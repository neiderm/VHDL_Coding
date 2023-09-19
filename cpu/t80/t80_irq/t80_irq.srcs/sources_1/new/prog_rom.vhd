-- This file was generated with hex2rom written by Daniel Wallner

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity prog_rom is
	port(
		Clk	: in std_logic;
		A	: in std_logic_vector(5 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end prog_rom;

architecture rtl of prog_rom is
	signal A_r : std_logic_vector(5 downto 0);
begin
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			A_r <= A;
		end if;
	end process;
	process (A_r)
	begin
		case to_integer(unsigned(A_r)) is
		when 000000 => D <= "00100001";	-- 0x0000
		when 000001 => D <= "00000000";	-- 0x0001
		when 000002 => D <= "10000000";	-- 0x0002
		when 000003 => D <= "10101111";	-- 0x0003
		when 000004 => D <= "01110111";	-- 0x0004
		when 000005 => D <= "00111100";	-- 0x0005
		when 000006 => D <= "00101100";	-- 0x0006
		when 000007 => D <= "01110111";	-- 0x0007
		when 000008 => D <= "00110100";	-- 0x0008
		when 000009 => D <= "01111110";	-- 0x0009
		when 000010 => D <= "00011000";	-- 0x000A
		when 000011 => D <= "11111001";	-- 0x000B
		when 000012 => D <= "00000000";	-- 0x000C
		when others => D <= "--------";
		end case;
	end process;
end;
