; Set the PPU_ADDR to write to
; Parameters:
; addr - The PPU memory address to write to
.macro PPU_Set_Addr addr, latch, fromVar
  .ifblank latch
    bit PPU_STATUS                      ; Reset PPU_ADDR latch
  .endif
  .ifblank fromVar
    lda #>addr                          ; Load high byte of address
    sta PPU_ADDR                        ; $2006
    lda #<addr                          ; Load low byte of address
    sta PPU_ADDR                        ; $2006
  .else
    lda addr+1                          ; Load high byte of address
    sta PPU_ADDR                        ; $2006
    lda addr                            ; Load low byte of address
    sta PPU_ADDR                        ; $2006
  .endif
.endmacro

; Macro to write a single byte to PPU memory
; Parameters:
; addr - The PPU memory address to write to
; value - The value to write
.macro PPU_Write addr, value
  PPU_Set_Addr addr
  lda value                             ; Load the value
  sta PPU_DATA                          ; $2007
.endmacro

; Wait for the next VBlank
.macro PPU_Wait_VBlank
:
  bit PPU_STATUS
  bpl :-
.endmacro

; Check docs/ppu_ctrl.md and docs/ppu_mask.md for parameter information
; Parameters:
; nmi - The PPU_CTRL nmi bit sequence
; mask - The PPU_MASK bit sequence
.macro PPU_Set_CtrlMask nmi, mask
  lda nmi
  sta PPU_CTRL                          ; Enable NMI
  lda mask
  sta PPU_MASK                          ; Set PPU_MASK bits to render the background
.endmacro

; Clear PPU nametable address with a given value
; Parameters:
; addr - The namestable address
; tileValue - The tile value to apply
; attrValue - The attribute value to apply
.macro PPU_Clear_Nametable addr, tileValue, attrValue
  PPU_Set_Addr addr

  ldy #4                                ; 4 loops of:

  ; Clear tiles
  lda tileValue
:
  ldx #$F0                              ; 240 tiles (4x = 960 bytes of tiles)
:
  sta PPU_DATA
  dex
  bne :-
  dey
  bne :--

  ; Clear attributes
  lda attrValue
  ldx #$40                              ; 64 bytes of attributes
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
  ldx #$A0                              ; 10 bytes
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
  ldx #$A0                              ; 10 bytes
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
.macro PPU_Load_1x1_Screen mapLabel, paletteLabel

  Addr_Set ptr, mapLabel, 1             ; Copy label to indirect pointer address
  PPU_Set_Addr $2000                    ; Set PPU to given address

  ldx #4                                ; 4 rows of 255 bytes
: ldy #0                                ; Start from 0 (to 255)
:
  lda (ptr),y                           ; Load byte at X index
  sta PPU_DATA                          ; Push loaded byte to PPU

  iny
  bne :-                                ; Loop until X wraps to 0
  inc ptr+1                             ; Increment high byte of address
  dex
  bne :--                               ; Loop for all 4 pages

  ; Load background palette
  PPU_LoadPalette paletteLabel, $3F00, #16
.endmacro

; Load correct nametable
.macro PPU_SetMapPtr ptr, mapTable
  lda nametable_idx                     ; Load index
  asl                                   ; Multiply index by 2 (word size)
  tax                                   ; Use X as offset
  lda mapTable, x                        ; Load low byte of pointer
  sta ptr
  lda mapTable+1, x                      ; Load high byte of pointer
  sta ptr+1
.endmacro

; Load a screen of 2x2 metatiles into the PPU
.macro PPU_Load_2x2_Screen fromPPUAddress, totalRows, mapTable

  PPU_SetMapPtr ptr, mapTable
  PPU_Set_Addr fromPPUAddress           ; Set PPU to given address

  lda totalRows
  sta temp
  ldy #0

  ; First row (under 16)
  @loop2x2FirstRow:
    lda (ptr),y                         ; Load byte at X index
    tax

    lda Metatiles2x2Data, x
    sta PPU_DATA
    inx
    lda Metatiles2x2Data, x
    sta PPU_DATA

    ; If haven't hit 16 yet (end of line) continue with first row
    iny
    cpy #16
    bcc @loop2x2FirstRow
    tya
    sec
    sbc #16
    tay

  ; Second row (over 16)
  @loop2x2SecondRow:
    lda (ptr),y                         ; Load byte at X index
    tax

    inx                                 ; Get byte index 2 and 3
    inx
    lda Metatiles2x2Data, x
    sta PPU_DATA
    inx
    lda Metatiles2x2Data, x
    sta PPU_DATA

    ; If hit 32 (end of line) reset register Y
    iny
    cpy #16
    bne @loop2x2SecondRow
    dec temp
    beq @loop2x2End
    ldy #0

    ; Move pointer to next 16 tiles
    clc
    lda ptr
    adc #16
    sta ptr
    lda ptr+1                           ; Handle carry to high byte
    adc #0
    sta ptr+1

    jmp @loop2x2FirstRow

  @loop2x2End:
.endmacro

.macro PPU_LoadHeader

.endmacro

; Expensive in CPU, but hey.. saves a lot of bytes!
; If stage has 16 nametables, it's 48 bytes x 16 ~ 768 bytes
; So if 8 levels ~ 6.1k and if you include an overworld of
; let's say 16x8, that would be another 6.1k for a total of
; 12k saved.
.macro PPU_LoadAttributes mapTable

  PPU_Set_Addr $23C8
  PPU_SetMapPtr ptr, mapTable

  ldx #48
  ldy #0
  @PPU_LoadAttributes_Loop:
    txa
    pha

    lda #0
    sta temp

    lda (ptr), y
    tax
    lda Metatiles2x2Prop+1, x
    ora temp
    sta temp

    iny
    lda (ptr), y
    tax
    lda Metatiles2x2Prop+1, x
    asl
    asl
    ora temp
    sta temp

    tya
    clc
    adc #15
    tay
    lda (ptr), y
    tax
    lda Metatiles2x2Prop+1, x
    asl
    asl
    asl
    asl
    ora temp
    sta temp

    iny
    lda (ptr), y
    tax
    lda Metatiles2x2Prop+1, x
    asl
    asl
    asl
    asl
    asl
    asl
    ora temp
    sta temp

    lda temp
    sta PPU_DATA

    iny
    tya
    and #MOD_32
    beq :+
      tya
      sec
      sbc #16
      tay
    :

    pla
    tax
    dex
    bne @PPU_LoadAttributes_Loop
.endmacro

.macro PPU_Load_2x2_Column nametableIdx

.endmacro

; Load a palette of of colors from a given address
; Parameters:
; label - The label address to read the color from
; addr - The PPU address to write to
; amount - The amount of bytes to read/write
.macro PPU_LoadPalette label, addr, amount
  PPU_Set_Addr addr                     ; Set PPU to given address

  ldx #0                                ; Index for palette bytes
:
  lda label, x                          ; Load byte from your binary data
  sta PPU_DATA                          ; Write byte to PPU
  inx
  cpx amount                            ; 16 background palette bytes
  bne :-
.endmacro

; Set sprite data into OAM buffer
; Parameters:
; addr - Start address (normally $0200)
; xPos - Position of the sprite on the X axis
; yPos - Position of the sprite on the Y axis
; tite - Tile hexadecimal
; attr - Tile attributes
.macro PPU_SetSprite addr, xPos, yPos, tile, attr
  lda xPos
  sta addr+3
  lda yPos
  sta addr
  lda tile
  sta addr+1
  lda attr
  sta addr+2
.endmacro

.macro PPU_GetTileIdx addr
  bit PPU_ADDR
  lda addr+1                            ; Load high byte of address
  sta PPU_ADDR                          ; $2006
  lda addr                              ; Load low byte of address
  sta PPU_ADDR                          ; $2006
  lda PPU_DATA
  lda PPU_DATA
.endmacro

.scope PPU
  .proc EnableRendering
    PPU_Set_CtrlMask #%10001000, #%00011110
    rts
  .endproc

  ; Wait for the next VBlank
  .proc DisableRendering
    lda #0
    sta PPU_CTRL
    sta PPU_MASK
  .endproc
.endscope

.macro LDA_GetPPUAddrFromTileIdx tileIdx

.endmacro

.macro PPU_UpdateMetatile tileIdx, metatile

.endmacro