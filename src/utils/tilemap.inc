; Check actor collision and return value
; of tile in register A
.macro Tilemap_GetAddressByXY xPos, yPos
  Push_ParamsBytes 2
  Set_ParamByte xPos, 0
  Set_ParamByte yPos, 1
  jsr Tilemap_GetAddressByXY
  Pull_ParamsBytes 2
.endmacro
.proc Tilemap_GetAddressByXY

  xPos = params_bytes+0
  yPos = params_bytes+1aaaaaaa

  ; Convert to multiple of 8s
  ; Nice way of converting numbers to a grid
  lda xPos
  and #%11111000
  sta xPos
  lda yPos
  and #%11111000
  sta yPos

  ; Handle Y position first (multiply by 32)
  lda yPos                              ; Get Y position
  lsr                                   ; Divide by 8 first (pixel to tile position)
  lsr
  lsr
  sta temp

  lda #0                                ; Initialize high byte
  sta temp+1

  ; Multiply by 32 (shift left 5 times)
  clc                                   ; Clear carry before shifts
  .repeat 5
  asl temp                              ; Shift 1 (×2)
  rol temp+1
  .endrepeat

  ; Now add X position
  clc
  lda xPos                              ; Get X position
  lsr                                   ; Divide by 8 (pixel to tile position)
  lsr
  lsr
  adc temp                              ; Add to low byte
  sta temp
  lda temp+1                            ; Get high byte
  adc #0                                ; Add carry if any
  clc
  adc #$20                              ; Add nametable base address
  sta temp+1

  rts
.endproc
