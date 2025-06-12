; Log to Mesen debugger
; Parameters:
; value - Value to log
.macro Log value, index
  pha
  lda value
  .ifnblank index
  sta MESEN_LOG_ADDR+index
  .else
  sta MESEN_LOG_ADDR+1
  .endif
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
  .ifnblank index
  sta MESEN_LOG_ADDR+index
  .else
  sta MESEN_LOG_ADDR+0
  .endif
  pla
.endmacro

.macro LogY index
  pha
  tya
  .ifnblank index
  sta MESEN_LOG_ADDR+index
  .else
  sta MESEN_LOG_ADDR+0
  .endif
  pla
.endmacro

.macro LogA index
  .ifnblank index
  sta MESEN_LOG_ADDR+index
  .else
  sta MESEN_LOG_ADDR+0
  .endif
.endmacro

.macro LogInc index
  pha
  inc debug
  lda debug
  .ifnblank index
  sta MESEN_LOG_ADDR+index
  .else
  sta MESEN_LOG_ADDR+3
  .endif
  pla
.endmacro
