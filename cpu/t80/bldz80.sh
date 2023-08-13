#!/bin/bash

TEST_ASM="./test.asm"
echo z80asm $TEST_ASM

z80asm $TEST_ASM

#./t80_comp_vga.srcs/sources_1/new/roms_1.vhd
od -v  -t x1 a.bin | cut -c 9- | tr '\ ' '\n' > ./t80_comp_vga.srcs/sources_1/new/z80test_hex.dat

z80dasm  -t a.bin | head -n10


# hex2rom -b  a.bin  prog_rom 6l8a # array
# hex2rom -b  a.bin  prog_rom 6l8s # synchronized

