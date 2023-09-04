-- This file was generated with hex2rom written by Daniel Wallner
-- (RB: bitmap header removed for testing)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity img_rom is
	port(
		Clk	: in std_logic;
		A	: in std_logic_vector(6 downto 0);
		D	: out std_logic_vector(15 downto 0)
	);
end img_rom;

architecture rtl of img_rom is
	signal A_r : std_logic_vector(6 downto 0);
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
		when 000000 => D <= "0111111111111111";	-- 0x0000
		when 000001 => D <= "0111111111111111";	-- 0x0002
		when 000002 => D <= "0111110000000000";	-- 0x0004
		when 000003 => D <= "0111110000000000";	-- 0x0006
		when 000004 => D <= "0111110000000000";	-- 0x0008
		when 000005 => D <= "0111110000000000";	-- 0x000A
		when 000006 => D <= "0000001111100000";	-- 0x000C
		when 000007 => D <= "0000001111100000";	-- 0x000E
		when 000008 => D <= "0000001111100000";	-- 0x0010
		when 000009 => D <= "0000001111100000";	-- 0x0012
		when 000010 => D <= "0000000000011111";	-- 0x0014
		when 000011 => D <= "0000000000011111";	-- 0x0016
		when 000012 => D <= "0000000000011111";	-- 0x0018
		when 000013 => D <= "0000000000011111";	-- 0x001A
		when 000014 => D <= "0111111111111111";	-- 0x001C
		when 000015 => D <= "0111111111111111";	-- 0x001E
		when 000016 => D <= "0111111111111111";	-- 0x0020
		when 000017 => D <= "0111111111111111";	-- 0x0022
		when 000018 => D <= "0111110000000000";	-- 0x0024
		when 000019 => D <= "0111110000000000";	-- 0x0026
		when 000020 => D <= "0111110000000000";	-- 0x0028
		when 000021 => D <= "0111110000000000";	-- 0x002A
		when 000022 => D <= "0000001111100000";	-- 0x002C
		when 000023 => D <= "0000001111100000";	-- 0x002E
		when 000024 => D <= "0000001111100000";	-- 0x0030
		when 000025 => D <= "0000001111100000";	-- 0x0032
		when 000026 => D <= "0000000000011111";	-- 0x0034
		when 000027 => D <= "0000000000011111";	-- 0x0036
		when 000028 => D <= "0000000000011111";	-- 0x0038
		when 000029 => D <= "0000000000011111";	-- 0x003A
		when 000030 => D <= "0111111111111111";	-- 0x003C
		when 000031 => D <= "0111111111111111";	-- 0x003E
		when others => D <= "----------------";
		end case;
	end process;
end;
