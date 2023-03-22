--
-- 4-bit unsigned up counter with an asynchronous reset.
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/counters/counters_1.vhd
--
-- neiderm: added generic map for counter width
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counters_1 is
    generic(constant DWIDTH : integer := 4);
    port(C, CLR : in std_logic;
         Q : out std_logic_vector(DWIDTH-1 downto 0));
end counters_1;

architecture archi of counters_1 is
    signal tmp: std_logic_vector(DWIDTH-1 downto 0);
begin
    process (C, CLR)
    begin
        if (CLR='1') then
            tmp <= (others => '0');
        elsif (C'event and C='1') then
            tmp <= tmp + 1;
        end if;
    end process;

    Q <= tmp;

end archi;
