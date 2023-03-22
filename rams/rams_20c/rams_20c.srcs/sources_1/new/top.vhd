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
    generic( constant CNTR_BITS : integer := 30; -- 24 (~10ms to sim)
             constant ADDR_BITS : integer := 6);
    Port ( reset : in STD_LOGIC;
           clk   : in STD_LOGIC;
           led   : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is

    -- use upper bits of large counter to address a pattern generator ROM
    signal address : std_logic_vector (5 downto 0);
    signal counter : std_logic_vector (CNTR_BITS-1 downto 0);

    -- registers to handle the data driving the LEDs
    signal romdata : std_logic_vector (31 downto 0);
    signal ledout  : std_logic_vector (15 downto 0);
begin
    led <= ledout;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            -- only uses upper or lower word16 (todo use a MUX)
            ledout <= romdata(15 downto 0);
            --ledout <= romdata(31 downto 16);

            -- synchronise address to avoid DRC warnings Warning The RAMB18E1  which is driven by a register has an active asychronous set or rese ;)
            --address <= counter(31 downto 26); -- 32-6=26
            address <= counter(CNTR_BITS-1 downto CNTR_BITS-ADDR_BITS); -- leave highest counter bit for bank selection
        end if;
    end process;

    u_addr_cntr : entity work.counters_1
    generic map(DWIDTH => CNTR_BITS)
    port map(
        C => clk,
        CLR => reset,
        Q => counter);

    u_rom : entity work.rams_20c
    port map(
        clk  => clk,
        we   => '0',
        --addr => std_logic_vector(counter(32-1 downto 32-6)) -- NO!
        addr => address(ADDR_BITS-1 downto 0),
        din  => (others => '1'),
        dout => romdata
    );

end Behavioral;
