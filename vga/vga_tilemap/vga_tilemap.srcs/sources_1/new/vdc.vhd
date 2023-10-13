----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2023 08:47:52 PM
-- Design Name: 
-- Module Name: vdc - Behavioral
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
-- RB: VGA demo project from
--     https://forum.digikey.com/t/vga-controller-vhdl/12794
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vdc is
    port (
        pclk : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        video_on : out STD_LOGIC;
        rgb : out STD_LOGIC_VECTOR (11 downto 0)
    );
end vdc;

architecture Behavioral of vdc is
    signal video_on_i : std_logic ;
    signal hsync_p0 : STD_LOGIC;
    signal vsync_p0 : STD_LOGIC;
    signal pixel_x : INTEGER;
    signal pixel_y : INTEGER;
    signal red : std_logic_vector (7 downto 0);
    signal green : std_logic_vector (7 downto 0);
    signal blue : std_logic_vector (7 downto 0);
begin
    --------------------------------------------------
    --  VGA controller
    --------------------------------------------------
    u_vga_control : entity work.vga_controller
        generic map(
            h_pulse => 96,
            h_bp => 46,
            h_pixels => 640,
            h_fp => 16,
            h_pol => '0',
            v_pulse => 2,
            v_bp => 33,
            v_pixels => 480,
            v_fp => 10,
            v_pol => '0')
        port map(
            pixel_clk => pclk, -- 25 Mhz
            reset_n => '1', -- reset_l,  (RB: no reset, causes DRC warnings regarding BRAM address!)
            h_sync => hsync_p0,
            v_sync => vsync_p0,
            disp_ena => video_on_i, -- video_on,
            column => pixel_x,
            row => pixel_y,
            n_blank => open,
            n_sync => open
        );
    hsync <= hsync_p0;
    vsync <= vsync_p0;
    video_on <= video_on_i;
    --------------------------------------------------
    --  image generator
    --------------------------------------------------
    u_img_view : entity work.hw_image_generator
        generic map(
            pixels_x => 320,
            pixels_y => 240
            )
        port map(
            column => pixel_x,
            row => pixel_y,
            red => red,
            green => green,
            blue => blue,
            disp_ena => video_on_i
        );
        rgb(11 downto 8) <= red(7 downto 4);
        rgb(7 downto 4) <= green(7 downto 4);
        rgb(3 downto 0) <= blue(7 downto 4);

end Behavioral;
