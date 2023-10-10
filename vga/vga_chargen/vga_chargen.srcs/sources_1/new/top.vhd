----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2023 04:56:08 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- conversion helper:
--    https://nandland.com/common-vhdl-conversions/#Numeric-Integer-To-Std_Logic_Vector
-- Legacy character set data:
--    https://github.com/mobluse/chargen-maker
--
-- simulate reading characters from charecter tile vram
-- steps to generate character ROM from font data and convert to VHDL
--  cd chargen-maker
--  ./build.sh zx81.txt  
--  cd ..
--  hex2rom -b chargen-maker/zx81.bin charg_rom 9l8s > vga_chargen.srcs/sources_1/new/charg_rom.vhd 

--  </dev/zero head -c 80 | tr '\0' '\46' > tempvram.bin  # \46 == 0x26 == 38 == A

--  hex2rom -b tempvram.bin char_vram 9l8s > vga_chargen.srcs/sources_1/new/char_vram.vhd 
--
--  hex2rom  -b redbote_80x60_8bpp_deux.bmp char_vram 13l8s   > vga_chargen.srcs/sources_1/new/char_vram.vhd
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC;
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is

    constant C_VRAM_ADDR_BITS : integer := 13;

    signal reset_l : STD_LOGIC;
    signal clk_cntr : STD_LOGIC_VECTOR(3 downto 0);
    signal clk_vga : STD_LOGIC;
    signal video_on : STD_LOGIC;

    signal hsync_p0 : STD_LOGIC;
    signal vsync_p0 : STD_LOGIC;

    signal r_hsync : STD_LOGIC;
    signal r_vsync : STD_LOGIC;
    
    signal pixel_x : integer;
    signal pixel_y : integer;

    signal rgb12 : STD_LOGIC_VECTOR(11 downto 0);

    signal chargen_rdata : STD_LOGIC_VECTOR(7 downto 0);
    signal chargen_addr : STD_LOGIC_VECTOR(8 downto 0);

    signal char_vram_addr : std_logic_vector(C_VRAM_ADDR_BITS-1 downto 0);

    signal character_code : std_logic_vector(7 downto 0); -- 6-bits character code read from VRAM

    signal pixel_bit : std_logic; -- bit output from mux
    signal pix_col_select : std_logic_vector(2 downto 0);
begin

    --reset_l <= not reset;

    --------------------------------------------------
    --  clock reference
    --------------------------------------------------
    u_clocks: entity work.counters_1
    port map(
        C => clk,
        CLR => reset,
        Q => clk_cntr
    );

    clk_vga <= clk_cntr(1);

    --------------------------------------------------
    --  VGA controller
    --------------------------------------------------
    u_vga_control : entity work.vga_controller
        GENERIC map (
            h_pulse  => 96,
            h_bp     => 46,
            h_pixels => 640,
            h_fp     => 16,
            h_pol    => '0',
            v_pulse  => 2,
            v_bp     => 33,
            v_pixels => 480,
            v_fp     => 10,
            v_pol    => '0')
        port map(
            pixel_clk => clk_vga, -- 25 Mhz
            reset_n  => '1', -- reset_l,  (RB: no reset, causes DRC warnings regarding BRAM address!)
            h_sync   => hsync_p0,
            v_sync   => vsync_p0,
            disp_ena => video_on,
            column  => pixel_x,
            row     => pixel_y,
            n_blank => open,
            n_sync  => open
        );

    --------------------------------------------------
     -- decode character address in "VRAM" of currently scanned pixel coordinate
    u_char_vram_addr_gen: entity work.char_addresser
    generic map(
        IMG_OFFSET => 218, --set this to header size if generated from .BMP image
        ADDR_BITS => C_VRAM_ADDR_BITS
    )
    port map(
        pixel_r => pixel_y,
        pixel_c => pixel_x,
        address => char_vram_addr
    );
    --------------------------------------------------
    -- simulate reading characters from charecter tile vram
    u_char_tile_vram: entity work.char_vram
    port map(
        Clk => clk_vga,
        A => char_vram_addr(C_VRAM_ADDR_BITS-1 downto 0),
        D => character_code  -- base row address in character gen ROM = character code * 8
    );

    -- character generator ROM address decoder
    process (pixel_y, character_code)
        -- characters encoded in ROM are 8-bits high so low 3 bits of pixel_y 
        constant ROW_DECODE_BITS : integer := 3;
        variable char_row_addr : unsigned(ROW_DECODE_BITS-1 downto 0) := to_unsigned(pixel_y, ROW_DECODE_BITS);
    begin
        chargen_addr(2 downto 0) <= std_logic_vector(char_row_addr);
        -- "multiplies" the character code by 8 to offset to row 0 of the character data in ROM
        chargen_addr(8 downto 3) <= character_code(5 downto 0);
    end process;

    --------------------------------------------------
    --  character generator
    --------------------------------------------------
    u_char_gen_rom: entity work.charg_rom
    port map(
        Clk => clk_vga,
        A => chargen_addr,
        D => chargen_rdata -- 1 row of character tile pixels
    );

    -- pix_col_select <= std_logic_vector(to_unsigned(pixel_x, pix_col_select'length)); -- 3 bits pix col select
    -- pixel_x-1 is workaround to account for character code output of VRAM delayed 1-clock
--    pix_col_select <= std_logic_vector(to_unsigned(pixel_x - 1, pix_col_select'length));

    process (clk_vga)
    begin
        if clk_vga'event and clk_vga = '1' then
            pix_col_select <= std_logic_vector(to_unsigned(pixel_x, pix_col_select'length));

            r_hsync <= hsync_p0;
            r_vsync <= vsync_p0;
        end if;
    end process;

    -- "shift" the pixel of the current scan column out of the character row data
    u_char_pix_mux: entity work.multiplexers_1
    port map(
        di => chargen_rdata,
        sel => pix_col_select,
        do => pixel_bit
    );

    rgb12 <= (others => pixel_bit); -- set pixel RGB all white (or all black)

    --------------------------------------------------
    -- drive external pins
    --------------------------------------------------
--    Hsync <= h_sync_p0;
--    Vsync <= v_sync_p0;
    Vsync <= r_vsync;
    Hsync <= r_hsync;

    vgaRed    <= rgb12(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen  <= rgb12(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue   <= rgb12(3 downto 0) when video_on = '1' else (others => '0');

    led (15 downto 12) <= sw(15 downto 12);

end Behavioral;
