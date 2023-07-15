----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2023 01:08:01 PM
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
-- 
-- Demonstrating VGA on BASYS 3 from online example code:
--   https://forum.digikey.com/t/vga-controller-vhdl/12794
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

entity top is
    Port ( clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           sw    : in STD_LOGIC_VECTOR (15 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC;
           vgaRed   : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR (3 downto 0);
           led      : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is
    signal reset_l : std_logic;
    signal clocks2 : std_logic_vector(3 downto 0);
    signal clk_vga : std_logic;
    signal video_on : std_logic;
    signal pixel_x  : INTEGER;
    signal pixel_y  : INTEGER;
    signal rgb24    : std_logic_vector(24 downto 0); -- convert to 12-bit data
    signal rgb_mI0  : std_logic_vector(11 downto 0); -- rgb mux in 0
    signal rgb_mI1  : std_logic_vector(11 downto 0); -- rgb mux in 1
    signal rgb_mI2  : std_logic_vector(11 downto 0); -- rgb mux in 2
    signal rgb_mI3  : std_logic_vector(11 downto 0); -- rgb mux in 3
    signal rgb_mOut : std_logic_vector(11 downto 0); -- rgb mux out
    signal mux_sel  : std_logic_vector(1 downto 0); -- rgb mux select vector
    signal data24   : std_logic_vector(19 downto 0); -- convert to 12-bit data
    signal pix_addr : unsigned(6 downto 0); -- used to address the ROM
begin
    led <= sw;

    -------------------------------------------------------
    -- static RGB test pattern from arbitrary data from ROM
    -------------------------------------------------------
    pix_addr <= to_unsigned(pixel_y, pix_addr'length);
    rgb_mI2 <= data24(19 downto 8); -- connect arbitrary set of signals to RGB output

    bmp_img_gen : entity work.roms_signal
        port map(
            clk     => clk_vga, -- clk?
            en      => '1', -- video_on 
            addr    => std_logic_vector(pix_addr),
            data    => data24);

    --------------------------------------------------
    -- video multplexer
    --------------------------------------------------
    u_mux2 : entity work.Mux(behv2)
        generic map(
            RGB_SIGW => 12 - 1)
        port map(
            I0 => rgb_mI0, 
            I1 => rgb_mI1,
            I2 => rgb_mI2, 
            I3 => rgb_mI3, -- (others => '0'), 
            S => mux_sel,
            O => rgb_mOut
        );

    --------------------------------------------------
    -- video multplexer
    --------------------------------------------------
    u_mux1 : entity work.Mux(behv1)
        port map(
            I0 => (others => '0'), 
            I1 => (others => '0'),
            I2 => (others => '0'), 
            I3 => (others => '0'),
            S => (others => '0'),
            O => open
        );

    rgb_mI0 <= sw(11 downto 0);
    rgb_mI1(11 downto 8) <= rgb24(23 downto 20);
    rgb_mI1(7 downto 4) <= rgb24(15 downto 12);
    rgb_mI1(3 downto 0) <= rgb24(7 downto 4);
    mux_sel <= sw(15 downto 14);

    vgaRed    <= rgb_mOut(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen  <= rgb_mOut(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue   <= rgb_mOut(3 downto 0) when video_on = '1' else (others => '0');

    --------------------------------------------------
    -- invert the active high reset to active low 
    --------------------------------------------------
    reset_l <= not reset;

    --------------------------------------------------
    -- clocks
    --------------------------------------------------
    u_clk_div: entity work.counters_1
    port map(
        C   => clk,
        CLR => reset,
        Q   => clocks2
    );

    clk_vga <= clocks2(1);

    --------------------------------------------------
    -- video subsystem
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
            reset_n => reset_l,
            h_sync => Hsync,
            v_sync => Vsync,
            disp_ena => video_on,
            column => pixel_x,
            row => pixel_y,
            n_blank => open,
            n_sync => open
        );

    --------------------------------------------------
    -- static RGB test pattern from discrete logic
    --------------------------------------------------
    u_bmp_img_gen : entity work.hw_image_generator
        GENERIC map (
            pixels_y => 240,  --row that first color will persist until
            pixels_x => 320)  --column that first color will persist until
        port map(
            disp_ena => '1', -- video_on ... or not, enable is applied to final output 
            row      => pixel_y,
            column   => pixel_x,
            red      => rgb24(23 downto 16),
            green    => rgb24(15 downto 8),
            blue     => rgb24(7 downto 0)
            );


-- ha teaching moment don't do this!
--    vgaRed   <= rgbR(7 downto 4);
--    vgaGreen <= rgbG(7 downto 4);
--    vgaBlue  <= rgbB(7 downto 4);

end Behavioral;
