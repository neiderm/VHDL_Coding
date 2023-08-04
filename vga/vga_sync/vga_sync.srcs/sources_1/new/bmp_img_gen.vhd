----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
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

    constant imgRow0  : integer := 120;
    constant imgCol0  : integer := 240;
    constant imgW     : integer := 24; -- bmp_dat.dimensions.width;
    constant imgH     : integer := 19; -- bmp_dat.dimensions.height;
    signal   addr     : UNSIGNED(31 downto 0); -- initializing integer causes a synthesize warning on BRAM 

begin
    u_bmp_loader: entity work.bmp_loader
        generic map(
            FileName => "rgb.bmp.dat"
        )
        port map (
            clk     => clk_in,
            addr_in => addr,
            dout    => rgb_out
        );

    process (clk_in)
    begin
        if (clk_in'EVENT and clk_in = '1') then
            -- todo investigate using integer multiplication to get pix location directly instead of the free-running address counter
            if (row_in < imgRow0) then
                addr <= to_unsigned(0, addr'length);
            end if;
                
            if (row_in >= imgRow0) and (row_in < (imgRow0 + imgH)) and
               (col_in >= imgCol0) and (col_in < (imgCol0 + imgW))
            then
                addr <= addr + 1;
            end if;
        end if;
    end process;
end Behavioral;
