; Set a metasprite into OAM buffer
; Parameters (RAM):
; sprite_ptr - Label to read metasprite data from
; metasprite_y - Position of the metasprite on the Y axis
; metasprite_x - Position of the metasprite on the X axis
; oam_ptr - OAM buffer starting address
.proc Metasprite_Set

  ; Clone pointer
  lda sprite_ptr
  sta ptr
  lda sprite_ptr+1
  sta ptr+1

  ldy #0
  lda (ptr),y                           ; Tile amount
  tax
  inc ptr
@MetaspriteSetLoop:

  ; Calculating X offset
  ldy #0
  lda metasprite_x
  clc
  adc (ptr),y
  sec
  sbc scroll_x

  ; Push X offset to OAM
  ldy #3
  sta (oam_ptr),y

  ; Calculating Y offset
  ldy #1
  lda metasprite_y
  clc
  adc (ptr),y
  sec
  sbc scroll_y

  ; Push Y offset to OAM
  ldy #0
  sta (oam_ptr),y

  ; Set tile
  ldy #2
  lda (ptr),y
  ldy #1
  sta (oam_ptr),y

  ; Set attributes
  ldy #ACTOR_STATE
  lda (actor_ptr), y
  and #ACTOR_STATE_DAMAGE
  bne @flashing
    ldy #3
    lda (ptr),y
    ldy #2
    sta (oam_ptr),y
    jmp @endFlashing
  @flashing:
LogA
  @endFlashing:

  ; Prepare pointer for next tile
  lda ptr
  clc
  adc #4
  sta ptr
  bcc :+
    inc ptr+1
  :

  ; Prepare pointer for next tile
  lda oam_ptr
  clc
  adc #4
  sta oam_ptr
  bcc :+
    inc oam_ptr+1
  :

  dex
  bne @MetaspriteSetLoop

  rts
.endproc
