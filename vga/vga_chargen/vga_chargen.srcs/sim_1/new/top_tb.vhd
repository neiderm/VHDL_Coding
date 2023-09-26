----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2023 06:56:42 PM
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

    COMPONENT top
        PORT (
            clk : IN std_logic;
            reset    : IN std_logic;
            sw       : IN std_logic_vector (15 DOWNTO 0);
            vgaRed   : OUT std_logic_vector (3 DOWNTO 0);
            vgaGreen : OUT std_logic_vector (3 DOWNTO 0);
            vgaBlue  : OUT std_logic_vector (3 DOWNTO 0);
            led      : OUT std_logic_vector (15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk : std_logic := '0';
    SIGNAL reset : std_logic;
    SIGNAL sw : std_logic_vector (15 DOWNTO 0) := "0000101001011010";
    SIGNAL led : std_logic_vector (15 DOWNTO 0);

begin

    clk <= NOT clk AFTER 5ns;
    reset <= '1', '0' AFTER 10ns;

    dut : top
    PORT MAP(
        clk => clk, 
        reset => reset, 
        sw => sw, 
        led => led
    );

end Behavioral;
