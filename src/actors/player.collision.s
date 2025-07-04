PlayerCollision:

  ; Map variables names
  mapData = scene_map_ptr_jt
  xPos = metasprite_x
  yPos = metasprite_y
  deltaX = metasprite_delta_x
  deltaY = metasprite_delta_y

  ; Initialize delta
  lda #0
  sta deltaX
  sta deltaY

  ; Keep direction in register X
  lda metasprite_direction
  tax

  ; Prepare vertical collision check
  and #DIRECTION_UP
  beq :+
    dec deltaY
    jmp :++
  :
  txa
  and #DIRECTION_DOWN
  beq :+
    inc deltaY
  :

  ; Prepare horizontal collision check
  txa
  and #DIRECTION_LEFT
  beq :+
    dec deltaX
  :
  txa
  and #DIRECTION_RIGHT
  beq :+
    inc deltaX
  :

  ; Update position
  Collision_SpritePushback mapData, xPos, yPos, #15, #4, deltaX, deltaY
