----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2023 03:45:06 PM
-- Design Name: 
-- Module Name: ssd4 - Behavioral
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

entity ssd4 is
    generic (
             constant NUMSEGS : integer := 7;
             constant RDATABITS : integer := 20;
             constant RADDRBITS : integer := 6
            );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           dnum : in STD_LOGIC_VECTOR (31 downto 0); -- displayed number, the reason we're here
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC);
end ssd4;

architecture Behavioral of ssd4 is

    signal cntr    : std_logic_vector (31 downto 0);
    signal digsel  : std_logic_vector (3 downto 0); -- selects digit pattern lookup

    signal raddr   : std_logic_vector (RADDRBITS-1 downto 0);
    signal rdata   : std_logic_vector (RDATABITS-1 downto 0);

begin

    process (rdata)
    begin
        seg <= rdata(NUMSEGS-1 downto 0); -- drive output pins from ROM data
    end process;

    u_seg_rom : entity work.rams_21c
--    generic map (ADDRW => 6,
--                 DATAW => 32)
    port map(
        clk  => clk,
        en   => '1',
        addr => raddr,
        data => rdata
    );

    process (digsel)
    begin
        raddr <= (others => '0'); -- 0 the bits first since only [3:0] are set
        raddr(3 downto 0) <= digsel;
    end process;

     -- synchronize displayed information with the segment being driven
    u_seg_mux : entity work.concurrent_selected_assignment
    generic map (width => 4)
    port map(
        sel => cntr(20 downto 19),
        a => cntr(31 downto 28),
        b => cntr(27 downto 24),
        c => (others => '0'), -- sw(7 downto 4),
        d => (others => '0'), -- sw(3 downto 0),
        t => digsel
    );

     -- segment selection using a pair of counter bits with close enough timing for flicker-free display
    u_seg_decode : entity work.decoders_2
    port map (
        sel => cntr(20 downto 19), -- segment/digit selector
        res => an
    );

    u_counter_1 : entity work.counters_1
    generic map (DATAW => 32)
    port map(
        C   => clk,
        Q   => cntr,
        CLR => reset
    );

end Behavioral;
