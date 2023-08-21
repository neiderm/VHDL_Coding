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
        imgRow0 : integer := 120;  -- row at which bitmap starts on the screen
        imgCol0 : integer := 160); -- column at which bitmap starts on the screen
    port (
        clk_in   : in  std_logic;
        disp_ena : in  std_logic;  -- display enable ('1' = display time, '0' = blanking time)
        row_r    : in  integer;    -- row pixel coordinate
        col_r    : in  integer;    -- column pixel coordinate
        red      : out std_logic_vector(3 downto 0) := (others => '0');
        green    : out std_logic_vector(3 downto 0) := (others => '0');
        blue     : out std_logic_vector(3 downto 0) := (others => '0'));
end pix_address;

architecture Behavioral of pix_address is

    signal rgb_out  : std_logic_vector(15 downto 0); -- ROM is 16-bits RGB 555
    signal pix_addr : UNSIGNED(8 downto 0);  -- address bus width must match that of generated ROM!!!!!!

    constant imgW   : integer := 8;
    constant imgH   : integer := 16;

    constant BMP_HDR_SZ : integer := 68 / 2; -- (54 / 2); -- convert bmp header offset (byte) to address width of img rom (16-bit!)
    
begin
    --------------------------------------------------
    --------------------------------------------------
    u_img_rom : entity work.img_rom
      port map (
        Clk  => clk_in,
        A    => std_logic_vector(pix_addr), -- ADDRESS HAS TO BE OFFET BY BITMAP HEADER 
        D    => rgb_out
        );
    --------------------------------------------------
    --------------------------------------------------
    process (clk_in)

        variable addri: integer; -- variable to simplify expression

    begin
        if (clk_in'EVENT and clk_in = '1') then

            if (disp_ena = '1') then
--                if (row_r < imgRow0) then
--                    -- offset past bmp header
--                    pix_addr <= to_unsigned(BMP_HDR_SZ, pix_addr'length);
--                end if;

                if (row_r >= imgRow0) and (row_r < (imgRow0 + imgH)) and
                   (col_r >= imgCol0) and (col_r < (imgCol0 + imgW))
                then
                    red      <= rgb_out(13 downto 10); -- RBG 555
                    green    <= rgb_out( 8 downto 5);  -- RBG 555
                    blue     <= rgb_out( 3 downto 0);  -- RBG 555

                    -- pix_addr <= pix_addr + 1;

                    addri := BMP_HDR_SZ + ((row_r - imgRow0) * imgW + (col_r - imgCol0));
                    pix_addr <= to_unsigned(addri, pix_addr'length);
                else
                    red   <= (others => '0');
                    green <= (others => '0');
                    blue  <= (others => '0');
                end if;
            end if; --disp_ena
        end if;
    end process;

end Behavioral;
