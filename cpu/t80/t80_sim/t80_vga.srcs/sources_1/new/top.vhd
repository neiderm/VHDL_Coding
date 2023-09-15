----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/06/2023 01:52:46 PM
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
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity top is
    Port (
        reset : in STD_LOGIC;
        clk   : in STD_LOGIC;
        led  : out std_logic_vector(15 downto 0)
        );
end top;

architecture Behavioral of top is
    signal clocks2 : std_logic_vector(3 downto 0); -- 4-bit clock/counter
    signal clk_vga : std_logic;
    signal clk_cpu : std_logic;
    signal reset_l : std_logic;

    -- cpu
    signal cpu_mreq_l     : std_logic;
    signal cpu_wr_l       : std_logic;
    signal cpu_addr       : std_logic_vector(15 downto 0);
    signal cpu_data_out   : std_logic_vector(7 downto 0);
    signal cpu_data_in    : std_logic_vector(7 downto 0);
    signal ram_data_in    : std_logic_vector(15 downto 0); --rams08 16-bit databus

    signal prog_rom_data  : std_logic_vector(7 downto 0);
    signal rams_data_out  : std_logic_vector(15 downto 0); --rams08 16-bit databus

    signal work_ram_cs_l  : std_logic;
    signal prog_rom_cs_l  : std_logic;

    --signal mem_wr_l       : std_logic;
    signal work_rams_we   : std_logic;
    signal work_rams_ce   : std_logic;
begin
    --------------------------------------------------
    -- invert the active high reset to active low 
    --------------------------------------------------
    reset_l <= not reset;

    --------------------------------------------------
    -- clocks
    --------------------------------------------------
    u_clk_div: entity work.counters_1
    port map(
        C   => clk,
        CLR => reset,
        Q   => clocks2
    );

    clk_vga <= clocks2(1); -- 25 Mhz
    clk_cpu <= clocks2(3); -- 6.25 Mhz

    --------------------------------------------------
    -- CPU
    --------------------------------------------------
    u_cpu : entity work.T80s
        port map(
            RESET_n => reset_l,
            CLK_n   => clk_cpu,
            WAIT_n  => '1', -- cpu_wait_l,
            INT_n   => '1', -- cpu_int_l,
            NMI_n   => '1', -- cpu_nmi_l,
            BUSRQ_n => '1', -- cpu_busrq_l,
            M1_n    => open, -- cpu_m1_l,
            MREQ_n  => cpu_mreq_l,
            IORQ_n  => open, -- cpu_iorq_l,
            RD_n    => open, -- cpu_rd_l,
            WR_n    => cpu_wr_l,
            -- RFSH_n  => cpu_rfsh_l,
            -- HALT_n  => cpu_halt_l,
            -- BUSAK_n => cpu_busak_l,
            A       => cpu_addr,
            DI      => cpu_data_in,
            DO      => cpu_data_out
        );
    -- test
    led <= cpu_addr;

    --------------------------------------------------
    -- work RAM
    --------------------------------------------------
    work_rams_we <= not (cpu_wr_l or cpu_mreq_l); -- WR_n==0 AND MREQ_n==0
    --work_rams_ce <= not (work_ram_cs_l);
    ram_data_in(7 downto 0) <= cpu_data_out; -- 16-bit data bus

    u_rams : entity work.rams_08
      port map (
        a    => cpu_addr(5 downto 0),
        di   => ram_data_in,
        do   => rams_data_out,
        we   => work_rams_we, -- write enable, active high
        en   => '1',          -- chip enable, active high   
        clk  => clk_cpu
      );

    --------------------------------------------------
    -- internal program rom
    --------------------------------------------------
    u_program_rom : entity work.prog_rom
      port map (
        Clk  => clk_cpu,
        A    => cpu_addr(5 downto 0), -- ADDR_BITS
        D    => prog_rom_data -- cpu_data_in
        );

    --------------------------------------------------
    -- primary addr decode (chip selects)
    --------------------------------------------------
    prog_rom_cs_l  <= '0' when cpu_addr(15)           = '0'     else '1'; -- ROM at $0000, RAM at $8000
    work_ram_cs_l  <= '0' when cpu_addr(15 downto 11) = "10000" else '1'; -- Work RAM at $8000 (1k or 2k)
    -------------------

    -- cpu data in mux (bus isolation)
    cpu_data_in  <=
        prog_rom_data              when prog_rom_cs_l = '0' else
        rams_data_out(7 downto 0)  when work_ram_cs_l = '0' else
        x"FF"; -- should never be read by CPU?

end Behavioral;
