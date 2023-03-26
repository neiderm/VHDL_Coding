--
-- 1-of-8 decoder (One-Cold)
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/decoders/decoders_2.vhd
--
-- neiderm; convert to 1-of-4
--
library ieee;
use ieee.std_logic_1164.all;

entity decoders_2 is
    port (sel: in std_logic_vector (1 downto 0);
          res: out std_logic_vector (3 downto 0));
end decoders_2;

architecture archi of decoders_2 is
begin
    res <= "1110" when sel = "00" else
           "1101" when sel = "01" else
           "1011" when sel = "10" else
           "0111";
end archi;
