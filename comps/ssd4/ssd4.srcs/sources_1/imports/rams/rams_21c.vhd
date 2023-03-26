--
-- ROMs Using Block RAM Resources.
-- VHDL code for a ROM with registered address
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/rams/rams_21c.vhd
--
-- neiderm: generic parameters
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rams_21c is
    generic (
        constant ADDRW : integer := 6;
        constant DATAW : integer := 20
    );
    port (
        clk : in std_logic;
        en : in std_logic;
        addr : in std_logic_vector(ADDRW - 1 downto 0);
        data : out std_logic_vector(DATAW - 1 downto 0)
    );
end rams_21c;

architecture syn of rams_21c is
--    type rom_type is array (2 ** ADDRW - 1 downto 0) of std_logic_vector (DATAW - 1 downto 0);
    type rom_type is array (0 to 2 ** ADDRW - 1) of std_logic_vector (DATAW - 1 downto 0);
        signal ROM : rom_type := (
        0 => X"00040", -- "01000000" -- "0" 
        1 => X"00079", -- "01111001" -- "1"
        2 => X"00024", -- "00100100" -- "2"
        3 => X"00030", -- "00110000" -- "3"
        4 => X"00019", -- "00011001" -- "4"
        5 => X"00012", -- "00010010" -- "5"
        6 => X"00002", -- "00000010" -- "6"
        7 => X"00078", -- "01111000" -- "7"
        8 => X"00000", -- "00000000" -- "8" 
        9 => X"00010", -- "00010000" -- "9"
       10 => X"00008", -- "00001000" -- "A"
       11 => X"00003", -- "00000011" -- "B"
       12 => X"00046", -- "01000110" -- "C"
       13 => X"00021", -- "00100001" -- "D"
       14 => X"00006", -- "00000110" -- "E"
       15 => X"0000E", -- "00001110" -- "F"
       16 to 63 => X"5A5A5"
        );

    signal raddr : std_logic_vector(ADDRW - 1 downto 0);
begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (en = '1') then
                raddr <= addr;
            end if;
        end if;
    end process;

    data <= ROM(conv_integer(raddr));

end syn;

