; Z80 Test 8/12/2023 RB
;
; Count by 2, each result stores in successive RAM address.
; Each memory address will be seen written twice.
; First increment in A then written to (HL)
; Second increment used 'inc (HL)' so the LD to A is not needed.
;
org 0
  ld hl, l_ram_start  ;0100   21 00 80

  xor a               ; a=0
  ld  (hl), a         ; *($8000) = 0

l_loop:

  inc a               ; A=0+1
  inc l               ; L==1

  ld  (hl), a         ; *($8001) = 1
  inc (hl)            ; *($8002) = 1+1

  ld  a, (hl)         ; A=2

  jr  l_loop

org 0x8000
l_ram_start:
  db  00

org 0x8400
l_stack_top:          ; SP is pre-incremented i.e. 87FF is first address push'd

gfx_ram:

