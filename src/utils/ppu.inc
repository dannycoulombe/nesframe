; Set the PPU_ADDR to write to
; Parameters:
; addr - The PPU memory address to write to
.macro PPU_Set_Addr addr
    bit PPU_STATUS                      ; Reset PPU_ADDR latch
    lda #>addr                          ; Load high byte of address
    sta PPU_ADDR                        ; $2006
    lda #<addr                          ; Load low byte of address
    sta PPU_ADDR                        ; $2006
.endmacro

; Macro to write a single byte to PPU memory
; Parameters:
; addr - The PPU memory address to write to
; value - The value to write
.macro PPU_Write addr, value
    PPU_Set_Addr addr
    lda value                           ; Load the value
    sta PPU_DATA                        ; $2007
.endmacro

; Wait for the next VBlank
.macro PPU_Wait_VBlank
:
    bit PPU_STATUS
    bpl :-
.endmacro

; Wait for the next VBlank
.macro PPU_Disable_Rendering
    lda #0
    sta PPU_CTRL
    sta PPU_MASK
.endmacro

; Check docs/ppu_ctrl.md and docs/ppu_mask.md for parameter information
; Parameters:
; nmi - The PPU_CTRL nmi bit sequence
; mask - The PPU_MASK bit sequence
.macro PPU_Set_CtrlMask nmi, mask
    lda nmi
    sta PPU_CTRL                        ; Enable NMI
    lda mask
    sta PPU_MASK                        ; Set PPU_MASK bits to render the background
.endmacro

; Clear PPU nametable address with a given value
; Parameters:
; addr - The namestable address
; tileValue - The tile value to apply
; attrValue - The attribute value to apply
.macro PPU_Clear_Nametable addr, tileValue, attrValue
    PPU_Set_Addr addr

    ldy #4                              ; 4 loops of:

    ; Clear tiles
    lda tileValue
:
    ldx #$F0                            ; 240 tiles (4x = 960 bytes of tiles)
:
    sta PPU_DATA
    dex
    bne :-
    dey
    bne :--

    ; Clear attributes
    lda attrValue
    ldx #$40                            ; 64 bytes of attributes
:
    sta PPU_DATA
    dex
    bne :-
.endmacro

; Clear PPU background palette with given value
; Parameters:
; value - The value to apply
.macro PPU_Clear_Background_Palette value
    PPU_Set_Addr $3F00
    ldx #$A0                            ; 10 bytes
    lda value
:
    sta PPU_DATA
    dex
    bne :-
.endmacro

; Clear PPU sprite palette with given value
; Parameters:
; value - The value to apply
.macro PPU_Clear_Sprite_Palette value
    PPU_Set_Addr $3F10
    ldx #$A0                            ; 10 bytes
    lda value
:
    sta PPU_DATA
    dex
    bne :-
.endmacro

; Load a screen with all tiles and palettes into the PPU
; Parameters:
; label - Data label to load into the PPU
; addr - From a given address
.macro PPU_Load_Screen mapLabel, paletteLabel

    Addr_Set ptr, mapLabel, 1           ; Copy label to indirect pointer address
    PPU_Set_Addr $2000                  ; Set PPU to given address

    ldx #4                              ; 4 rows of 255 bytes
:   ldy #0                              ; Start from 0 (to 255)
:
    lda (ptr),y                         ; Load byte at X index
    sta PPU_DATA                        ; Push loaded byte to PPU

    iny
    bne :-                              ; Loop until X wraps to 0
    inc ptr+1                           ; Increment high byte of address
    dex
    bne :--                             ; Loop for all 4 pages

    ; Load background palette
    PPU_Load_Palette paletteLabel, $3F00, #16
.endmacro

; Load a palette of of colors from a given address
; Parameters:
; label - The label address to read the color from
; addr - The PPU address to write to
; amount - The amount of bytes to read/write
.macro PPU_Load_Palette label, addr, amount
    PPU_Set_Addr addr                   ; Set PPU to given address

    ldx #0                              ; Index for palette bytes
:
    lda label, x                         ; Load byte from your binary data
    sta PPU_DATA                        ; Write byte to PPU
    inx
    cpx amount                          ; 16 background palette bytes
    bne :-
.endmacro

; Set sprite data into OAM buffer
; Parameters:
; addr - Start address (normally $0200)
; xPos - Position of the sprite on the X axis
; yPos - Position of the sprite on the Y axis
; tite - Tile hexadecimal
; attr - Tile attributes
.macro PPU_Set_Sprite addr, xPos, yPos, tile, attr
    lda xPos
    sta addr+3
    lda yPos
    sta addr
    lda tile
    sta addr+1
    lda attr
    sta addr+2
.endmacro
