----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2023 02:17:32 PM
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is

    component top
        port (clk   : in std_logic;
              reset : in std_logic;
              sw    : in std_logic_vector (15 downto 0);
              led   : out std_logic_vector (15 downto 0));
    end component;

    signal clk   : std_logic := '0'; -- clock must be in known state for sim to start!
    signal reset : std_logic;
     -- initial condition of sw must be in known state!
    signal sw    : std_logic_vector (15 downto 0) := "0000101001011010"; --  (others => '0');
    signal led   : std_logic_vector (15 downto 0);

begin
    clk <= NOT clk AFTER 5ns;
    reset <= '1', '0' AFTER 10ns;

    dut : top
    port map (clk   => clk,
              reset => reset,
              sw    => sw,
              led   => led);

end Behavioral;
