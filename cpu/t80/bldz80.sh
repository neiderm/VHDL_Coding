#!/bin/bash

TEST_ASM="./z80.asm"
echo z80asm $TEST_ASM

z80asm $TEST_ASM

# Old example, dump binary to file, massage it into hex for loading from VHDL code
# od -v  -t x1 a.bin | cut -c 9- | tr '\ ' '\n' > ./t80_comp_vga.srcs/sources_1/new/z80test_hex.dat

z80dasm -t a.bin

# array (not synchronized)
hex2rom -b a.bin prog_rom 6l8a

# synchronized
echo "hex2rom -b a.bin prog_rom 6l8s  | tee ./t80_sim/t80_vga.srcs/sources_1/new/prog_rom.vhd"

