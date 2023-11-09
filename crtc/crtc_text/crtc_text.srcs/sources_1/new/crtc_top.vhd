----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/01/2023 06:47:16 AM
-- Design Name: 
-- Module Name: crtc_top - Behavioral
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

entity crtc_top is
    Port ( clk : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           reset : in STD_LOGIC;
           btnU : in std_logic;
           led : out STD_LOGIC_VECTOR (15 downto 0);
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end crtc_top;

architecture Behavioral of crtc_top is

    signal vsync_int : STD_LOGIC;
    signal hsync_int : STD_LOGIC;

    signal int_reg_clr : STD_LOGIC;
    signal int_reg_out : STD_LOGIC;

    signal reset_l : std_logic;
    signal clock_refs : std_logic_vector(3 downto 0);
    signal clk_25 : std_logic;
    signal clk_cpu : std_logic;
    signal video_on : std_logic;
    signal rgb : std_logic_vector (11 downto 0);

    signal cpu_ioreq_l    : std_logic;
    signal cpu_int_l      : std_logic;
    signal cpu_m1_l       : std_logic;
    signal cpu_mreq_l     : std_logic;
    signal cpu_wr_l       : std_logic;
    signal cpu_nmi_l      : std_logic;

    signal cpu_address    : std_logic_vector(15 downto 0);
    signal cpu_data_in    : std_logic_vector(7 downto 0);
    signal cpu_data_out   : std_logic_vector(7 downto 0);

    signal prog_rom_cs_l  : std_logic;
    signal work_ram_cs_l  : std_logic;
    signal video_ram_cs_l : std_logic;
    signal prog_rom_data  : std_logic_vector(7 downto 0);

    signal ram_write_en   : std_logic;
    signal ram_data_in    : std_logic_vector(15 downto 0);
    signal ram_data_out   : std_logic_vector(15 downto 0);

    signal vram_wr_en     : std_logic;
begin
    --------------------------------------------------
    --  inputs
    --------------------------------------------------
    reset_l <= not reset;

   --------------------------------------------------
    --  clock reference
    --------------------------------------------------
    u_clocks: entity work.counters_1
    port map(
        C => clk,
        CLR => reset,
        Q => clock_refs
    );

    clk_25 <= clock_refs(1);
    clk_cpu <= clock_refs(3);

    --------------------------------------------------
    -- IRQ
    --------------------------------------------------
    -- /INT is level triggered, must be held until interrupt is acknowledged
    u_int_reg : entity work.registers_2
        port map(
            C     => vsync_int,
            D     => '1',         -- sets latch to 1 on falling edge of C
            CLR   => int_reg_clr, -- IORQ == 0 and M1 == 0
            Q     => int_reg_out
        );
        cpu_int_l <= NOT(int_reg_out);
        int_reg_clr <= not (cpu_ioreq_l or cpu_m1_l);

    -- NMI is edge triggered and needs no debouncing
    cpu_nmi_l <= not btnU; 

    --------------------------------------------------
    -- internal program ROM
    --------------------------------------------------
    u_program_rom : entity work.prog_rom
      port map (
        Clk  => clk_cpu,
        A    => cpu_address(8 downto 0), -- ADDR_BITS
        D    => prog_rom_data
        );

    --------------------------------------------------
    -- CPU
    --------------------------------------------------
    u_cpu : entity work.T80s
        port map(
            RESET_n => reset_l,
            CLK_n   => clk_cpu,
            WAIT_n  => '1', -- cpu_wait_l,
            INT_n   => cpu_int_l,
            NMI_n   => cpu_nmi_l,
            BUSRQ_n => '1', -- cpu_busrq_l,
            M1_n    => cpu_m1_l,
            MREQ_n  => cpu_mreq_l,
            IORQ_n  => cpu_ioreq_l,
            RD_n    => open, -- cpu_rd_l,
            WR_n    => cpu_wr_l,
            -- RFSH_n  => cpu_rfsh_l,
            -- HALT_n  => cpu_halt_l,
            -- BUSAK_n => cpu_busak_l,
            A       => cpu_address,
            DI      => cpu_data_in,
            DO      => cpu_data_out
        );

    --------------------------------------------------
    -- address decode (chip selects)
    --------------------------------------------------
    prog_rom_cs_l  <= '0' when cpu_address(15)           = '0'     else '1'; -- ROM at $0000, RAM at $8000
    work_ram_cs_l  <= '0' when cpu_address(15 downto 11) = "10000" else '1'; -- Work RAM at $8000 (1k or 2k)
    video_ram_cs_l <= '0' when cpu_address(15 downto 11) = "10001" else '1'; -- GFX RAM maps at $8800 (2k i.e. 11 address-bits)

    -- cpu data in mux (bus isolation)
    cpu_data_in  <=
        prog_rom_data             when prog_rom_cs_l = '0' else
        ram_data_out(7 downto 0)  when work_ram_cs_l = '0' else
        x"FF"; -- should never be read by CPU?

    --------------------------------------------------
    -- work RAM
    --------------------------------------------------
    ram_write_en <= not (cpu_wr_l or cpu_mreq_l); -- WR_n==0 AND MREQ_n==0
    ram_data_in(7 downto 0) <= cpu_data_out; -- 16-bit data bus

    u_rams : entity work.rams_08
      port map (
        a    => cpu_address(5 downto 0), -- map RAM to $8000
        di   => ram_data_in,
        do   => ram_data_out,
        we   => ram_write_en, -- write enable, active high
        en   => '1',   -- chip enable, active high (enable on clk_cpu?) 
        clk  => clk_cpu -- use system clock?
      );

    --------------------------------------------------
    --  video display controller
    --------------------------------------------------
    vram_wr_en <= not (cpu_wr_l or video_ram_cs_l);

    u_vdc : entity work.vdc
        port map(
            pclk => clk_25,
            reset => reset,
            address_in => cpu_address(13 downto 0),
            data_in => cpu_data_out,
            vram_wr_en => vram_wr_en, -- write enable, active high
            hsync => hsync_int,
            vsync => vsync_int,
            rgb => rgb,
            disp_ena => video_on
        );

    --------------------------------------------------
    --  output signals
    --------------------------------------------------
    --rgb <= sw(11 downto 0);
    hSync <= hsync_int;
    vSync <= vsync_int;

    vgaRed <= rgb(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen <= rgb(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue <= rgb(3 downto 0) when video_on = '1' else (others => '0');

    led(15 downto 0) <= sw(15 downto 0);

end Behavioral;
