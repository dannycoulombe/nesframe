.segment "RODATA"
LifeTxt: .byte "LIFE", 0
MagicTxt: .byte "MAGIC", 0

.segment "CODE"
PrintLifeText:
  PrintText $2022, LifeTxt
  rts

PrintMagicText:
  PrintText $2042, MagicTxt
  rts

; Full: D7
; Half: D8
; Empty: D9
PrintMagicBars:
  PPU_Set_Addr $2048

  ldx player_magic_slot

  ; Print full bars
  ; Divide magic by 2 (one full heart)
  lda player_magic
  lsr
  tay
  beq :++
  :
    lda #$D7
    sta PPU_DATA
    dex
    dey
    tya
    bne :-
  :

  ; Print half bar
  ; Keep remaining value of division (half bar?)
  lda player_magic
  and #%00000001
  tay
  beq :+
    dex
    lda #$D8
    sta PPU_DATA
  :

  ; Print empty bars(s)
  txa
  beq :++
  tay
  :
    lda #$D9
    sta PPU_DATA
    dey
    tya
    bne :-
  :

  rts

; Full: C0
; Half: C1
; Empty: C2
PrintHearts:
  PPU_Set_Addr $2028

  ldx player_hearths

  ; Print full hearts
  ; Divide health by 2 (one full heart)
  lda player_health
  lsr
  tay
  beq :++
  :
    lda #$C0
    sta PPU_DATA
    dex
    dey
    tya
    bne :-
  :

  ; Print half heart
  ; Keep remaining value of division (half heart?)
  lda player_health
  and #%00000001
  tay
  beq :+
    dex
    lda #$C1
    sta PPU_DATA
  :

  ; Print empty heart(s)
  txa
  beq :++
  tay
  :
    lda #$C2
    sta PPU_DATA
    dey
    tya
    bne :-
  :

  rts

PrintKeys:
  PPU_Set_Addr $203C
  lda #$C4
  sta PPU_DATA
  lda #$C3
  sta PPU_DATA
  rts

PrintKeyDigit:
  PrintNumber $203E, total_keys
  rts

PrintPebbles:
  PPU_Set_Addr $205A
  lda #$C8
  sta PPU_DATA
  lda #$C3
  sta PPU_DATA
  rts

PrintPebblesNumber:
  PrintNumber $205C, total_pebbles ; TODO
  PrintNumber $205D, total_pebbles ; TODO
  PrintNumber $205E, total_pebbles ; TODO
  rts

PrintItemContainerB:
  PPU_Set_Addr $2031
  lda #$C5
  sta PPU_DATA
  PPU_Set_Addr $2051
  lda #$D5
  sta PPU_DATA
  PPU_Set_Addr $2034
  lda #$C6
  sta PPU_DATA
  PPU_Set_Addr $2054
  lda #$D6
  sta PPU_DATA
  rts

PrintItemContainerA:
  PPU_Set_Addr $2035
  lda #$C7
  sta PPU_DATA
  PPU_Set_Addr $2055
  lda #$D5
  sta PPU_DATA
  PPU_Set_Addr $2038
  lda #$C6
  sta PPU_DATA
  PPU_Set_Addr $2058
  lda #$D6
  sta PPU_DATA
  rts

SetAttributes:
  PPU_Set_Addr $23C0

  ; Life/Hearts
  lda #%00000000
  sta PPU_DATA
  sta PPU_DATA
  lda #%00000101
  sta PPU_DATA
  sta PPU_DATA

  ; Containers
  lda #%00000000
  sta PPU_DATA
  sta PPU_DATA
  lda #%11000000
  sta PPU_DATA
  lda #%00000011
  sta PPU_DATA
  rts

PrintHeader:
  jsr PrintMagicText
  jsr PrintMagicBars
  jsr PrintLifeText
  jsr PrintHearts
  jsr PrintKeys
  jsr PrintKeyDigit
  jsr PrintItemContainerB
  jsr PrintItemContainerA
  jsr PrintPebbles
  jsr PrintPebblesNumber
  jsr SetAttributes
  rts

HeaderNMICallback:
  lda header_state
  and #HEADER_STATE_HEARTHS
  beq :+
    lda header_state
    and #<~HEADER_STATE_HEARTHS
    sta header_state
    jsr PrintHearts
  :

  rts