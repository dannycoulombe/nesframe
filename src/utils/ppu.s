.segment "CODE"

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

; Use register x/y for positions
.macro SetPPUAttrsAddrFromXY addr
  lda #$23
  sta addr+1
  jsr GetPPUAttrsAddrFromXY
  adc #$C0
  sta addr
  PPU_Set_Addr addr, 0, 1
.endmacro
.proc GetPPUAttrsAddrFromXY
  txa
  lsr           ; metatile_x / 2
  sta temp       ; store x_part

  tya
  lsr           ; metatile_y / 2
  asl           ; *2
  asl           ; *4
  asl           ; *8 (metatile_y / 2 * 8)
  clc
  adc temp       ; final attribute index

  rts
.endproc

.macro PrintPPUMetatilesLine fromPPUAddress, totalColumns, mapTable
  PPU_SetMapPtr ptr, mapTable
  PPU_Set_Addr fromPPUAddress           ; Set PPU to given address

  ldy totalColumns

  jsr PrintPPUMetatilesLine
.endmacro
.proc PrintPPUMetatilesLine
  lda (ptr),y                           ; Load byte at X index
  tax

  @loop:
    lda Metatiles2x2Data, x
    sta PPU_DATA
    inx
    lda Metatiles2x2Data, x
    sta PPU_DATA
    inx
    dey
    tya
    bne @loop


.endproc

; Load a screen of 2x2 metatiles into the PPU
.macro PPU_Load_2x2_Screen fromPPUAddress, totalRows, mapTable

  PPU_SetMapPtr ptr, mapTable
  PPU_Set_Addr fromPPUAddress           ; Set PPU to given address

  lda totalRows
  sta temp
  ldy #0

  jsr PPU_Load_2x2_Screen
.endmacro
.proc PPU_Load_2x2_Screen
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

  rts
.endproc

.proc ClearOAM
  lda #$00
  sta OAM_ADDR         ; Start at beginning of OAM ($00)

  lda #$FF            ; Value to hide all sprites
  ldx #$00
@loop:
  sta OAM_DATA
  inx
  bne @loop           ; 256 iterations (X wraps at 0)

  rts
.endproc

; Expensive in CPU, but hey.. saves a lot of bytes!
; If stage has 16 nametables, it's 48 bytes x 16 ~ 768 bytes
; So if 8 levels ~ 6.1k and if you include an overworld of
; let's say 16x8, that would be another 6.1k for a total of
; 12k saved.
.macro PPU_LoadAttributes mapTable, fromPPUAddress
  PPU_SetMapPtr ptr, mapTable
  .ifnblank fromPPUAddress
    PPU_Set_Addr fromPPUAddress
  .else
    PPU_Set_Addr $23C8
  .endif
  jsr PPU_LoadAttributes
.endmacro
.proc PPU_LoadAttributes
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
.endproc

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

; Writing twice to $2006 ensures the internal write toggle
; is reset to first write, so that the next two $2005 writes
; are interpreted as X/Y.
; If you skip this, the latch might already be in "second write"
; state (or worse, flipped by a prior $2006), so you end up
; writing Y/Y or nothing at all.
.macro PPU_ResetLatch
  lda #0
  sta PPU_ADDR       ; write to $2006 (dummy)
  sta PPU_ADDR       ; write to $2006 (dummy)
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
    rts
  .endproc

  .proc ClearNametable
    jsr DisableRendering
    PPU_Set_Addr $2000
    ldx #0
    ldy #0
    lda #0
    @loop:
      sta PPU_DATA
      iny
      bne @loop
      inx
      cpx #4
      bne @loop
    jsr EnableRendering
    rts
  .endproc

  ; Clone nametable
  .proc Clone
    PPU_Load_2x2_Screen NM1_LEVEL_OFFSET, #13, map_ptr
    PPU_LoadAttributes map_ptr, $27C8
    rts
  .endproc
.endscope

; Outputs:
;   temp     = PPU_ADDR low byte
;   temp+1   = PPU_ADDR high byte
GetMetatilePPUAddr:
  ; Compute Y * 64 → use a lookup table
  tya
  asl         ; Y * 2
  tay
  lda Mul64Table,y      ; low byte of Y * 64
  sta temp
  lda Mul64Table+1,y     ; high byte of Y * 64
  sta temp+1

  ; Compute X * 2 and add to temp
  txa
  asl         ; X * 2
  clc
  adc temp
  sta temp
  lda temp+1
  adc #$00
  sta temp+1

  ; Add base address $2000
  clc
  lda temp
  adc #<$2000
  sta temp
  lda temp+1
  adc #>$2000
  sta temp+1

  rts