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
    generic (constant NUMSEGS : integer := 7;
             constant RADDRBITS : integer := 6;
             constant RDATABITS : integer := 20
             );
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
    signal switches : std_logic_vector (15 downto 0);
    signal cntr    : std_logic_vector (31 downto 0);
begin
    -- From Reset, free-run counter until any button pushed
    -- Buttons: +1 -1 <<1 >>1

    switches <= sw;

    led <= switches ; -- std_logic_vector (cntr(31 downto 16));
    --led <= rdata(15 downto 0);

    u_counter_1 : entity work.counters_1
    generic map (DATAW => 32)
    port map(
        C   => clk,
        Q   => cntr,
        CLR => reset
    );

    u_ssd4 : entity work.ssd4
    port map(
        dnum => cntr,
        clk => clk,
        reset => reset,
        seg => seg,
        an => an,
        dp => dp
    );

end Behavioral;
