----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2023 06:56:11 PM
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
    port (
        clk : in STD_LOGIC;
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

    signal clk_pixel : STD_LOGIC;
    signal counter_clkref : STD_LOGIC_VECTOR (3 downto 0);

    signal rgb : STD_LOGIC_VECTOR (11 downto 0);
    signal video_on : STD_LOGIC;
begin
    --------------------------------------------------
    --  clock reference
    --------------------------------------------------
    u_clocks : entity work.counters_1
        port map(
            C => clk,
            CLR => reset,
            Q => counter_clkref
        );

    clk_pixel <= counter_clkref(1); -- 100 / 2 / 2 = 25 Mhz

    --------------------------------------------------
    --  video display controller
    --------------------------------------------------
    u_vdc : entity work.vdc
        port map(
            pclk => clk_pixel,
            hsync => Hsync,
            vsync => Vsync,
            video_on => video_on,
            rgb => rgb
        );
    vgaRed <= rgb(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen <= rgb(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue <= rgb(3 downto 0) when video_on = '1' else (others => '0');
--    rgb <= sw(11 downto 0); -- temp test
    led <= sw;

end Behavioral;
