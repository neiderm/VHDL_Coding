--
-- A missing else that leads to a latch inference.
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/multiplexers/multiplexers_4.vhd
--
-- neiderm: converted to mux 4 vectors
--
library ieee;
use ieee.std_logic_1164.all;

entity multiplexers_4 is
    port (a, b, c, d: in std_logic_vector(3 downto 0);
          s : in std_logic_vector(1 downto 0);
          o : out std_logic_vector(3 downto 0));
end multiplexers_4;

architecture archi of multiplexers_4 is
begin
    process (a, b, c, d, s)
    begin
        if (s = "00") then o <= a;
        elsif (s = "01") then o <= b;
        elsif (s = "10") then o <= c;
        else o <= d;
        end if;
    end process;
end archi;
