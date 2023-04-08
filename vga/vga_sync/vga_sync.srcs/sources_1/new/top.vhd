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
           led   : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is
    signal clocks2 : std_logic_vector(3 downto 0);
    signal counter : std_logic_vector(3 downto 0);
    signal leds    : std_logic_vector(15 downto 0);
begin

   led <= leds;

   leds(3 downto 0) <= sw(3 downto 0);
   leds(15 downto 12) <= counter(3 downto 0);

    u_clk_div: entity work.counters_1
    port map(
        C   => clk,
        CLR => reset,
        Q   => clocks2
    );

    u_clk_cntr: entity work.counters_5
    port map(
        C   => clk,
        CLR => reset,
        CE  => clocks2(3),
        Q   => counter
    );

end Behavioral;
