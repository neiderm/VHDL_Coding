--
-- 4-bit Unsigned Up Accumulator with Asynchronous Reset
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/accumulators/accumulators_1.vhd
--
-- neiderm: imported accumulators to re-purpose the port interface
--
library ieee;
use ieee.std_logic_1164.all;

entity accumulators_1 is
    generic (
        WIDTH : integer := 4);
    port(
        clk  : in  std_logic;
        rst  : in  std_logic;
        D    : in  std_logic_vector(WIDTH-1 downto 0);
        Q    : out std_logic_vector(WIDTH-1 downto 0));
end accumulators_1;

architecture archi of accumulators_1 is
begin
    u_debounce_0 : entity work.debounce
    port map(
        reset_n => rst,
        clk => clk,
        button => D(0),
        result => Q(0)
    );
    
    u_debounce_1 : entity work.debounce
    port map(
        reset_n => rst,
        clk => clk,
        button => D(1),
        result => Q(1)
    );

    u_debounce_2 : entity work.debounce
    port map(
        reset_n => rst,
        clk => clk,
        button => D(2),
        result => Q(2)
    ); 

    u_debounce_3 : entity work.debounce
    port map(
        reset_n => rst,
        clk => clk,
        button => D(3),
        result => Q(3)
    );
end archi;
