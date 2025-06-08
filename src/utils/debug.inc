; Log to Mesen debugger
; Parameters:
; value - Value to log
.macro Log value, index
  pha
  lda value
  sta MESEN_LOG_ADDR+index
  pla
.endmacro

.macro LogPtrY value, index
  pha
  lda (value),y
  sta MESEN_LOG_ADDR+index
  lda (value+1),y
  sta MESEN_LOG_ADDR+index+1
  pla
.endmacro
.macro LogPtrX value, index
  pha
  lda (value,x)
  sta MESEN_LOG_ADDR+index
  lda (value+1,x)
  sta MESEN_LOG_ADDR+index+1
  pla
.endmacro

.macro LogX index
  pha
  txa
  sta MESEN_LOG_ADDR+index
  pla
.endmacro
.macro LogY index
  pha
  tya
  sta MESEN_LOG_ADDR+index
  pla
.endmacro
.macro LogA index
  sta MESEN_LOG_ADDR+index
.endmacro
