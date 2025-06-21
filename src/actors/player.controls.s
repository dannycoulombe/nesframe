PlayerReadControls:

  Pull_ParamsBytes 2
  collisionOffsetX = params_bytes+0
  collisionOffsetY = params_bytes+1
  originalDirection = params_bytes+2

  ; Keep position in memory
  ldy #ACTOR_Y
  lda (actor_ptr), y
  sta metasprite_y
  ldy #ACTOR_X
  lda (actor_ptr), y
  sta metasprite_x

  ; Initialize direction
  lda #0
  sta metasprite_direction

  ; Initialize collision detection offset
  lda #8
  sta collisionOffsetX
  sta collisionOffsetY

  ; Read buttons
  lda buttons
  beq :+
    jmp PlayerReadControlsStillnessEnd
  :

    ; If required, reset to stillness
    lda originalDirection
    tax

    ; Up
    and #ACTOR_STATE_DIRECTION_UP
    beq :+
      CurActor_SetMetasprite GnomeStillBack
      jmp @PlayerReadControlsResetEnd
    :

    ; Down
    txa
    and #ACTOR_STATE_DIRECTION_DOWN
    beq :+
      CurActor_SetMetasprite GnomeStillFront
      jmp @PlayerReadControlsResetEnd
    :

    ; Left
    txa
    and #ACTOR_STATE_DIRECTION_LEFT
    beq :+
      CurActor_SetMetasprite GnomeStillLeft
      jmp @PlayerReadControlsResetEnd
    :

    ; Right
    txa
    and #ACTOR_STATE_DIRECTION_RIGHT
    beq :+
      CurActor_SetMetasprite GnomeStillRight
      jmp @PlayerReadControlsResetEnd
    :

    @PlayerReadControlsResetEnd:

    lda originalDirection
    beq :+
      CurActor_SetStateBit %00001111, 0
      Pointer_SetVal actor_ptr, #0, #ACTOR_COUNTER

      lda #0
      sta originalDirection
    :

    jmp PlayerReadControlsEnd
  PlayerReadControlsStillnessEnd:

  ; Up
  lda buttons
  tax
  and #BUTTON_UP
  beq :+
    lda metasprite_direction
    ora #ACTOR_STATE_DIRECTION_UP
    sta metasprite_direction
    lda #0
    sta collisionOffsetY
    jmp :++
  :

  ; Down
  txa
  and #BUTTON_DOWN
  beq :+
    lda metasprite_direction
    ora #ACTOR_STATE_DIRECTION_DOWN
    sta metasprite_direction
  :

  ; Right
  txa
  and #BUTTON_RIGHT
  beq :+
    lda metasprite_direction
    ora #ACTOR_STATE_DIRECTION_RIGHT
    sta metasprite_direction
    lda #7
    sta collisionOffsetX
    jmp :++
  :

  ; Left
  txa
  and #BUTTON_LEFT
  beq :+
    lda metasprite_direction
    ora #ACTOR_STATE_DIRECTION_LEFT
    sta metasprite_direction
  :

  .include "player.collision.s"

  ; Update sprites
  lda metasprite_direction
  cmp originalDirection
  bne :+
    jmp PlayerReadControlsSetMetaspriteEnd
  :

    lda metasprite_direction
    tax

    ; Up
    cmp #ACTOR_STATE_DIRECTION_UP
    bne :+
      lda #ACTOR_STATE_DIRECTION_UP
      sta originalDirection
      CurActor_SetMetasprite GnomeWalkBackA
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Down
    txa
    cmp #ACTOR_STATE_DIRECTION_DOWN
    bne :+
      lda #ACTOR_STATE_DIRECTION_DOWN
      sta originalDirection
      CurActor_SetMetasprite GnomeWalkFrontA
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Left
    txa
    cmp #ACTOR_STATE_DIRECTION_LEFT
    bne :+
      @PlayerReadControlsSetMetaspriteLeft:
      lda #ACTOR_STATE_DIRECTION_LEFT
      sta originalDirection
      CurActor_SetMetasprite GnomeWalkLeft
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Right
    txa
    cmp #ACTOR_STATE_DIRECTION_RIGHT
    bne :+
      @PlayerReadControlsSetMetaspriteRight:
      lda #ACTOR_STATE_DIRECTION_RIGHT
      sta originalDirection
      CurActor_SetMetasprite GnomeWalkRight
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Multiple buttons have been pressed at
    ; the same time
    lda originalDirection
    bne PlayerReadControlsSetMetaspriteEnd
    txa
    cmp #ACTOR_STATE_DIRECTION_UP | ACTOR_STATE_DIRECTION_LEFT
    beq @PlayerReadControlsSetMetaspriteLeft
    txa
    cmp #ACTOR_STATE_DIRECTION_UP | ACTOR_STATE_DIRECTION_RIGHT
    beq @PlayerReadControlsSetMetaspriteRight
    txa
    cmp #ACTOR_STATE_DIRECTION_DOWN | ACTOR_STATE_DIRECTION_LEFT
    beq @PlayerReadControlsSetMetaspriteLeft
    txa
    cmp #ACTOR_STATE_DIRECTION_DOWN | ACTOR_STATE_DIRECTION_RIGHT
    beq @PlayerReadControlsSetMetaspriteRight
  PlayerReadControlsSetMetaspriteEnd:

  ; Update position
  lda metasprite_x
  ldy #ACTOR_X
  sta (actor_ptr), y
  lda metasprite_y
  ldy #ACTOR_Y
  sta (actor_ptr), y

  ; Update direction
  ldy #ACTOR_STATE
  lda (actor_ptr),y
  and #%11110000
  ora metasprite_direction
  sta (actor_ptr),y

  ; Update actor counter
  lda originalDirection
  beq :+
    Pointer_IncVal actor_ptr, #ACTOR_COUNTER
  :

  PlayerReadControlsEnd:

  Push_ParamsBytes 2
