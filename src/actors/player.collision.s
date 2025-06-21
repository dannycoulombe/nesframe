PlayerCollision:

  ; Map variables names
  mapData = scene_nametable_label
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
  and #ACTOR_STATE_DIRECTION_UP
  beq :+
    dec deltaY
    jmp :++
  :
  txa
  and #ACTOR_STATE_DIRECTION_DOWN
  beq :+
    inc deltaY
  :

  ; Prepare horizontal collision check
  txa
  and #ACTOR_STATE_DIRECTION_LEFT
  beq :+
    dec deltaX
  :
  txa
  and #ACTOR_STATE_DIRECTION_RIGHT
  beq :+
    inc deltaX
  :

;  lda deltaX
;  asl
;  asl
;  sta deltaX
;
;  lda deltaY
;  asl
;  asl
;  sta deltaY

  ; Update position
  Collision_SpritePushback mapData, xPos, yPos, #<~7, #4, #15, #4, deltaX, deltaY
