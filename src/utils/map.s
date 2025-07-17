.macro LoadMap mapTbl, namIdx, objTbl, objAmountTbl

  Addr_Set scene_map_ptr_jt, mapTbl, 1

  ; Print header
  jsr PrintHeader

  ; Load nametable
  lda namIdx
  sta nametable_idx
  PPU_Load_2x2_Screen NM0_LEVEL_OFFSET, #13, mapTbl
  ApplyObjectsToNametable objTbl, objAmountTbl
  PPU_LoadAttributes mapTbl, $23C8

  ; Cache map pointer
  lda nametable_idx
  asl
  tay
  lda (scene_map_ptr_jt), y
  sta map_ptr
  iny
  lda (scene_map_ptr_jt), y
  sta map_ptr+1
.endmacro