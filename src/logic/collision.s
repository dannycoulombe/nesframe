.macro Collision_SpritePushback mapData, xPos, yPos, width, height, deltaX, deltaY

  ; Perform collision check
  jsr @Collision_SpritePushback_DoVertical
  jsr @Collision_SpritePushback_DoHorizontal
  jmp @Collision_SpritePushback_End

  ; ------------------------------------
  ; Initialize positions
  @Collision_SpritePushback_InitPos:
    lda yPos
    sta collision_check_y

    lda width
    lsr
    sta temp
    lda xPos
    sec
    sbc temp
    sbc #1
    sta collision_check_x
    rts

  ; ------------------------------------
  ; Update tile indexes
  @Collision_SpritePushback_UpdateTileIndexes:

    ; Get top-left tile
    jsr Collision_SpritePushback_GetTileIdx
    sta collision_tl_tile_idx

    ; Get top-right tile
    lda collision_check_x
    clc
    adc width
    sta collision_check_x
    jsr Collision_SpritePushback_GetTileIdx
    sta collision_tr_tile_idx

    ; Get bottom-right tile
    lda collision_check_y
    clc
    adc height
    sta collision_check_y
    jsr Collision_SpritePushback_GetTileIdx
    sta collision_br_tile_idx

    ; Get bottom-left tile
    lda collision_check_x
    sec
    sbc width
    sta collision_check_x
    jsr Collision_SpritePushback_GetTileIdx
    sta collision_bl_tile_idx

    rts

  ; ------------------------------------
  ; Perform vertical check
  @Collision_SpritePushback_DoVertical:

    ; Is moving vertically?
    lda deltaY
    cmp #0
    beq @Collision_SpritePushback_DoVerticalEnd

      ; Set new Y position to check
      jsr @Collision_SpritePushback_InitPos
      lda collision_check_y
      clc
      adc deltaY
      sta collision_check_y

      ; Get positions
      jsr @Collision_SpritePushback_UpdateTileIndexes

      ; Which direction?
      lda deltaY
      bpl :+ ; Going up

        ; Check top-left tile
        lda collision_tl_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalCollisionUp

        ; Check top-right tile
        lda collision_tr_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalCollisionUp

        jmp :++
      : ; Going down

        ; Check bottom-right position
        lda collision_br_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalCollisionDown

        ; Check bottom-left position
        lda collision_bl_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalCollisionDown
      :

      ; No collision: update Y position
      lda yPos
      clc
      adc deltaY
      sta yPos

      @Collision_SpritePushback_DoVerticalEnd:
        rts

      @Collision_SpritePushback_DoVerticalCollisionUp:
        lda collision_check_y
        and #%11111000
        sta yPos
        rts

      @Collision_SpritePushback_DoVerticalCollisionDown:
        lda yPos
        and #%11111000
        clc
        adc height
        sec
        sbc #1
        sta yPos
        rts

  ; ------------------------------------
  ; Perform horizontal check
  @Collision_SpritePushback_DoHorizontal:

    ; Is moving horizontally?
    lda deltaX
    cmp #0
    beq @Collision_SpritePushback_DoHorizontalEnd

      ; Set new X position to check
      jsr @Collision_SpritePushback_InitPos
      lda collision_check_x
      clc
      adc deltaX
      sta collision_check_x

      ; Get positions
      jsr @Collision_SpritePushback_UpdateTileIndexes

      ; Which direction?
      lda deltaX
      bpl :+ ; Going left

        ; Check top-left tile
        lda collision_tl_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalCollisionLeft

        ; Check bottom-left tile
        lda collision_bl_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalCollisionLeft

        jmp :++
      : ; Going right

        ; Check top-right position
        lda collision_tr_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalCollisionRight

        ; Check bottom-right position
        lda collision_br_tile_idx
        jsr GetMetatileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalCollisionRight
      :

      ; No collision: update X position
      lda xPos
      clc
      adc deltaX
      sta xPos

      @Collision_SpritePushback_DoHorizontalEnd:
        rts

      @Collision_SpritePushback_DoHorizontalCollisionLeft:
        rts

      @Collision_SpritePushback_DoHorizontalCollisionRight:
        rts

  ; ------------------------------------
  ; End collision check
  @Collision_SpritePushback_End:

.endmacro

; ------------------------------------
; Get tile index from collision coordinates
Collision_SpritePushback_GetTileIdx:

  ; Compute Y Pos
  lda collision_check_y               ; Get Y coordinate
  and #%11110000
  sta temp

  ; Compute X pos
  lda collision_check_x               ; Get X coordinate
  and #%11110000
  lsr
  lsr
  lsr
  lsr
  clc
  adc temp                            ; Add Y*8 to X to get final offset
  sta temp

  rts