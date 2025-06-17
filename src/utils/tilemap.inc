.macro Tilemap_GetTilePropByXY xPos, yPos
  Push_ParamsBytes 2
  Set_ParamByte xPos, 0
  Set_ParamByte yPos, 1
  jsr Tilemap_GetTilePropByXY
  Pull_ParamsBytes 2
.endmacro
.proc Tilemap_GetTilePropByXY
  xPos = params_bytes+0
  yPos = params_bytes+1

  ; Compute Y Pos
  lda yPos                              ; Get Y coordinate
  and #%11111000
  lsr                                   ; Divide by 8 first (pixel to tile position)
  lsr
  lsr
  asl                                   ; Multiply by
  asl                                   ; Y * 4
  asl                                   ; Y * 8
  sta temp                              ; Store Y*8 in temp

  ; Compute X pos
  lda xPos                              ; Get X coordinate
  and #%11111000
  lsr                                   ; Divide by 16 first (pixel to tile position)
  lsr
  lsr
  lsr
  clc
  adc temp                              ; Add Y*8 to X to get final offset

  ; Fetch tile index
;  tay
;  lda scene_nametable_label, y

  rts
.endproc
