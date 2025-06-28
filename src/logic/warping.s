WARP_SPEED = 8
WARP_DIR_UP = 2
WARP_DIR_RIGHT = 4
WARP_DIR_DOWN = 6
WARP_DIR_LEFT = 8
WARP_NAMESPACE_TOP = $1C
WARP_NAMESPACE_RIGHT = $F8
WARP_NAMESPACE_BOTTOM = $E7
WARP_NAMESPACE_LEFT = $08

.macro WARPING_SET direction
  lda direction
  sta warping_direction
  jmp WarpingDo
.endmacro

WarpingJumpTable:
  .word WarpingCheckDirection
  .word WarpingDoUp
  .word WarpingDoRight
  .word WarpingDoBottom
  .word WarpingDoLeft

WarpingCheck:

  ; ------------------------------------
  ; Jump to right pointer in jump table
  ldy warping_direction
  lda WarpingJumpTable, y
  sta ptr
  lda WarpingJumpTable+1, y
  sta ptr+1
  jmp (ptr)

  ; ------------------------------------
  ; Detect warping
  WarpingCheckDirection:
    ldy #0

    ; Check if up
    lda actor_array+ACTOR_Y, y
    clc
    adc scroll_y
    cmp #WARP_NAMESPACE_TOP
    bne :+
      WARPING_SET #WARP_DIR_UP
    :

    ; Check if right
    lda actor_array+ACTOR_X, y
    clc
    adc scroll_x
    cmp #WARP_NAMESPACE_RIGHT
    bne :+
      WARPING_SET #WARP_DIR_RIGHT
    :

    ; Check if bottom
    lda actor_array+ACTOR_Y, y
    clc
    adc scroll_y
    cmp #WARP_NAMESPACE_BOTTOM
    bne :+
      WARPING_SET #WARP_DIR_DOWN
    :

    ; Check if left
    lda actor_array+ACTOR_X, y
    clc
    adc scroll_x
    cmp #WARP_NAMESPACE_LEFT
    bne :+
      WARPING_SET #WARP_DIR_LEFT
    :

    jmp WarpingCheckSkip

  ; ------------------------------------
  ; Do warping
  WarpingDo:
    tay
    lda WarpingJumpTable, y
    sta ptr
    lda WarpingJumpTable+1, y
    sta ptr+1
    jmp (ptr)

  WarpingDoUp:
    lda scroll_y
    sec
    sbc #WARP_SPEED
    sta scroll_y
    cmp #$FC
    bne :+
      lda #$EC
      sta scroll_y
    :
    rts

  WarpingDoRight:
    lda #WARP_SPEED
    clc
    adc scroll_x
    sta scroll_x

;    PPU_Load_2x2_Column
    rts

  WarpingDoBottom:
    lda #WARP_SPEED
    clc
    adc scroll_y
    sta scroll_y
    cmp #240
    bne :+
      lda #0
      sta scroll_y
    :
    rts

  WarpingDoLeft:
    lda scroll_x
    sec
    sbc #WARP_SPEED
    sta scroll_x
    rts

  WarpingCheckSkip:

  rts
