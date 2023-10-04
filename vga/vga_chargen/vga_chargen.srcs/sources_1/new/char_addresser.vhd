----------------------------------------------------------------------------------
-- Company: 
-- Engineer: RB
-- 
-- Create Date: 09/27/2023 06:40:03 PM
-- Design Name: 
-- Module Name: char_addresser - Behavioral
-- Project Name: character generator
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--   calculate address of 8x8 character tile from input pixel_x and pixel_y scan coordinates
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--   Conversion help:
--   https://nandland.com/common-vhdl-conversions/#Numeric-Integer-To-Std_Logic_Vector
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

entity char_addresser is
    GENERIC (
            NCOLUMNS : integer := 80;
            ADDR_BITS : integer := 13); -- 8k should be plenty
    Port (
            pixel_r : in integer;
            pixel_c : in integer;
            address : out STD_LOGIC_VECTOR (ADDR_BITS-1 downto 0));

end char_addresser;

architecture Behavioral of char_addresser is
begin

	process (pixel_r, pixel_c)
        variable i_addr : integer;
	begin

        i_addr := pixel_r / 8 * NCOLUMNS + pixel_c / 8;
        address <= std_logic_vector(to_unsigned(i_addr, address'length));

	end process;

end Behavioral;
