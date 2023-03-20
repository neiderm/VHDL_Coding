----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/20/2023 05:29:37 PM
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
--   neiderm: entity work.rams_20c
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
    Port ( --reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is

    signal counter : unsigned(32-1 downto 0);

    signal odata : std_logic_vector (31 downto 0);
begin

    led(15 downto 0) <= odata(15 downto 0);

    process(clk)
    begin
        if (clk'event and clk = '1') then
            counter <= counter + 1;
        end if;
    end process;

    u_rom : entity work.rams_20c
    port map(
        clk  => clk,
        we   => '0',
        addr => std_logic_vector(counter(32-1 downto 32-6)), -- std_logic_vector(counter(6-1 downto 0)),
        din  =>  (others => '1'),
        dout => odata
    );

end Behavioral;
