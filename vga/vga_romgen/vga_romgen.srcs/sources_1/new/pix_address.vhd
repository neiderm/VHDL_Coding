----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/20/2023 08:40:18 AM
-- Design Name: 
-- Module Name: pix_address - Behavioral
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
-- RB (9/2023)
--  This entity is an address generator to render a bitmap image to VGA from a VHDL array.
--  The bitmap data is converted to VHDL from a bitmap file using the hex2rom utilitiy
--  found in the t80 distribution. See "t80/trunk/sw/hex2rom.cpp". For example, the command line:
--   hex2rom -b rgb_16x2.bmp  \
--     img_rom 7l16s > vga_romgen/vga_romgen.srcs/sources_1/new/img_rom.vhd
--  ... generates a VHDL synchronised ROM with 16-bit data, little-endian and 7-bits address width.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pix_address is
    generic (
        constant ADDR_BITS : integer := 7; -- must match address width from generated ROM file
        constant imgRow0 : integer := 240;  -- row at which bitmap starts on the screen
        constant imgCol0 : integer := 320); -- column at which bitmap starts on the screen
    port (
        clk_in   : in  std_logic;
        disp_ena : in  std_logic;  -- display enable ('1' = display time, '0' = blanking time)
        row_in   : in  integer;    -- row pixel coordinate
        col_in   : in  integer;    -- column pixel coordinate
        red      : out std_logic_vector(3 downto 0) := (others => '0');
        green    : out std_logic_vector(3 downto 0) := (others => '0');
        blue     : out std_logic_vector(3 downto 0) := (others => '0'));
end pix_address;

architecture Behavioral of pix_address is

    signal rgb_out  : std_logic_vector(15 downto 0); -- ROM is 16-bits RGB 555
    signal rgb_ena  : std_logic;
    signal pix_addr : UNSIGNED((ADDR_BITS-1) downto 0) := (others => '0');

    constant imgW   : integer := 16;
    constant imgH   : integer := 2;

    constant BMP_HDR_SZ : integer := 70 / 2;
    
begin
    --------------------------------------------------
    u_img_rom : entity work.img_rom
      port map (
        Clk  => clk_in,
        A    => std_logic_vector(pix_addr),
        D    => rgb_out
        );

    --------------------------------------------------
    pix_addr <= to_unsigned(
        BMP_HDR_SZ +   --BMP_HDR_SZ
        (
            (row_in - imgRow0) * imgW
             + (col_in - imgCol0)
        ), pix_addr'length );

    --------------------------------------------------
    process (row_in, col_in)
        variable imgC_1ck : integer := imgCol0 + 1;
    begin
      if row_in >= imgRow0 and row_in < (imgRow0 + imgH) and 
         col_in >= imgC_1ck and col_in < (imgC_1ck + imgW)
      then
          rgb_ena <= '1';
      else
          rgb_ena <= '0';
      end if;
    end process;
    
    process (rgb_ena, rgb_out)
    begin
        if (rgb_ena = '1')
        then
            red   <= rgb_out(14 downto 11); -- RBG 555
            green <= rgb_out( 9 downto 6);  -- RBG 555
            blue  <= rgb_out( 4 downto 1);  -- RBG 555
        else
            red   <= (others => '0');
            green <= (others => '0');
            blue  <= (others => '0');
        end if;
    end process;
end Behavioral;
