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
        constant imgRow0 : integer := 0;  -- row at which bitmap starts on the screen
        constant imgCol0 : integer := 0); -- column at which bitmap starts on the screen
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
    signal rgb_ena  : std_logic := '0';
    signal pix_addr : UNSIGNED((ADDR_BITS-1) downto 0) := (others => '0');
    
    constant imgW   : integer := 16;
    constant imgH   : integer := 2;

    constant BMP_HDR_SZ : integer := 70 / 2; -- bitmap header size, in 16-bit words

    -- row and col are considered by the syntheses tool as inputs to the ROM 
    -- and so must be registered to infer a BRAM without setting off DRC warnings
    signal row_r : integer := 0;
    signal col_r : integer := 0;

begin
    --------------------------------------------------
    u_img_rom : entity work.img_rom
        port map (
            Clk  => clk_in,
            A    => std_logic_vector(pix_addr),
            D    => rgb_out
        );

    --------------------------------------------------
	process (clk_in)
	begin
        if clk_in'event and clk_in = '1' then
            row_r <= row_in;
            col_r <= col_in;
        end if;
	end process;

    --------------------------------------------------
    pix_addr <= to_unsigned(
        BMP_HDR_SZ +
        (
            (row_r - imgRow0) * imgW + 
            (col_r - imgCol0)
        ), pix_addr'length );

    --------------------------------------------------
    process (row_r, col_r)
        -- offset the starting column of the bmp image line by one pixel to 
        -- compensate for 1-clock delay of registered address in the image ROM
        variable imgCol1 : integer := imgCol0 + 1; 
    begin
        if row_r >= imgRow0 and row_r < (imgRow0 + imgH) and 
           col_r >= imgCol1 and col_r < (imgCol1 + imgW)
        then
            rgb_ena <= '1';
        else
            rgb_ena <= '0';
        end if;
    end process;

    --------------------------------------------------
    process (rgb_ena, rgb_out)
    begin
        -- default RGB output to black
        red   <= (others => '0');
        green <= (others => '0');
        blue  <= (others => '0');

        -- vertical test bar for manually adjusting H-alignment of VGA panel
        --if (col_in >= 0 and col_in < 2 and row_in >= 4) -- 2 pixel wide
        if (col_in = 0 and row_in > 2) or 
           (col_in = 639) or
           (row_in = 479) or 
           (row_in = 0 and col_in >= 320) 
        then
            red   <= (others => '1');
            green <= (others => '0');
            blue  <= (others => '0');
        end if;

        if rgb_ena = '1'
        then
            red   <= rgb_out(14 downto 11); -- RBG 555
            green <= rgb_out( 9 downto 6);  -- RBG 555
            blue  <= rgb_out( 4 downto 1);  -- RBG 555
        end if;

    end process;
    
end Behavioral;
