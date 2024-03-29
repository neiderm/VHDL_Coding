-- This file was generated with hex2rom written by Daniel Wallner

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity char_vram is
	port(
		Clk	: in std_logic;
		A	: in std_logic_vector(13 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end char_vram;

architecture rtl of char_vram is
	signal A_r : std_logic_vector(13 downto 0);
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
		when 000000 => D <= "00111110";	-- 0x0000
		when 000001 => D <= "00111110";	-- 0x0001
		when 000002 => D <= "00100110";	-- 0x0002
		when 000003 => D <= "00100110";	-- 0x0003
		when 000004 => D <= "00011100";	-- 0x0004
		when 000005 => D <= "00011100";	-- 0x0005
		when 000006 => D <= "00011101";	-- 0x0006
		when 000007 => D <= "00011101";	-- 0x0007
		when 000008 => D <= "00011110";	-- 0x0008
		when 000009 => D <= "00011110";	-- 0x0009
		when 000010 => D <= "00011111";	-- 0x000A
		when 000011 => D <= "00011111";	-- 0x000B
		when 000012 => D <= "00100000";	-- 0x000C
		when 000013 => D <= "00100000";	-- 0x000D
		when 000014 => D <= "00100001";	-- 0x000E
		when 000015 => D <= "00100001";	-- 0x000F
		when 000016 => D <= "00100010";	-- 0x0010
		when 000017 => D <= "00100010";	-- 0x0011
		when 000018 => D <= "00100011";	-- 0x0012
		when 000019 => D <= "00100011";	-- 0x0013
		when 000020 => D <= "00100100";	-- 0x0014
		when 000021 => D <= "00100100";	-- 0x0015
		when 000022 => D <= "00100101";	-- 0x0016
		when 000023 => D <= "00100101";	-- 0x0017
		when 000024 => D <= "00100110";	-- 0x0018
		when 000025 => D <= "00100110";	-- 0x0019
		when 000026 => D <= "00100111";	-- 0x001A
		when 000027 => D <= "00100111";	-- 0x001B
		when 000028 => D <= "00101000";	-- 0x001C
		when 000029 => D <= "00101000";	-- 0x001D
		when 000030 => D <= "00101001";	-- 0x001E
		when 000031 => D <= "00101001";	-- 0x001F
		when 000032 => D <= "00101010";	-- 0x0020
		when 000033 => D <= "00101010";	-- 0x0021
		when 000034 => D <= "00101011";	-- 0x0022
		when 000035 => D <= "00101011";	-- 0x0023
		when 000036 => D <= "00101100";	-- 0x0024
		when 000037 => D <= "00101100";	-- 0x0025
		when 000038 => D <= "00101101";	-- 0x0026
		when 000039 => D <= "00101101";	-- 0x0027
		when 000040 => D <= "00101110";	-- 0x0028
		when 000041 => D <= "00101110";	-- 0x0029
		when 000042 => D <= "00101111";	-- 0x002A
		when 000043 => D <= "00101111";	-- 0x002B
		when 000044 => D <= "00110000";	-- 0x002C
		when 000045 => D <= "00110000";	-- 0x002D
		when 000046 => D <= "00110001";	-- 0x002E
		when 000047 => D <= "00110001";	-- 0x002F
		when 000048 => D <= "00110010";	-- 0x0030
		when 000049 => D <= "00110010";	-- 0x0031
		when 000050 => D <= "00110011";	-- 0x0032
		when 000051 => D <= "00110011";	-- 0x0033
		when 000052 => D <= "00110100";	-- 0x0034
		when 000053 => D <= "00110100";	-- 0x0035
		when 000054 => D <= "00110101";	-- 0x0036
		when 000055 => D <= "00110101";	-- 0x0037
		when 000056 => D <= "00110110";	-- 0x0038
		when 000057 => D <= "00110110";	-- 0x0039
		when 000058 => D <= "00110111";	-- 0x003A
		when 000059 => D <= "00110111";	-- 0x003B
		when 000060 => D <= "00111000";	-- 0x003C
		when 000061 => D <= "00111000";	-- 0x003D
		when 000062 => D <= "00111001";	-- 0x003E
		when 000063 => D <= "00111001";	-- 0x003F
		when 000064 => D <= "00111010";	-- 0x0040
		when 000065 => D <= "00111010";	-- 0x0041
		when 000066 => D <= "00111011";	-- 0x0042
		when 000067 => D <= "00111011";	-- 0x0043
		when 000068 => D <= "00111100";	-- 0x0044
		when 000069 => D <= "00111100";	-- 0x0045
		when 000070 => D <= "00111101";	-- 0x0046
		when 000071 => D <= "00111101";	-- 0x0047
		when 000072 => D <= "00111110";	-- 0x0048
		when 000073 => D <= "00111110";	-- 0x0049
		when 000074 => D <= "00111111";	-- 0x004A
		when 000075 => D <= "00111111";	-- 0x004B
		when 000076 => D <= "00000110";	-- 0x004C
		when 000077 => D <= "00000110";	-- 0x004D
		when 000078 => D <= "00000010";	-- 0x004E
		when 000079 => D <= "00000010";	-- 0x004F
		when others => D <= "--------";
		end case;
	end process;
end;
