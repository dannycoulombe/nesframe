; Set a metasprite into OAM buffer
; Parameters:
; label - Label to read metasprite data from
; yPos - Position of the metasprite on the Y axis
; xPos - Position of the metasprite on the X axis
; addr - OAM buffer starting address
.macro Metasprite_Set label, xPos, yPos, addr

  Addr_Set sprite_ptr, addr             ; Copy address to sprite indirect pointer address
  Addr_Set ptr, label                   ; Copy label to indirect pointer address

  ldy #0
  lda (ptr),y                           ; Tile amount
  tax
  inc ptr
:
  clc
  sec

  ; Calculating X offset
  ldy #0
  lda xPos
  clc
  adc (ptr),y
  ldy #3
  sta (sprite_ptr),y

  ; Calculating Y offset
  ldy #1
  lda yPos
  clc
  adc (ptr),y
  ldy #0
  sta (sprite_ptr),y

  ; Set tile
  ldy #2
  lda (ptr),y
  ldy #1
  sta (sprite_ptr),y

  ; Set attributes
  ldy #3
  lda (ptr),y
  ldy #2
  sta (sprite_ptr),y

  ; Prepare pointer for next tile
  lda ptr
  clc
  adc #4
  sta ptr

  ; Prepare pointer for next tile
  lda sprite_ptr
  clc
  adc #4
  sta sprite_ptr

  dex
  bne :-
.endmacro
