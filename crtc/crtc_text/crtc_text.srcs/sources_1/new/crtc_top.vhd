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
           led : out STD_LOGIC_VECTOR (15 downto 0);
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end crtc_top;

architecture Behavioral of crtc_top is
    signal reset_l : std_logic;
    signal clock_refs : std_logic_vector(3 downto 0);
    signal clk_25 : std_logic;
    signal clk_cpu : std_logic;
    signal video_on : std_logic;
    signal rgb : std_logic_vector (11 downto 0);
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
            MREQ_n  => open, -- cpu_mreq_l,
            IORQ_n  => open, -- cpu_ioreq_l,
            RD_n    => open, -- cpu_rd_l,
            WR_n    => open, -- cpu_wr_l,
            -- RFSH_n  => cpu_rfsh_l,
            -- HALT_n  => cpu_halt_l,
            -- BUSAK_n => cpu_busak_l,
            A       => open, -- cpu_addr,
            DI      => (others => '0'), -- cpu_data_in,
            DO      => open -- cpu_data_out
        );

    --------------------------------------------------
    --  VGA controller
    --------------------------------------------------
    u_vdc : entity work.vdc
        port map(
            pclk => clk_25,
            reset => reset,
            hsync => Hsync,
            vsync => Vsync,
            rgb => rgb,
            disp_ena => video_on
        );

    --------------------------------------------------
    --  output signals
    --------------------------------------------------
    --rgb <= sw(11 downto 0);

    vgaRed <= rgb(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen <= rgb(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue <= rgb(3 downto 0) when video_on = '1' else (others => '0');

    led(15 downto 0) <= sw(15 downto 0);

end Behavioral;
