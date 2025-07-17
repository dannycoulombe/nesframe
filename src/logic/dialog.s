; --------------------------------------
; Declarations
DIALOG_TL_CORNER = $0D
DIALOG_TOP = $0E
DIALOG_TR_CORNER = $0F
DIALOG_RIGHT = $1F
DIALOG_BR_CORNER = $2F
DIALOG_BOTTOM = $2E
DIALOG_BL_CORNER = $2D
DIALOG_LEFT = $1D
DIALOG_INNER = $00

; --------------------------------------
; Variables
.segment "ZEROPAGE"
dialog_ppu_addr:      .word 0

.segment "RAM"
dialog_width:         .byte 0
dialog_height:        .byte 0
dialog_x:             .byte 0
dialog_y:             .byte 0
dialog_nl_offset:     .byte 0           ; Amount of tiles for next line to start printing (from right overflowing to left)

; --------------------------------------
; Logic
.segment "CODE"

.macro OpenDialogMiddle width, height
  ldx width
  ldy height
  jsr OpenDialogMiddle
.endmacro
.proc OpenDialogMiddle

  ; Keep size in memory
  stx dialog_width
  sty dialog_height

  ; Calculate the right to left overflowing size
  lda #16
  sec
  sbc dialog_width
  asl
  sta dialog_nl_offset

  ; Calculate X top-left position
  txa
  lsr
  sta temp
  lda #8                                ; Half of screen in metatiles
  sec
  sbc temp
  tax
  sta dialog_x

  ; Calculate Y top-left position
  tya
  lsr
  sta temp
  lda #8                                ; Half of screen in metatiles
  sec
  sbc temp
  tay
  sta dialog_y

  ; Get the PPU_ADDR to print tiles to
  jsr GetMetatilePPUAddr                ; temp variable
  lda temp
  sta dialog_ppu_addr
  lda temp+1
  sta dialog_ppu_addr+1

  ; Tell NMI to update the tiles
  OnceDuringNMI PrintDialog

  rts
.endproc

.proc PrintDialog
  PPU_Set_Addr dialog_ppu_addr, 0, 1

  ; Top-left corner
  lda #DIALOG_TL_CORNER
  sta PPU_DATA

  ; Top lines
  lda dialog_width
  asl
  sec
  sbc #2
  tax
  lda #DIALOG_TOP
  @PrintTopLines:
    sta PPU_DATA
    dex
    bne @PrintTopLines

  ; Top-right corner
  lda #DIALOG_TR_CORNER
  sta PPU_DATA

  ; Calculate the amount of horizontal inner tiles
  lda dialog_height
  asl
  sec
  sbc #2
  tay
  @PrintLine:

    ; Left
    jsr PushDialogPPUAddrToNextLine
    lda #DIALOG_LEFT
    sta PPU_DATA

    ; Empty tiles
    lda dialog_width
    asl
    sec
    sbc #2
    tax
    lda #DIALOG_INNER
    @PrintEmptyTiles:
      sta PPU_DATA
      dex
      bne @PrintEmptyTiles

    ; Right
    lda #DIALOG_RIGHT
    sta PPU_DATA

    dey
    tya
    bne @PrintLine

  ; Bottom-left corner
  jsr PushDialogPPUAddrToNextLine
  lda #DIALOG_BL_CORNER
  sta PPU_DATA

  ; Empty tiles
  lda dialog_width
  asl
  sec
  sbc #2
  tax
  lda #DIALOG_BOTTOM
  @PrintBottomTiles:
    sta PPU_DATA
    dex
    bne @PrintBottomTiles

  ; Bottom-right corner
  lda #DIALOG_BR_CORNER
  sta PPU_DATA

  ; Set PPU address attributes
  ;ldx dialog_x
  ;ldy dialog_y
  ;SetPPUAttrsAddrFromXY dialog_ppu_addr

  ;lda PPU_DATA
  ;lda PPU_DATA
  ;jsr SetMetatilePalette
  ;lda #0
  ;sta PPU_DATA
  ;sta PPU_DATA
  ;sta PPU_DATA
  ;sta PPU_DATA
  ;jsr PushDialogPPUAttrAddrToNextLine
  ;lda #0
  ;sta PPU_DATA
  ;sta PPU_DATA
  ;sta PPU_DATA
  ;sta PPU_DATA

  rts
.endproc

.proc CloseDialog

  rts
.endproc

PushDialogPPUAttrAddrToNextLine:

  ; Calculate offset size
  lda dialog_nl_offset
  lsr
  lsr
  sta temp
  lda dialog_width
  lsr
  clc
  adc temp
  sta temp

  ; Update pointer
  lda dialog_ppu_addr
  clc
  adc temp
  sta dialog_ppu_addr

  ; Set new PPU_ADDR
  PPU_Set_Addr dialog_ppu_addr, 0, 1

  rts

PushDialogPPUAddrToNextLine:

  ; Calculate offset size
  lda dialog_width
  asl
  clc
  adc dialog_nl_offset
  sta temp

  ; Calculate new PPU_ADDR
  lda dialog_ppu_addr
  clc
  adc temp
  sta dialog_ppu_addr
  lda dialog_ppu_addr+1
  adc #0
  sta dialog_ppu_addr+1

  ; Set new PPU_ADDR
  PPU_Set_Addr dialog_ppu_addr, 0, 1

  rts