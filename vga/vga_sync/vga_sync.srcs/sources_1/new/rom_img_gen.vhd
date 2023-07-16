----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/15/2023 03:07:18 PM
-- Design Name: 
-- Module Name: rom_img_gen - Behavioral
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

entity rom_img_gen is
    generic (
        imgRow0 : integer := 120;  -- row at which bitmap starts on the screen
        imgCol0 : integer := 160); -- column at which bitmap starts on the screen

    port (
        clk_in   : in  std_logic;
        disp_ena : in  std_logic;                                        -- display enable ('1' = display time, '0' = blanking time)
        row_r    : in  integer;                                          -- row pixel coordinate
        col_r    : in  integer;                                          -- column pixel coordinate
        red      : out std_logic_vector(3 downto 0) := (others => '0');  --red output
        green    : out std_logic_vector(3 downto 0) := (others => '0');  --green output
        blue     : out std_logic_vector(3 downto 0) := (others => '0')); --blue output
end rom_img_gen;

architecture Behavioral of rom_img_gen is

    signal rgb_out  : std_logic_vector(19 downto 0); -- ROM is 20-bits data bus
    signal pix_addr : UNSIGNED(6 downto 0);

    constant imgW   : integer := 8;
    constant imgH   : integer := 16;

begin

    u_img_rom : entity work.roms_signal
        --    generic map(
        --      imgRow0 => 120,
        --      imgCol0 => 160
        --      imgW => 8;
        --      imgH => 16;
        --    )
        port map(
            clk  => clk_in,
            en   => disp_ena,
            --      row  => row,
            --      col  => column,
            addr => std_logic_vector(pix_addr),
            data => rgb_out
        );

    process (clk_in)
    begin
        if (clk_in'EVENT and clk_in = '1') then

            if (disp_ena = '1') then
                if (row_r < imgRow0) then
                    pix_addr <= to_unsigned(0, pix_addr'length);
                end if;

                if (row_r >= imgRow0) and (row_r < (imgRow0 + imgH)) and
                    (col_r >= imgCol0) and (col_r < (imgCol0 + imgW))
                then
                    red      <= rgb_out(19 downto 16);
                    green    <= rgb_out(15 downto 12);
                    blue     <= rgb_out(7 downto 4);
                    pix_addr <= pix_addr + 1;
                else
                    red   <= (others => '1');
                    green <= (others => '1');
                    blue  <= (others => '1');

                end if;
            end if; --disp_ena
        end if;
    end process;

end Behavioral;