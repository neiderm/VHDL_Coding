----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/26/2023 04:56:08 PM
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
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC;
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is

    signal reset_l : STD_LOGIC;
    signal clk_cntr : STD_LOGIC_VECTOR(3 downto 0);
    signal clk_vga : STD_LOGIC;
    signal video_on : STD_LOGIC;
    signal h_sync_l : STD_LOGIC;
    signal v_sync_l : STD_LOGIC;
    signal pixel_x : integer;
    signal pixel_y : integer;
    signal rgb12 : STD_LOGIC_VECTOR(11 downto 0);
begin
    --------------------------------------------------
    -- drive external pins
    --------------------------------------------------
    Hsync <= h_sync_l;
    Vsync <= v_sync_l;

    vgaRed    <= rgb12(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen  <= rgb12(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue   <= rgb12(3 downto 0) when video_on = '1' else (others => '0');

-- This does not work, must be synced to video_on signal!
--    vgaRed    <= sw(11 downto 8);
--    vgaGreen  <= sw(7 downto 4);
--    vgaBlue   <= sw(3 downto 0);
    rgb12 <= sw(11 downto 0);
    led (15 downto 12) <= sw(15 downto 12);

    reset_l <= not reset;

    clk_vga <= clk_cntr(1);

    u_clocks: entity work.counters_1
    port map(
        C => clk,
        CLR => reset,
        Q => clk_cntr
    );

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
            h_sync   => h_sync_l,
            v_sync   => v_sync_l,
            disp_ena => video_on,
            column  => open, -- pixel_x,
            row     => open, -- pixel_y,
            n_blank => open,
            n_sync  => open
        );

end Behavioral;
