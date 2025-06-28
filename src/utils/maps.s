.macro LoadMap mapTbl, namIdx, objTbl

  Addr_Set scene_map_ptr_jt, mapTbl, 1

  ; Load nametable
  lda namIdx
  sta nametable_idx
  PPU_Load_2x2_Screen LEVEL_OFFSET, #13, mapTbl
  PPU_LoadAttributes mapTbl
  Object_ApplyToScreen objTbl

  ; Print header
  jsr PrintHeader
.endmacro