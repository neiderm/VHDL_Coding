----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2023 03:29:02 PM
-- Design Name: 
-- Module Name: crtc_tb - Behavioral
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

entity crtc_tb is
--  Port ( );
end crtc_tb;

architecture Behavioral of crtc_tb is

    COMPONENT crtc_top
        PORT (
            clk : IN std_logic;
            reset    : IN std_logic;
            sw       : IN std_logic_vector (15 DOWNTO 0);
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

    dut : crtc_top
    PORT MAP(
        clk => clk, 
        reset => reset, 
        sw => sw, 
        led => led
    );

end Behavioral;
