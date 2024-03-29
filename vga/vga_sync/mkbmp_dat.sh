#!/bin/bash

RGB_BIN="./rgb.bmp"

RGB_OUT="./soc_t80_vga.srcs/sources_1/imports/rams/rgb.bmp.dat"
RGB_OUT="./vga_sync.srcs/sources_1/imports/rams/rgb.bmp.dat"
RGB_OUT="./vga_sync.srcs/sources_1/new/rgb.bmp.dat"

if [[ -z  "$1" ]]
then
   echo "Defaulting output to $RGB_OUT"
elif [[ ! -f  "$1" ]]
then
  echo "$1 notta file, bye!"
else
  RGB_BIN="$1"
fi


echo  "$RGB_BIN -> $RGB_OUT"

RGB_CONV=rgb.tmp.bmp
convert $RGB_BIN -flip $RGB_CONV

RGB_CONV=$RGB_BIN  # tmp ... IM is changing bitmap layout PC bitmap, Windows 98/2000 and newer format

od -v  -t x1 $RGB_CONV | cut -c 9- | tr '\ ' '\n' > $RGB_OUT

ls -l $RGB_OUT

