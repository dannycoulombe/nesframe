.macro CollisionCheckResetXY xPos, yPos
  lda xPos
  sta collision_check_x
  lda yPos
  sta collision_check_y
.endmacro
.macro Collision_Check xPos, yPos, direction, offsetX, offsetY

  PPU_Disable_Rendering
  CollisionCheckResetXY xPos, yPos

  ; Check all directions
  lda direction
  tax
  and #ACTOR_STATE_DIRECTION_UP
  beq :+
    dec collision_check_y
    lda collision_check_y
    sec
    sbc offsetY
    sta collision_check_y
    Tilemap_GetAddressByXY collision_check_x, collision_check_y
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    bne :++
    dec yPos
  :
  txa
  and #ACTOR_STATE_DIRECTION_DOWN
  beq :+
    CollisionCheckResetXY xPos, yPos
    inc collision_check_y
    lda collision_check_y
    clc
    adc offsetY
    sta collision_check_y
    Tilemap_GetAddressByXY collision_check_x, collision_check_y
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    bne :+
    inc yPos
  :
  txa
  and #ACTOR_STATE_DIRECTION_LEFT
  beq :+
    CollisionCheckResetXY xPos, yPos
    dec collision_check_x
    lda collision_check_x
    sec
    sbc offsetX
    sta collision_check_x
    Tilemap_GetAddressByXY collision_check_x, collision_check_y
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    bne :++
    dec xPos
  :
  txa
  and #ACTOR_STATE_DIRECTION_RIGHT
  beq :+
    CollisionCheckResetXY xPos, yPos
    inc collision_check_x
    lda collision_check_x
    clc
    adc offsetX
    sta collision_check_x
    Tilemap_GetAddressByXY collision_check_x, collision_check_y
    PPU_GetTileIdx temp
    tay
    lda TilesPropertiesData, y
    and #COLLISION_SOLID
    bne :+
    inc xPos
  :

  PPU_Enable_Rendering

.endmacro
