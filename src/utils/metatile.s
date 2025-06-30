.macro SetMetatile addr, metatile, palette

  PPU_Set_Addr addr, 1

  ldx metatile
  lda Metatiles2x2Data, x
  sta PPU_DATA
  inx
  lda Metatiles2x2Data, x
  sta PPU_DATA

  PPU_Set_Addr (addr + $20), 1

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