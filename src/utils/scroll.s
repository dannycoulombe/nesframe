; Set the scroll position
; Parameters:
; xPos - X position of the scroll
; yPos - Y position of the scroll
.scope Scroll
  .proc UpdatePosition
    PPU_ResetLatch
    lda scroll_x
    sta PPU_SCROLL                      ; Set X scroll
    lda scroll_y
    sta PPU_SCROLL                      ; Set Y scroll
    rts
  .endproc
.endscope
