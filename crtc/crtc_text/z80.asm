;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Z80 Test 8/12/2023 RB
;-------------------------------
org 0
  di
  ld sp, l_stack_top

  jp l_entry

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RST 38 /INT handler
;-------------------------------
ds  0x0038-$
org 0x0038
  di
  exx                 ; exchanges BC, DE, and HL with shadow registers with BC', DE', and HL'.
  ex   af, af'        ; save AF, it's not part of the exx exchange

    in a, (0x84)
    out (0x82), a

    inc c
    ld  a, c
    out (0x80), a

    ; hl points to VRAM, is reloaded in NMI
    inc hl
    ld  (hl), a

rst38_out:
  exx                 ; restore BC, DE, and HL
  ex   af, af'        ; restore AF
  ei
  ret                 ; reti?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ds  0x0066-$
org 0x0066
;;=============================================================================
;; RST_66()
;;  Description:
;;   Input handler
;; IN:
;; OUT:
;;-----------------------------------------------------------------------------
    exx             ; exchanges BC, DE, and HL with shadow registers with BC', DE', and HL'.
    ex   af, af'    ; save AF, it's not part of the exx exchange

    ; restarts the VRAM pointer so we can see something happen on the screen
    ld hl, l_vram_start
    ld a, l
    add a, 10
    ld l, a

    exx
    ex   af, af'    ; restore AF

    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ds 0x0100-$
org 0x0100
l_entry:
   ; enable IRQ
   im  1 
   ei

  ld a, 0x3F
  ld hl, l_vram_start
  ld (hl), a
  exx                 ; stash vram address in HL for use during ISR


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


org 0x5000
l_in0_reg:
  db  00

org 0x8000
l_ram_start:
  db  00

org 0x8400
l_stack_top:          ; SP is pre-incremented i.e. 87FF is first address push'd

org 0x8800
l_vram_start:
