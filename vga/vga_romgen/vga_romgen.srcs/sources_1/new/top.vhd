----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/15/2023 06:39:21 AM
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
--   RB: multiplexor example, see Zhang 2001
--       https://www.chegg.com/homework-help/questions-and-answers/tell-writing-code-vhdl-code-4-1-multiplexor-esd-book-figure-25-weijun-zhang-04-2001-multip-q9066873
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
           led   : out STD_LOGIC_VECTOR (15 downto 0);
           Vsync : out STD_LOGIC;
           Hsync : out STD_LOGIC;
           vgaRed   : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0));
end top;

architecture Behavioral of top is
    signal reset_l  : STD_LOGIC;
    signal clk_cntr : STD_LOGIC_VECTOR(3 downto 0);
    signal clk_vga  : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal pixel_x  : INTEGER;
    signal pixel_y  : INTEGER;
    signal rgb24    : STD_LOGIC_VECTOR(24 downto 0); -- convert to 12-bit bus
    signal rgb12    : STD_LOGIC_VECTOR(11 downto 0);
    signal rgbS0    : STD_LOGIC_VECTOR(11 downto 0);
    signal rgbS1    : STD_LOGIC_VECTOR(11 downto 0);
    signal mux_sel  : STD_LOGIC_VECTOR(1 downto 0);

begin
    --------------------------------------------------
    -- drive external pins
    --------------------------------------------------
--    vgaRed    <= rgb24(23 downto 20) when video_on = '1' else (others => '0');
--    vgaGreen  <= rgb24(15 downto 12) when video_on = '1' else (others => '0');
--    vgaBlue   <= rgb24( 7 downto 4)  when video_on = '1' else (others => '0');

    vgaRed    <= rgb12(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen  <= rgb12(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue   <= rgb12(3 downto 0) when video_on = '1' else (others => '0');

    led(15 downto 12) <= sw(15 downto 12);
    led(11 downto 0)  <= sw(11 downto 0);

    --------------------------------------------------
    -- invert the active high reset to active low 
    --------------------------------------------------
    reset_l <= not reset;

    --------------------------------------------------
    -- clocks
    --------------------------------------------------
    clk_vga <= clk_cntr(1); -- vga clock 25 Mhz

    u_clk_div: entity work.counters_1
    port map(
        C   => clk,
        CLR => reset,
        Q   => clk_cntr
    );

    --------------------------------------------------
    -- video multplexer (architecture 1)
    --------------------------------------------------
    mux_sel <= sw(15 downto 14);

    u_mux0 : entity work.Mux(behv2)
        generic map(
            RGB_SIGW => 12 - 1)
        port map(
            I0 => rgbS0, 
            I1 => rgbS1,
            I2 => (others => '0'), 
            I3 => (others => '0'),
            S => mux_sel,
            O => rgb12
        );

    --------------------------------------------------
    -- video multplexer (architecture 2)
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
            reset_n  => reset_l,
            h_sync   => Hsync,
            v_sync   => Vsync,
            disp_ena => video_on,
            column  => pixel_x,
            row     => pixel_y,
            n_blank => open,
            n_sync  => open
        );

    --------------------------------------------------
    -- static RGB test pattern from discrete logic
    --------------------------------------------------

    rgbS0(11 downto 8) <= rgb24(23 downto 20);
    rgbS0( 7 downto 4) <= rgb24(15 downto 12);
    rgbS0( 3 downto 0) <= rgb24( 7 downto 4);

    u_hw_img_gen : entity work.hw_image_generator
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

    -----------------------------------------------------------
    -- set screen fill color from switches
    -----------------------------------------------------------
    rgbS1 <= sw(11 downto 0);


end Behavioral;
