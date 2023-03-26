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
    signal cntr   : unsigned (31 downto 0);
    signal switches : std_logic_vector (15 downto 0);
    signal digsel : std_logic_vector (3 downto 0); -- selects digit pattern lookup
    signal segsel : std_logic_vector (1 downto 0); -- selects 1 of 4 anode drive 

    signal raddr   : std_logic_vector (RADDRBITS-1 downto 0);
    signal rdata   : std_logic_vector (RDATABITS-1 downto 0);
begin
    switches <= sw;
    --led <= switches ; -- std_logic_vector (cntr(31 downto 16));
    led <= rdata(15 downto 0);

    u_seg_decode : entity work.decoders_2
    port map (
        sel => segsel,
        res => an
    );

    dp <= '0';

    seg <= rdata(NUMSEGS-1 downto 0); -- drive output pins from ROM data

    u_seg_rom : entity work.rams_21c
--    generic map (ADDRW => 6,
--                 DATAW => 32)
    port map(
        clk  => clk,
        en   => '1',
        addr => raddr,
        data => rdata
    );

    u_seg_mux : entity work.multiplexers_4
    port map(
        s => segsel,
        a => sw(15 downto 12),
        b => sw(11 downto 8),
        c => sw(7 downto 4),
        d => sw(3 downto 0),
        o => digsel
    );

    process (clk)
        variable tmp_v32 : std_logic_vector(31 downto 0);
        variable tmp_v6  : std_logic_vector(RADDRBITS-1 downto 0);
        variable tmp_4u  : unsigned(3 downto 0);
    begin
        if (clk'EVENT and clk = '1') then

            tmp_4u  := 16 - cntr(31 downto 28); -- make a down counter to display on one of the 7-segments
            tmp_v32 := std_logic_vector(cntr);

            segsel <= tmp_v32(20 downto 19); -- 2-bits taken to make fast enough multiplex rate across the 4 segments

            raddr <= (others => '0'); -- 0 the bits first since only [3:0] are set
            raddr(3 downto 0) <= digsel;

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
