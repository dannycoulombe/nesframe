; --------------------------------------
; Declaration
HEADER_MAGIC_TILE_FULL      = $F3
HEADER_MAGIC_TILE_HALF      = $F4
HEADER_MAGIC_TILE_EMPTY     = $F5
HEADER_HEART_TILE_FULL      = $F0
HEADER_HEART_TILE_HALF      = $F1
HEADER_HEART_TILE_EMPTY     = $F2
HEADER_KEY_TILE             = $EA
HEADER_PEBBLE_TILE          = $FB
HEADER_X_TILE               = $E9
HEADER_CONTAINER_TL_B_TILE  = $F6
HEADER_CONTAINER_TL_A_TILE  = $F8
HEADER_CONTAINER_BL_TILE    = $F9
HEADER_CONTAINER_TR_TILE    = $F7
HEADER_CONTAINER_BR_TILE    = $FA

; --------------------------------------
; Logic
.segment "CODE"

PrintLifeText:
  PrintText $2022, LifeTxt
  rts

PrintMagicText:
  PrintText $2042, MagicTxt
  rts

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
    lda #HEADER_MAGIC_TILE_FULL
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
    lda #HEADER_MAGIC_TILE_HALF
    sta PPU_DATA
  :

  ; Print empty bars(s)
  txa
  beq :++
  tay
  :
    lda #HEADER_MAGIC_TILE_EMPTY
    sta PPU_DATA
    dey
    tya
    bne :-
  :

  rts

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
    lda #HEADER_HEART_TILE_FULL
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
    lda #HEADER_HEART_TILE_HALF
    sta PPU_DATA
  :

  ; Print empty heart(s)
  txa
  beq :++
  tay
  :
    lda #HEADER_HEART_TILE_EMPTY
    sta PPU_DATA
    dey
    tya
    bne :-
  :

  rts

PrintKeys:
  PPU_Set_Addr $203C
  lda #HEADER_KEY_TILE
  sta PPU_DATA
  lda #HEADER_X_TILE
  sta PPU_DATA
  rts

PrintKeyDigit:
  PrintNumber $203E, total_keys
  rts

PrintPebbles:
  PPU_Set_Addr $205A
  lda #HEADER_PEBBLE_TILE
  sta PPU_DATA
  lda #HEADER_X_TILE
  sta PPU_DATA
  rts

PrintPebblesNumber:
  PrintNumber $205C, total_pebbles ; TODO
  PrintNumber $205D, total_pebbles ; TODO
  PrintNumber $205E, total_pebbles ; TODO
  rts

PrintItemContainerB:
  PPU_Set_Addr $2031
  lda #HEADER_CONTAINER_TL_B_TILE
  sta PPU_DATA
  PPU_Set_Addr $2051
  lda #HEADER_CONTAINER_BL_TILE
  sta PPU_DATA
  PPU_Set_Addr $2034
  lda #HEADER_CONTAINER_TR_TILE
  sta PPU_DATA
  PPU_Set_Addr $2054
  lda #HEADER_CONTAINER_BR_TILE
  sta PPU_DATA
  rts

PrintItemContainerA:
  PPU_Set_Addr $2035
  lda #HEADER_CONTAINER_TL_A_TILE
  sta PPU_DATA
  PPU_Set_Addr $2055
  lda #HEADER_CONTAINER_BL_TILE
  sta PPU_DATA
  PPU_Set_Addr $2038
  lda #HEADER_CONTAINER_TR_TILE
  sta PPU_DATA
  PPU_Set_Addr $2058
  lda #HEADER_CONTAINER_BR_TILE
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