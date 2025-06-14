.macro Collision_Check xPos, yPos, direction, collision, offset

  PPU_Disable_Rendering

  ; Check all directions
  lda direction
  tax
  and #ACTOR_STATE_DIRECTION_UP
  beq :++
    dec yPos
    Tilemap_GetAddressByXY xPos, yPos
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    beq :+
      inc yPos
    :
    jmp :++
  :
  txa
  and #ACTOR_STATE_DIRECTION_DOWN
  beq :++
    inc yPos
    Tilemap_GetAddressByXY xPos, yPos
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    beq :+
      dec yPos
    :
    sta temp
  :
  txa
  and #ACTOR_STATE_DIRECTION_LEFT
  beq :++
    dec xPos
    Tilemap_GetAddressByXY xPos, yPos
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    beq :+
      inc xPos
    :
    jmp :++
  :
  txa
  and #ACTOR_STATE_DIRECTION_RIGHT
  beq :++
    inc xPos
    Tilemap_GetAddressByXY xPos, yPos
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    beq :+
      dec xPos
    :
  :

  PPU_Enable_Rendering

.endmacro
