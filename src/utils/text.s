; $B9 is space
.macro PrintText ppuAddr, textLabel
  PPU_Set_Addr ppuAddr
  ldy #0
:
  lda textLabel, y
  beq :+
  sta PPU_DATA
  iny
  bne :-
  :
.endmacro

; A single digit
.macro PrintDigit ppuAddr, digit
  PPU_Set_Addr ppuAddr
  lda digit
  clc
  adc #$C0
  sta PPU_DATA
.endmacro

; A large number
.macro PrintNumber ppuAddr, number
  PPU_Set_Addr ppuAddr
  lda number
  clc
  adc #$C0
  sta PPU_DATA
.endmacro
