.macro SetMetatile addr, metatile, palette, fromVar

  PPU_Set_Addr addr, 0, fromVar

  ldx metatile
  lda Metatiles2x2Data, x
  sta PPU_DATA
  inx
  lda Metatiles2x2Data, x
  sta PPU_DATA

  .ifblank fromVar
    PPU_Set_Addr (addr + $20), 0, fromVar
  .else
    lda addr
    clc
    adc #$20
    sta addr
    PPU_Set_Addr addr, 0, fromVar
  .endif

  inx
  lda Metatiles2x2Data, x
  sta PPU_DATA
  inx
  lda Metatiles2x2Data, x
  sta PPU_DATA

  ;.ifnblank palette
  ;  PPU_Set_Addr $23E6
  ;  lda palette
  ;  sta PPU_DATA
  ;.endif

.endmacro

.proc GetMetatileIdx

  ; Compute Y Pos
  tya
  and #%11110000
  sta temp

  ; Compute X pos
  txa
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  clc
  adc temp                              ; Add Y*8 to X to get final offset
.endproc