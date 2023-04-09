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
--use IEEE.NUMERIC_STD.ALL;

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
    signal leds    : std_logic_vector(15 downto 0);
    signal switches : std_logic_vector(15 downto 0);
    signal video_on : std_logic;
    signal pixel_x  : INTEGER;
    signal pixel_y  : INTEGER;
    signal rgbR   : std_logic_vector(7 downto 0);
    signal rgbG   : std_logic_vector(7 downto 0);
    signal rgbB   : std_logic_vector(7 downto 0);
begin

   led <= leds;
   switches <= sw;

    --leds <= (3 downto 0 => counter, others => '0'); -- vhdl 2008
    leds(3 downto 0) <= clocks2;
    leds(15 downto 4) <= (others => '0'); 

    u_clk_div: entity work.counters_1
    port map(
        C   => clk,
        CLR => reset,
        Q   => clocks2
    );

    clk_vga <= clocks2(1);

    --------------------------------------------------
    -- invert the active high reset to active low 
    --------------------------------------------------
    reset_l <= not reset;

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

    -- set RGB test pattern from the image ROM at a specific location on the screen
    u_bmp_img_gen : entity work.hw_image_generator
        GENERIC map (
            pixels_y => 240,  --row that first color will persist until
            pixels_x => 320)  --column that first color will persist until
        port map(
            disp_ena => '1', -- video_on ... tbd, enable is applied to final mux output 
            row      => pixel_y,
            column   => pixel_x,
            red      => rgbR,
            green    => rgbG,
            blue     => rgbB
            );

    -- rgb register gated onto VGA signals only during video on time
    vgaRed    <= rgbR(7 downto 4) when video_on = '1' else (others => '0');
    vgaGreen  <= rgbG(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue   <= rgbB(7 downto 4) when video_on = '1' else (others => '0');

-- ha teaching moment don't do this!
--    vgaRed   <= rgbR(7 downto 4);
--    vgaGreen <= rgbG(7 downto 4);
--    vgaBlue  <= rgbB(7 downto 4);

end Behavioral;
