; Z80 Test 8/12/2023 RB
org 0
  ld hl,ram_start   ;0100   21 00 80
; xor a             ;       af        a := 0
  ld  a, 55         ;0103   3e 37     a:=37h     
loop:
  ld  (hl),a        ;0105   77
  inc a             ;0106   3c
  inc hl            ;0107   23
  jr  loop          ;0108   18 fb     (jr $-3)

org 0x8000
ram_start:
  db  00

org 0x8400
top_of_stack:       ; SP is pre-incremented i.e. 87FF is first address push'd

gfx_ram:
