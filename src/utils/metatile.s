; --------------------------------------
; Constants
METATILE_LAST_INDEX       = 64
PPU_ADDR_OFFSET           = $80
TILE_ROW_TOTAL            = 26
TILE_COLUMN_TOTAL         = 32

; --------------------------------------
; Memory
.segment "ZEROPAGE"
metatile_line_ppu_addr:   .word 0

.segment "RAM"
metatile_next_line:       .byte 0

; --------------------------------------
; Logic
.segment "CODE"

; This pushes the PPU address to ppu_tile_cache_target
; sequentially based on the current metatile_next_line.
.proc CacheMetatileLinePPUAddr

  ; Prepare PPU address ($2000+OFFSET)
  lda #PPU_ADDR_OFFSET
  sta metatile_line_ppu_addr+1
  lda #$20
  sta metatile_line_ppu_addr

  ; Start from next line, multiple by 40 and
  ; push the carries to the hi-byte
  ldy metatile_next_line
  @multiply:
    lda metatile_line_ppu_addr
    clc
    adc #40
    sta metatile_line_ppu_addr
    bcc @noCarry
    inc metatile_line_ppu_addr+1
  @noCarry:
    dey
    bne @multiply

  rts
.endproc

; Pushes a cache of tiles to later load into the PPU
; during the NMI process.
;
; Data structure:
; Byte #0: Amount of tiles to push (0 will stop the process)
; Byte #1: Horizontal (0) or vertical (1)
; Byte #2: Width/Height (amount of tiles to print on a line)
; Byte #3: Next line offset (offset to skip to start printing on next line)
; Byte #4-6: PPU address to write to
; Byte X...Y: Tiles to write based on amount of tiles
;
; Parameters:
; Register X as width/height
; Register Y as next line offset
.proc PushMetatileLineToPPUCache

  ; Skip if metatile_next_line variable sets at $FF
  lda metatile_next_line
  cmp #METATILE_LAST_INDEX
  bne @end

    ; Push 64 to ppu_tile_cache_target to tell
    ; the PPU that 64 tiles needs to be loaded.
    lda #METATILE_LAST_INDEX
    SeqPush ppu_tile_cache_target

    ; Push direction to PPU cache
    ; TODO: horizontal as of now
    lda #0
    SeqPush ppu_tile_cache_target

    ; Push width to PPU cache
    txa
    SeqPush ppu_tile_cache_target

    ; Push limit to PPU cache
    tya
    SeqPush ppu_tile_cache_target

    ; Cache PPU address to zero-page
    jsr CacheMetatileLinePPUAddr

    ; Sequential push to ppu_tile_cache
    lda metatile_line_ppu_addr
    SeqPush ppu_tile_cache_target
    lda metatile_line_ppu_addr+1
    SeqPush ppu_tile_cache_target

    ; Loop through a complete line
    ; X being a row within a metatile
    ldx #0
    @lineLoop:
    ldy #0
    txa
    pha
    @byteLoop:

      ; Get metatile index from map pointer
      lda (map_ptr), y
      tax

      ; Load and push tile indexes from metatile into PPU
      lda Metatiles2x2Data, x
      sta PPU_DATA
      inx
      lda Metatiles2x2Data, x
      sta PPU_DATA

      ; Increase loop index of continue if necessary
      iny
      cpy #TILE_COLUMN_TOTAL
      bne @byteLoop

    ; We've completed a tile line. Check if we need to
    ; continue with another line.
    pla
    tax
    inx
    inx
    cpx #4
    bne @lineLoop

  @end:

  ; Increase next line index for next pass
  inc metatile_next_line

  rts
.endproc

.macro SetMetatile addr, metatile, palette, fromVar

  PPU_Set_Addr addr, 0, fromVar

  ldx metatile
  lda Metatiles2x2Data, x
  sta PPU_DATA
  inx
  lda Metatiles2x2Data, x
  sta PPU_DATA

  .ifblank fromVar
    PPU_Set_Addr (addr + $20), 0, fromVar
  .else
    lda addr
    clc
    adc #$20
    sta addr
    PPU_Set_Addr addr, 0, fromVar
  .endif

  inx
  lda Metatiles2x2Data, x
  sta PPU_DATA
  inx
  lda Metatiles2x2Data, x
  sta PPU_DATA

  ;.ifnblank palette
  ;  PPU_Set_Addr $23E6
  ;  lda palette
  ;  sta PPU_DATA
  ;.endif

.endmacro

; Calculate the metatile index from a X/Y coordinate
; RegY = Y position
; RegX = X position
.proc GetMetatileIdx

  ; Compute Y Pos
  tya
  and #%11110000
  sta temp

  ; Compute X pos
  txa
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  clc
  adc temp                              ; Add Y*8 to X to get final offset
.endproc

; A = tile idx
.proc GetMetatileProp
  sec
  sbc #32
  tay
  lda (map_ptr), y
  tay
  lda Metatiles2x2Prop, y
  rts
.endproc