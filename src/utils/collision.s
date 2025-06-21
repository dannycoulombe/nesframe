.macro Collision_SpritePushback mapData, xPos, yPos, offsetX, offsetY, width, height, deltaX, deltaY

  ; Perform collision check
  jsr @Collision_SpritePushback_DoVertical
  jsr @Collision_SpritePushback_DoHorizontal
  jmp @Collision_SpritePushback_End

  ; ------------------------------------
  ; Initialize positions
  @Collision_SpritePushback_InitPos:
    lda yPos
    clc
    adc offsetY
    sta collision_check_y
    lda xPos
    clc
    adc offsetX
    sta collision_check_x
    rts

  ; ------------------------------------
  ; Update tile indexes
  @Collision_SpritePushback_UpdateTileIndexes:

    ; Get top-left tile
    jsr @Collision_SpritePushback_GetTileIdx
    sta collision_tl_tile_idx

    ; Check top-right tile
    lda collision_check_x
    clc
    adc width
    sta collision_check_x
    jsr @Collision_SpritePushback_GetTileIdx
    sta collision_tr_tile_idx

    ; Get bottom-right tile
    lda collision_check_y
    clc
    adc height
    sta collision_check_y
    jsr @Collision_SpritePushback_GetTileIdx
    sta collision_br_tile_idx

    ; Check bottom-left tile
    lda collision_check_x
    sec
    sbc width
    sta collision_check_x
    jsr @Collision_SpritePushback_GetTileIdx
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
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalEnd

        ; Check top-right tile
        lda collision_tr_tile_idx
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalEnd

        jmp :++
      : ; Going down

        ; Check bottom-right position
        lda collision_br_tile_idx
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalEnd

        ; Check bottom-left position
        lda collision_bl_tile_idx
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoVerticalEnd
      :

      ; No collision: update Y position
      lda yPos
      clc
      adc deltaY
      sta yPos

      @Collision_SpritePushback_DoVerticalEnd:
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
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalEnd

        ; Check bottom-left tile
        lda collision_bl_tile_idx
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalEnd

        jmp :++
      : ; Going right

        ; Check top-right position
        lda collision_tr_tile_idx
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalEnd

        ; Check bottom-right position
        lda collision_br_tile_idx
        jsr @Collision_SpritePushback_GetTileProp
        cmp #COLLISION_SOLID
        beq @Collision_SpritePushback_DoHorizontalEnd
      :

      ; No collision: update X position
      lda xPos
      clc
      adc deltaX
      sta xPos

      @Collision_SpritePushback_DoHorizontalEnd:
        rts

  ; ------------------------------------
  ; Get tile index from collision coordinates
  @Collision_SpritePushback_GetTileIdx:

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

  ; ------------------------------------
  ; Get tile properties
  @Collision_SpritePushback_GetTileProp:
    sec
    sbc #32
    tay

    ; Get metatile index (x8 bytes)
    lda (mapData), y
    asl
    asl
    asl
    tay

    lda Metatiles2x2Data+METATILE_2X2_PROP, y

    rts

  ; ------------------------------------
  ; End collision check
  @Collision_SpritePushback_End:

.endmacro
