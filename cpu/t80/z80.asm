; Z80 Test 8/12/2023 RB
;
; Count by 2, each result stores in successive RAM address.
; Each memory address will be seen written twice.
; First increment in A then written to (HL)
; Second increment used 'inc (HL)' so the LD to A is not needed.
;
org 0
  di
  ld sp, l_stack_top

  jp l_entry

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RST 38 /INT handler
;   Exchange regs
;   Increment *(RAM_START + 1) and load result to A
;   Add some constant value to A
;   Store result to *(RAM_START)
;   Restore regs
;-------------------------------
ds  0x0038-$
org 0x0038
  di
  exx                 ; exchanges BC, DE, and HL with shadow registers with BC', DE', and HL'.
  ex   af, af'        ; save AF, it's not part of the exx exchange

  ld  hl, l_ram_start + 1
  inc (hl)
  ld  a, (hl)
  add a, 0x5A
  dec l
  ld  (hl), a

rst38_out:
  exx                 ; restore BC, DE, and HL
  ex   af, af'        ; restore AF
  ei
  ret                 ; reti?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ds 0x0100-$
org 0x0100
l_entry:
   ; enable IRQ
   im  1 
   ei

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

