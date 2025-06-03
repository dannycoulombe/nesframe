; Set the scroll position
; Parameters:
; xPos - X position of the scroll
; yPos - Y position of the scroll
.macro Scroll_Set_Position xPos, yPos
    lda xPos
    sta PPU_SCROLL                      ; Set X scroll
    lda yPos
    sta PPU_SCROLL                      ; Set Y scroll
.endmacro
