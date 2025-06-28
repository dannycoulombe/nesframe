SCROLL_SPEED = 8
SCROLL_DIR_UP = 2
SCROLL_DIR_RIGHT = 4
SCROLL_DIR_DOWN = 6
SCROLL_DIR_LEFT = 8
SCROLL_NAMESPACE_TOP = $1C
SCROLL_NAMESPACE_RIGHT = $F8
SCROLL_NAMESPACE_BOTTOM = $E7
SCROLL_NAMESPACE_LEFT = $08

.macro SCROLLING_SET direction
  lda direction
  sta scrolling_direction
  jmp ScrollingDo
.endmacro

ScrollingJumpTable:
  .word ScrollingCheckDirection
  .word ScrollingDoUp
  .word ScrollingDoRight
  .word ScrollingDoBottom
  .word ScrollingDoLeft

ScrollingCheck:

  ; ------------------------------------
  ; Jump to right pointer in jump table
  ldy scrolling_direction
  lda ScrollingJumpTable, y
  sta ptr
  lda ScrollingJumpTable+1, y
  sta ptr+1
  jmp (ptr)

  ; ------------------------------------
  ; Detect Scrolling
  ScrollingCheckDirection:
    ldy #0

    ; Check if up
    lda actor_array+ACTOR_Y, y
    clc
    adc scroll_y
    cmp #SCROLL_NAMESPACE_TOP
    bne :+
      SCROLLING_SET #SCROLL_DIR_UP
    :

    ; Check if right
    lda actor_array+ACTOR_X, y
    clc
    adc scroll_x
    cmp #SCROLL_NAMESPACE_RIGHT
    bne :+
      SCROLLING_SET #SCROLL_DIR_RIGHT
    :

    ; Check if bottom
    lda actor_array+ACTOR_Y, y
    clc
    adc scroll_y
    cmp #SCROLL_NAMESPACE_BOTTOM
    bne :+
      SCROLLING_SET #SCROLL_DIR_DOWN
    :

    ; Check if left
    lda actor_array+ACTOR_X, y
    clc
    adc scroll_x
    cmp #SCROLL_NAMESPACE_LEFT
    bne :+
      SCROLLING_SET #SCROLL_DIR_LEFT
    :

    jmp ScrollingCheckSkip

  ; ------------------------------------
  ; Do Scrolling
  ScrollingDo:
    tay
    lda ScrollingJumpTable, y
    sta ptr
    lda ScrollingJumpTable+1, y
    sta ptr+1
    jmp (ptr)

  ScrollingDoUp:
    lda scroll_y
    sec
    sbc #SCROLL_SPEED
    sta scroll_y
    cmp #$FC
    bne :+
      lda #$EC
      sta scroll_y
    :
    rts

  ScrollingDoRight:
    lda #SCROLL_SPEED
    clc
    adc scroll_x
    sta scroll_x

;    PPU_Load_2x2_Column
    rts

  ScrollingDoBottom:
    lda #SCROLL_SPEED
    clc
    adc scroll_y
    sta scroll_y
    cmp #240
    bne :+
      lda #0
      sta scroll_y
    :
    rts

  ScrollingDoLeft:
    lda scroll_x
    sec
    sbc #SCROLL_SPEED
    sta scroll_x
    rts

  ScrollingCheckSkip:

  rts
