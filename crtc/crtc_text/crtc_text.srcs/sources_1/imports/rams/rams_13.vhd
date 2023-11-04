--
-- Dual-Port RAM with One Enable Controlling Both Ports
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/rams/rams_13.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rams_13 is
    port (clk   : in std_logic;
          en    : in std_logic;
          we    : in std_logic;
          addra : in std_logic_vector(6 downto 0);
          addrb : in std_logic_vector(6 downto 0);
          di    : in std_logic_vector(15 downto 0);
          doa   : out std_logic_vector(15 downto 0);
          dob   : out std_logic_vector(15 downto 0));
end rams_13;

architecture syn of rams_13 is
    type ram_type is array (127 downto 0) of std_logic_vector (15 downto 0);

--    signal RAM : ram_type;
    signal RAM : ram_type:= (
        X"200A", X"0300", X"8101", X"4000", X"8601", X"233A", X"0300", X"8602",
	X"2310", X"203B", X"8300", X"4002", X"8201", X"0500", X"4001", X"2500",
	X"0340", X"0241", X"4002", X"8300", X"8201", X"0500", X"8101", X"0602",
        X"4003", X"241E", X"0301", X"0102", X"2122", X"2021", X"0301", X"0102",
	X"2222", X"4001", X"0342", X"232B", X"0900", X"0302", X"0102", X"4002",
	X"0900", X"8201", X"2023", X"0303", X"2433", X"0301", X"4004", X"0301",
        X"0102", X"2137", X"2036", X"0301", X"0102", X"2237", X"4004", X"0304",
	X"4040", X"2500", X"2500", X"2500", X"030D", X"2341", X"8201", X"400D",
        X"200A", X"0300", X"8101", X"4000", X"8601", X"233A", X"0300", X"8602",
	X"2310", X"203B", X"8300", X"4002", X"8201", X"0500", X"4001", X"2500",
	X"0340", X"0241", X"4112", X"8300", X"8201", X"0500", X"8101", X"0602",
        X"4003", X"241E", X"0301", X"0102", X"2122", X"2021", X"0301", X"0102",
	X"2222", X"4001", X"0342", X"232B", X"0870", X"0302", X"0102", X"4002",
	X"0900", X"8201", X"2023", X"0303", X"2433", X"0301", X"4004", X"0301",
        X"0102", X"2137", X"F036", X"0301", X"0102", X"0237", X"4934", X"0304",
	X"4078", X"1110", X"2500", X"2500", X"030D", X"2341", X"8201", X"410D"
	);

    signal read_addra : std_logic_vector(6 downto 0);
    signal read_addrb : std_logic_vector(6 downto 0);
begin

    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (en = '1') then
                if (we = '1') then
                    RAM(conv_integer(addra)) <= di;
                end if;

                read_addra <= addra;
                read_addrb <= addrb;

            end if;
        end if;
    end process;

    doa <= RAM(conv_integer(read_addra));
    dob <= RAM(conv_integer(read_addrb));

end syn;
