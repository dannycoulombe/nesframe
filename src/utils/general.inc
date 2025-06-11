.macro Set_Param_Byte value, index
  lda value
  sta params_bytes+index
.endmacro

.macro Set_Param_Label label, index
  lda #<label
  sta params_labels+(index * 2)
  lda #>label
  sta params_labels+(index * 2)+1
.endmacro

.macro MUL_A amount
  beq @MULAEnd
  stx temp
  tax
  lda #0
  @MULALoop:
    clc
    adc amount ; Add value to A
    dex       ; Decrement counter
    bne @MULALoop ; Branch if still positive
    ldx temp
  @MULAEnd:
.endmacro
