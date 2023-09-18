----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2023 05:44:02 AM
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);

           Vsync : out STD_LOGIC;
           Hsync : out STD_LOGIC;

           led : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is
    signal reset_l  : STD_LOGIC;
    signal clk_cntr : STD_LOGIC_VECTOR(3 downto 0);
    signal clk_vga  : STD_LOGIC;
    signal clk_cpu  : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal pixel_x  : INTEGER;
    signal pixel_y  : INTEGER;

    -- hsync and vsync used internally
    signal vsync_int : STD_LOGIC;
    signal hsync_int : STD_LOGIC;

    signal toggler   : STD_LOGIC := '0';

begin
    --------------------------------------------------
    -- update IO and other signals
    --------------------------------------------------
    --led <= sw;
    reset_l <= not reset; -- invert active-high reset button

    --------------------------------------------------
    -- clocks
    --------------------------------------------------
    u_clk_div: entity work.counters_1
    port map(
        C   => clk,
        CLR => reset,
        Q   => clk_cntr
    );

    clk_vga <= clk_cntr(1); -- vga clock 25 Mhz
    clk_cpu <= clk_cntr(3); -- 6.25 Mhz

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
            IORQ_n  => open, -- cpu_iorq_l,
            RD_n    => open, -- cpu_rd_l,
            WR_n    => open, --cpu_wr_l,
            -- RFSH_n  => cpu_rfsh_l,
            -- HALT_n  => cpu_halt_l,
            -- BUSAK_n => cpu_busak_l,
            A       => open, -- cpu_addr,
            DI      => (others => '0'), -- cpu_data_in,
            DO      => open --cpu_data_out
        );

    --------------------------------------------------
    -- video subsystem
    --------------------------------------------------
    u_vga_control : entity work.vga_controller
        GENERIC map (
            h_pulse  => 96,
            h_bp     => 46,
            h_pixels => 640,
            h_fp     => 16,
            h_pol    => '0',
            v_pulse  => 2,
            v_bp     => 33,
            v_pixels => 480,
            v_fp     => 10,
            v_pol    => '0')
        port map(
            pixel_clk => clk_vga, -- 25 Mhz
            reset_n  => reset_l,
            h_sync   => hsync_int,
            v_sync   => vsync_int,
            disp_ena => video_on,
            column  => pixel_x,
            row     => pixel_y,
            n_blank => open,
            n_sync  => open
        );

        hSync <= hsync_int;
        vSync <= vsync_int;

    --------------------------------------------------
    -- toggle signal on vsync (active low falling edge)
    --------------------------------------------------
    process (vsync_int)
    begin
        if vsync_int'event and vsync_int = '0'
        then
            if toggler = '1'
            then
                toggler <= '0';
            else
                toggler <= '1';
            end if;
        end if;
    end process;

    led(15) <= toggler;

end Behavioral;
