----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Red~Bote
-- 
-- Create Date: 10/20/2023 06:44:38 PM
-- Design Name: 
-- Module Name: vram_addresser - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--   character tile RAM addresser generator.
-- Dependencies: 
--   Dot clock, and sync signal generator that provides scan row and scan column
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vram_addresser is
    GENERIC (
        constant IMG_OFFSET : in integer := 0; -- display a bitmap image, skip the header
        constant VGA_COLS : in integer := 640;
        constant VGA_ROWS : in integer := 480;
        constant TILE_WIDTH : in integer := 8;
        constant TILE_HEIGHT : in integer := 8;
        constant CHARS_PER_LINE : in integer := 80
    );
    Port ( pix_clk : in STD_LOGIC;
           pix_x : in integer;
           pix_y : in integer;
           vr_address : out STD_LOGIC_VECTOR (13 downto 0);
           row_address : out STD_LOGIC_VECTOR (3 downto 0));
end vram_addresser;

architecture Behavioral of vram_addresser is

    signal row_counter : integer := 0;
    signal col_counter : integer := 0;
    signal row_char_count : integer := 0;
    signal col_char_count : integer := 0;
    signal eof : std_logic := '0';

begin

    PCLK : process(pix_clk)
    begin
        if rising_edge(pix_clk) 
        then
            -- row address counter
            if pix_y = 0
            then
                row_char_count <= 0;
                row_counter <= 0;
                eof <= '0';
            elsif pix_y > 0 
            then
                if pix_x = 0
                then
                    if eof = '0'
                    then
                        row_counter <= row_counter + 1;
                        if row_counter = (TILE_HEIGHT - 1)
                        then
                            row_counter <= 0;
                            row_char_count <= row_char_count + CHARS_PER_LINE;
                        end if;
                    end if;

                    if pix_y = (VGA_ROWS - 1)
                    then
                         eof <= '1';
                    end if;
                end if;
            end if;
            -- column address counter
            col_counter <= col_counter + 1;
            if col_counter = (TILE_WIDTH - 1)
            then
                col_counter <= 0;

                if col_char_count < (CHARS_PER_LINE - 1)
                then
                    col_char_count <= col_char_count + 1;
                end if;
            end if;

            if pix_x = 0
            then
                col_counter <= 0;
                col_char_count <= 0;
            end if;

        end if;
    end process;

    row_address <= std_logic_vector(to_unsigned(row_counter, row_address'length));

    vr_address(13 downto 0) <= 
        std_logic_vector( to_unsigned( IMG_OFFSET + row_char_count + col_char_count, vr_address'length ) )
    when eof = '0'
    else (others => '0');

end Behavioral;
