----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Red~Bote
-- 
-- Create Date: 10/15/2023 06:20:59 PM
-- Design Name: 
-- Module Name: vdc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
--     Dot clock, and sync signal generator that provides scan row and scan column
--       https://forum.digikey.com/t/vga-controller-vhdl/12794
--     8x8 tile character sets with various encodings:
--       https://github.com/mobluse/chargen-maker.git
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--  Testing: create test patterns in simulated character tile VRAM using zx80 set (64 characters)
--    </dev/zero head -c 80 | tr '\0' '\46' > tempvram.bin  # \46 == 0x26 == 38 == A
--  Use hex2rom (from T80 VHDL distribution) to convert binary data to a VHDL RAM/ROM entity:
--    hex2rom -b tempvram.bin char_vram 9l8s > vga_chargen.srcs/sources_1/new/char_vram.vhd 
--
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

entity vdc is
    GENERIC (
        constant VGA_COLS : in integer := 640;
        constant VGA_ROWS : in integer := 480;
        constant CHARS_PER_LINE : in integer := 80
    );
    Port ( pclk : in STD_LOGIC;
           reset_l : in STD_LOGIC;
           disp_ena : out STD_LOGIC;
           h_sync : out STD_LOGIC;
           v_sync : out STD_LOGIC;
           rgb : out STD_LOGIC_VECTOR (11 downto 0));
end vdc;

architecture Behavioral of vdc is
    signal pixel_x : integer;
    signal pixel_y : integer;
    signal disp_ena_p0 : std_logic;
    signal disp_ena_p1 : std_logic;
    signal disp_ena_p2 : std_logic;
    signal disp_ena_p3 : std_logic;
    signal disp_ena_p4 : std_logic;
    signal hsync_p0 : std_logic;
    signal hsync_p1 : std_logic;
    signal hsync_p2 : std_logic;
    signal hsync_p3 : std_logic;
    signal hsync_p4 : std_logic;
    signal vsync_p0 : std_logic;
    signal vsync_p1 : std_logic;
    signal vsync_p2 : std_logic;
    signal vsync_p3 : std_logic;
    signal vsync_p4 : std_logic;

    signal char_raddr : std_logic_vector(3 downto 0); -- character row address
    signal vram_addr : std_logic_vector(13 downto 0);
    signal vram_charcode: std_logic_vector(7 downto 0);
    signal rom_addr : std_logic_vector(8 downto 0);
    signal chargen_rdata : std_logic_vector(7 downto 0);

    signal pixel_bit : std_logic; -- bit output from mux
    signal pix_col_select : std_logic_vector(2 downto 0);
    signal pix_col_select_p0 : std_logic_vector(2 downto 0);
    signal pix_col_select_p1 : std_logic_vector(2 downto 0);
    signal pix_col_select_p2 : std_logic_vector(2 downto 0);

begin
    u_vga_control : entity work.vga_controller
        GENERIC map (
            h_pulse  => 96,
            h_bp     => 46,
            h_pixels => VGA_COLS,
            h_fp     => 16,
            h_pol    => '0',
            v_pulse  => 2,
            v_bp     => 33,
            v_pixels => VGA_ROWS,
            v_fp     => 10,
            v_pol    => '0')
        port map(
            pixel_clk => pclk, -- 25 Mhz
            reset_n  => reset_l, 
            h_sync   => hsync_p0,
            v_sync   => vsync_p0,
            disp_ena => disp_ena_p0,
            column  => pixel_x,
            row     => pixel_y,
            n_blank => open,
            n_sync  => open
        );

    u_vram_addr : entity work.vram_addresser
    generic map(
        IMG_OFFSET => 218 --set this to header size if generated from .BMP image
--        ADDR_BITS => C_VRAM_ADDR_BITS
    )
    port map(
        pix_clk => pclk,
        pix_x => pixel_x,
        pix_y => pixel_y,
        vr_address => vram_addr,
        row_address => char_raddr
        );

    --------------------------------------------------
    -- VRAM
    --------------------------------------------------
    u_char_vram: entity work.char_vram
    port map(
        Clk => pclk,
        A => vram_addr,
        D => vram_charcode
    );

    --------------------------------------------------
    -- character generator ROM address decoder
    --  ROM address = character_code * font_height + scan_row % font_height
    --------------------------------------------------
    -- 64 x 8 x 8-bit-fontheight:
    rom_addr(8 downto 3) <= vram_charcode(5 downto 0); --  character_code * font_height
    rom_addr(2 downto 0) <= char_raddr(2 downto 0);    --  scan_row % font_height

    --------------------------------------------------
    -- character generator ROM
    --------------------------------------------------
    u_char_gen_rom: entity work.charg_rom
    port map(
        Clk => pclk,
        A => rom_addr,
        D => chargen_rdata -- 1 row of character tile pixels
    );

    --------------------------------------------------
    -- synchronize signals
    --------------------------------------------------
    process (pclk)
    begin
        if rising_edge(pclk) then
            -- synchronize pixel selection to font row data
            pix_col_select_p0 <= std_logic_vector(to_unsigned(pixel_x, pix_col_select'length));
            pix_col_select_p1 <= pix_col_select_p0;
            pix_col_select_p2 <= pix_col_select_p1;
--            pix_col_select <= pix_col_select_p1;
            pix_col_select <= pix_col_select_p2;
            -- synchronize syncs
            hsync_p1 <= hsync_p0;
            hsync_p2 <= hsync_p1;
            hsync_p3 <= hsync_p2;
            hsync_p4 <= hsync_p3;
            vsync_p1 <= vsync_p0;
            vsync_p2 <= vsync_p1;
            vsync_p3 <= vsync_p2;
            vsync_p4 <= vsync_p4;
            disp_ena_p1 <= disp_ena_p0;
            disp_ena_p2 <= disp_ena_p1;
            disp_ena_p3 <= disp_ena_p2;
            disp_ena_p4 <= disp_ena_p3;
        end if;
    end process;

    --------------------------------------------------
    -- pixel output
    --------------------------------------------------
    -- "shift" the pixel of the current scan column out of the character row data
    u_char_pix_mux: entity work.multiplexers_1
    port map(
        di => chargen_rdata,
        sel => pix_col_select,
        do => pixel_bit
    );

    --------------------------------------------------
    -- drive output signals
    --------------------------------------------------
    disp_ena <= disp_ena_p4;
    h_sync <= hsync_p4;
    v_sync <= vsync_p3; -- todo: vsync_p4 loses sync, see if vsync pipelining matters
    rgb <= (others => pixel_bit); -- set pixel RGB all white (or all black)

end Behavioral;
