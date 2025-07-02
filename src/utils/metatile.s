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