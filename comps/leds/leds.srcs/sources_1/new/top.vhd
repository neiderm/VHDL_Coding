----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2023 03:05:10 PM
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
-- neiderm: drive LEDs from 16-bit counter with synchronous-clear
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
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           --sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is
    signal ledb : std_logic_vector(31 downto 0);
    signal counter : unsigned(31 downto 0);
begin

    led <= ledb(31 downto 16);

    process(clk)
        --variable v16 : unsigned(15 downto 0);
    begin
        if (clk'event and clk = '1') then

            ledb <= std_logic_vector(counter);

            if (reset = '1') then   -- synchronous clear
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

end Behavioral;

