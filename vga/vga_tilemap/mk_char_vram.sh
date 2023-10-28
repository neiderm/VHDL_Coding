#!/bin/bash
#
#  Tilemap tester (10/2023 Red~Bote)
#
#  Create test patterns in simulated character tile VRAM using zx80 set (64 characters)
#    </dev/zero head -c 80 | tr '\0' '\46' > tempvram.bin  # \46 == 0x26 == 38 == A
#  Use hex2rom (from t80 vhdl distribution) to convert binary data to a VHDL RAM/ROM entity:
#    hex2rom -b tempvram.bin char_vram 9l8s > vga_chargen.srcs/sources_1/new/char_vram.vhd 
#  8x8 tile character sets with various encodings:
#    https://github.com/mobluse/chargen-maker.git
#    \46 == 0x26 == 38 == A
#    \76 == 0x3E == 62 == Y   (useful for testing Hsync synchronization with left-most column)

# Note: there is an IMG_OFFSET generic in the VHDL code to specify the BMP header offset.
#       Use IMG_OFFSET => 0 for "raw" data from this generator script! 
#    u_vram_addr : entity work.vram_addresser
#    generic map(
#        IMG_OFFSET => 218 --set this to header size if generated from .BMP image

  </dev/zero head -c 2 | tr '\0' '\76' > tempvram.bin  # '>' overwrites file!
  </dev/zero head -c 2 | tr '\0' '\46' >> tempvram.bin

#  </dev/zero head -c 2 | tr '\0' '\30' >> tempvram.bin
#  </dev/zero head -c 2 | tr '\0' '\31' >> tempvram.bin
#  </dev/zero head -c 2 | tr '\0' '\32' >> tempvram.bin
#  </dev/zero head -c 2 | tr '\0' '\33' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\34' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\35' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\36' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\37' >> tempvram.bin

  </dev/zero head -c 2 | tr '\0' '\40' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\41' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\42' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\43' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\44' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\45' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\46' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\47' >> tempvram.bin

  </dev/zero head -c 2 | tr '\0' '\50' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\51' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\52' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\53' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\54' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\55' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\56' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\57' >> tempvram.bin

  </dev/zero head -c 2 | tr '\0' '\60' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\61' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\62' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\63' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\64' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\65' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\66' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\67' >> tempvram.bin

  </dev/zero head -c 2 | tr '\0' '\70' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\71' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\72' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\73' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\74' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\75' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\76' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\77' >> tempvram.bin

  </dev/zero head -c 2 | tr '\0' '\06' >> tempvram.bin
  </dev/zero head -c 2 | tr '\0' '\02' >> tempvram.bin

  INF="tempvram.bin"

  OUTF="vga_tilemap.srcs/sources_1/imports/vga/char_vram.vhd"

  echo "Overwrite $OUTF? (y)"

  read AAA
  [ "$AAA" = "y" ] &&  echo "OK overwriting" &&
    hex2rom  -b tempvram.bin  char_vram 14l8s  > $OUTF

  ls -l $OUTF

  # end


