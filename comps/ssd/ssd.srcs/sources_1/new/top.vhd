----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/22/2023 04:49:40 PM
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
--  neiderm: adapted from example 
--  https://www.fpga4student.com/2017/09/vhdl-code-for-seven-segment-display.html
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    generic (
             constant SEGBIT   : integer := 29);
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        sw : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0);
        an : out STD_LOGIC_VECTOR (3 downto 0);
        seg : out STD_LOGIC_VECTOR (6 downto 0);
        dp : out STD_LOGIC
    );
end top;

architecture Behavioral of top is
    signal cntr   : unsigned (31 downto 0);
    signal switches : std_logic_vector (15 downto 0);
    signal digsel : std_logic_vector (3 downto 0); -- selects digit pattern lookup
    signal segsel : std_logic_vector (1 downto 0); -- selects 1 of 4 anode drive 
    signal segr   : std_logic_vector (7 downto 0);
begin
    switches <= sw;
    -- see HDL_Coding_Techniques/decoders_2.vhd:-- 1-of-8 decoder (One-Cold
    an <= "1110" when segsel = "00"
     else "1101" when segsel = "01"
     else "1011" when segsel = "10"
     else "0111";

    dp <= '0';
    led <= std_logic_vector (cntr(31 downto 16));
    seg <= segr(6 downto 0); -- drive output pins from segment register

    process (clk)
    begin
        if (clk'EVENT and clk = '1') then
            -- infers a registered address
            digsel <= std_logic_vector(cntr(SEGBIT downto SEGBIT-(4-1)));
            segsel <= std_logic_vector(cntr(20 downto 19)); -- 2-bits taken to make fast enough multiplex rate across the 4 segments

            case digsel is
                when "0000" => segr <= "01000000"; -- "0" 
                when "0001" => segr <= "01111001"; -- "1"
                when "0010" => segr <= "00100100"; -- "2"
                when "0011" => segr <= "00110000"; -- "3"
                when "0100" => segr <= "00011001"; -- "4"
                when "0101" => segr <= "00010010"; -- "5"
                when "0110" => segr <= "00000010"; -- "6"
                when "0111" => segr <= "01111000"; -- "7"
                when "1000" => segr <= "00000000"; -- "8" 
                when "1001" => segr <= "00010000"; -- "9"
                when "1010" => segr <= "00001000"; -- "A"
                when "1011" => segr <= "00000011"; -- "B"
                when "1100" => segr <= "01000110"; -- "C"
                when "1101" => segr <= "00100001"; -- "D"
                when "1110" => segr <= "00000110"; -- "E"
                when others => segr <= "00001110"; -- "F" (1111) 
            end case;

        end if;
    end process;
    
    process (clk)
    begin
        if (clk'EVENT and clk = '1') then
            if (reset = '1') then
                cntr <= (others => '0');
            else
                cntr <= cntr + 1;
            end if;
        end if;
    end process;

end Behavioral;
