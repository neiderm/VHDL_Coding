 --
-- Initializing Block RAM from external data file
--
-- Download: ftp://ftp.xilinx.com/pub/documentation/misc/xstug_examples.zip
-- File: HDL_Coding_Techniques/rams/rams_2oc.vhd
-- Ref: https://vhdlwhiz.com/read-bmp-file/
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity bmp_loader is
    generic (
        FileName : string := "rgb.bmp.dat";
        imgRow0  : integer := 120;
        imgCol0  : integer := 240;
        VGA_BITS : integer := 12  -- VGA bus width
    );
    port (
        clk     : in std_logic;
        row_in  : in integer;
        col_in  : in integer;
        dout    : out std_logic_vector(VGA_BITS-1 downto 0)
    );
end bmp_loader;

architecture syn of bmp_loader is
    --
    -- (1) load bitmap header
    --
    subtype byte_type is std_logic_vector(7 downto 0);
    type header_type is array (0 to 53) of byte_type;

    type bmp_info_type is record
        width  : integer;
        height : integer;
    end record;

    impure function ReadHeaderFromFile (RamFileName : in string) return bmp_info_type is
        file bmp_file        : text;
        variable RamFileLine : line;
        variable bmp_dims    : bmp_info_type;
        variable header      : header_type;
        variable read_index  : integer := 0;
    begin
        file_open(bmp_file, RamFileName, read_mode); -- todo error handling?

        -- read header from file
        for i in header_type'range loop
            readline (bmp_file, RamFileLine);
            hread (RamFileLine, header(i)); -- requires VHDL 2008
        end loop;

        file_close(bmp_file);

        -- extract image dimensions
        bmp_dims.width := to_integer(unsigned(header(18))) + 
                          to_integer(unsigned(header(19))) * 2 ** 8 + 
                          to_integer(unsigned(header(20))) * 2 ** 16 + 
                          to_integer(unsigned(header(21))) * 2 ** 24;
        bmp_dims.height := to_integer(unsigned(header(22))) + 
                           to_integer(unsigned(header(23))) * 2 ** 8 + 
                           to_integer(unsigned(header(24))) * 2 ** 16 + 
                           to_integer(unsigned(header(25))) * 2 ** 24;
        return bmp_dims;
    end function;
    --
    -- (2) load image data
    --
    constant bmp_hdr : bmp_info_type := ReadHeaderFromFile(FileName);

    constant bmp_img_sz : integer := bmp_hdr.height * bmp_hdr.width;

    -- byte buffer for input from bitmap image data section in file
    -- size is image size +1 to allow newline reading to end of file
    type bmp_img_dat_type is array (0 to bmp_img_sz * 3) of byte_type;

    subtype rgb444_type is std_logic_vector(VGA_BITS-1 downto 0);
    type rgb_data_type is array (0 to bmp_img_sz - 1) of rgb444_type;

    type bmp_type is record
        dimensions : bmp_info_type;
        pixel_data : rgb_data_type;
    end record;

    impure function InitRamFromFile (RamFileName : in string) return bmp_type is
        file     bmp_file     : text;
        variable RamFileLine  : line;
        variable pix_data_buf : bmp_img_dat_type; -- temp byte buffer to read in bmp image data
        variable read_index   : integer;
        variable bmp_data     : bmp_type;  -- object returned from function
    begin
        file_open(bmp_file, RamFileName, read_mode);

        -- read BMP header from file (only needed to skip over header to image data)
        for i in header_type'range loop
            readline (bmp_file, RamFileLine);
        end loop;

        bmp_data.dimensions.width := bmp_hdr.width;
        bmp_data.dimensions.height := bmp_hdr.height;

        -- read RGB image data from file
        read_index := 0;

        while(not ENDFILE(bmp_file)) loop  -- note readline called past the end of file
            readline (bmp_file, RamFileLine);
            hread (RamFileLine, pix_data_buf(read_index));  -- read into tmp rgb byte buffer
            read_index := read_index + 1;
        end loop;

        file_close(bmp_file);

        -- convert rgb888 to rgb444 (VGA_BITS=12)
        for read_index in rgb_data_type'range loop
            bmp_data.pixel_data(read_index)(11 downto 8) := pix_data_buf(read_index * 3 + 2)(7 downto 4);
            bmp_data.pixel_data(read_index)(7 downto 4)  := pix_data_buf(read_index * 3 + 1)(7 downto 4);
            bmp_data.pixel_data(read_index)(3 downto 0)  := pix_data_buf(read_index * 3 + 0)(7 downto 4);
        end loop;

        return bmp_data;
    end function;

    -- read bitmap file into image ram
    constant bmp_dat : bmp_type := InitRamFromFile(FileName);

begin
    process (clk)
        variable addri: integer; -- variable to simplify expression
    begin
        if (clk'EVENT and clk = '1') then
            if (row_in >= imgRow0) and (row_in < (imgRow0 + bmp_hdr.height)) and
               (col_in >= imgCol0) and (col_in < (imgCol0 + bmp_hdr.width))
            then
                addri := (row_in - imgRow0) * bmp_hdr.width + (col_in - imgCol0);
                dout <= bmp_dat.pixel_data(addri);
            end if;
        end if;
    end process;

end syn;
