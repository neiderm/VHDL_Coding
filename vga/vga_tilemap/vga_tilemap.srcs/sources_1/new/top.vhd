----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2023 03:28:13 PM
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
           Hsync : out std_logic;
           Vsync : out std_logic;
           vgaRed : out std_logic_vector(0 to 3);
           vgaBlue : out std_logic_vector(0 to 3);
           vgaGreen : out std_logic_vector(0 to 3);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end top;

architecture Behavioral of top is

    signal clock_refs : std_logic_vector(3 downto 0);
    signal clk_vga : std_logic;
    signal reset_l : std_logic;
    signal hsync_p0 : std_logic;
    signal vsync_p0 : std_logic;
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

    clk_vga <= clock_refs(1);

    --------------------------------------------------
    --  VGA controller
    --------------------------------------------------
    u_vdc : entity work.vdc
        port map(
            pclk => clk_vga, -- 25 Mhz
            reset_l => reset_l,
            h_sync => hsync_p0,
            v_sync => vsync_p0,
            rgb => rgb,
            disp_ena => video_on
        );

   --------------------------------------------------
    --  output signals
    --------------------------------------------------
    Hsync <= hsync_p0;
    Vsync <= vsync_p0;

--    rgb <= sw(11 downto 0);

    vgaRed <= rgb(11 downto 8) when video_on = '1' else (others => '0');
    vgaGreen <= rgb(7 downto 4) when video_on = '1' else (others => '0');
    vgaBlue <= rgb(3 downto 0) when video_on = '1' else (others => '0');

    led(15 downto 0) <= sw(15 downto 0);

end Behavioral;
