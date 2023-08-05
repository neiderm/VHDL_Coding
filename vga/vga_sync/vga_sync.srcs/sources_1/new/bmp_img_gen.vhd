----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Red~Bote
-- 
-- Create Date: 08/03/2023 05:17:36 PM
-- Design Name: 
-- Module Name: bmp_img_gen - Behavioral
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

entity bmp_img_gen is
    generic (
        FileName : string := "rgb.bmp.dat"; 
        imgY     : integer := 0;
        imgX     : integer := 0;
        VGA_BITS : integer := 12  -- VGA bus width
    );
    port (
        clk_in  : in std_logic;
        row_in  : in integer;
        col_in  : in integer;
        rgb_out : out std_logic_vector(VGA_BITS-1 downto 0)
    );
end bmp_img_gen;

architecture Behavioral of bmp_img_gen is
begin
    u_bmp_loader: entity work.bmp_loader
        generic map(
            imgRow0 => imgY,
            imgCol0 => imgX,
            FileName => FileName
        )
        port map (
            clk     => clk_in,
            row_in  => row_in,
            col_in  => col_in,
            dout    => rgb_out
        );

end Behavioral;
