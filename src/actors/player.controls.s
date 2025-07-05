PlayerReadControls:

  ; ------------------------------------
  ; Movements

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
  sta player_coll_off_x
  sta player_coll_off_y

  ; Read buttons
  lda buttons
  beq :+
    jmp PlayerReadControlsStillnessEnd
  :

    ; If required, reset to stillness
    lda player_ori_dir
    tax

    ; Up
    and #DIRECTION_UP
    beq :+
      CurActor_SetMetasprite GnomeStillBack
      jmp @PlayerReadControlsResetEnd
    :

    ; Down
    txa
    and #DIRECTION_DOWN
    beq :+
      CurActor_SetMetasprite GnomeStillFront
      jmp @PlayerReadControlsResetEnd
    :

    ; Left
    txa
    and #DIRECTION_LEFT
    beq :+
      CurActor_SetMetasprite GnomeStillLeft
      jmp @PlayerReadControlsResetEnd
    :

    ; Right
    txa
    and #DIRECTION_RIGHT
    beq :+
      CurActor_SetMetasprite GnomeStillRight
      jmp @PlayerReadControlsResetEnd
    :

    @PlayerReadControlsResetEnd:

    lda player_ori_dir
    beq :+
      Pointer_SetVal actor_ptr, #0, #ACTOR_COUNTER
      lda #0
      sta player_ori_dir
    :

    jmp PlayerReadControlsMovementEnd
  PlayerReadControlsStillnessEnd:

  ; Up
  lda buttons
  tax
  and #BUTTON_UP
  beq :+
    lda metasprite_direction
    ora #DIRECTION_UP
    sta metasprite_direction
    lda #0
    sta player_coll_off_y
    jmp :++
  :

  ; Down
  txa
  and #BUTTON_DOWN
  beq :+
    lda metasprite_direction
    ora #DIRECTION_DOWN
    sta metasprite_direction
  :

  ; Right
  txa
  and #BUTTON_RIGHT
  beq :+
    lda metasprite_direction
    ora #DIRECTION_RIGHT
    sta metasprite_direction
    lda #7
    sta player_coll_off_x
    jmp :++
  :

  ; Left
  txa
  and #BUTTON_LEFT
  beq :+
    lda metasprite_direction
    ora #DIRECTION_LEFT
    sta metasprite_direction
  :

  ; Check collision
  .include "player.collision.s"

  ; Update sprites
  lda metasprite_direction
  cmp player_ori_dir
  bne :+
    jmp PlayerReadControlsSetMetaspriteEnd
  :

    lda metasprite_direction
    tax

    ; Up
    cmp #DIRECTION_UP
    bne :+
      lda #DIRECTION_UP
      sta player_ori_dir
      sta player_dir
      CurActor_SetMetasprite GnomeWalkBackA
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Down
    txa
    cmp #DIRECTION_DOWN
    bne :+
      lda #DIRECTION_DOWN
      sta player_ori_dir
      sta player_dir
      CurActor_SetMetasprite GnomeWalkFrontA
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Left
    txa
    cmp #DIRECTION_LEFT
    bne :+
      @PlayerReadControlsSetMetaspriteLeft:
      lda #DIRECTION_LEFT
      sta player_ori_dir
      sta player_dir
      CurActor_SetMetasprite GnomeWalkLeft
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Right
    txa
    cmp #DIRECTION_RIGHT
    bne :+
      @PlayerReadControlsSetMetaspriteRight:
      lda #DIRECTION_RIGHT
      sta player_ori_dir
      sta player_dir
      CurActor_SetMetasprite GnomeWalkRight
      jmp PlayerReadControlsSetMetaspriteEnd
    :

    ; Multiple buttons have been pressed at
    ; the same time
    lda player_ori_dir
    bne PlayerReadControlsSetMetaspriteEnd
    txa
    cmp #DIRECTION_UP | DIRECTION_LEFT
    beq @PlayerReadControlsSetMetaspriteLeft
    txa
    cmp #DIRECTION_UP | DIRECTION_RIGHT
    beq @PlayerReadControlsSetMetaspriteRight
    txa
    cmp #DIRECTION_DOWN | DIRECTION_LEFT
    beq @PlayerReadControlsSetMetaspriteLeft
    txa
    cmp #DIRECTION_DOWN | DIRECTION_RIGHT
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
  lda player_ori_dir
  beq :+
    Pointer_IncVal actor_ptr, #ACTOR_COUNTER
  :

  PlayerReadControlsMovementEnd:

  ; ------------------------------------
  ; Interactions
  lda pressed_buttons
  tax
  and #BUTTON_A
  beq PlayerReadControlsInteractionEnd

    ; Get player direction
    lda player_dir
    tax

    ; Up
    cmp #DIRECTION_UP
    bne :+
      lda metasprite_y
      sec
      sbc #1
      sta collision_check_y
      lda metasprite_x
      sta collision_check_x
      jsr Collision_SpritePushback_GetTileIdx
      jmp PlayerReadControlsInteractionDo
    :

    ; Down
    cmp #DIRECTION_DOWN
    bne :+
      lda metasprite_y
      clc
      adc #5
      sta collision_check_y
      lda metasprite_x
      sta collision_check_x
      jmp PlayerReadControlsInteractionDo
    :

    ; Down
    cmp #DIRECTION_LEFT
    bne :+
      lda metasprite_x
      sec
      sbc #9
      sta collision_check_x
      lda metasprite_y
      sta collision_check_y
      jmp PlayerReadControlsInteractionDo
    :

    ; Right
    cmp #DIRECTION_RIGHT
    bne :+
      lda metasprite_x
      clc
      adc #8
      sta collision_check_x
      lda metasprite_y
      sta collision_check_y
      jmp PlayerReadControlsInteractionDo
    :

    jmp PlayerReadControlsInteractionEnd

  PlayerReadControlsInteractionDo:
    jsr Collision_SpritePushback_GetTileIdx
    sta interaction_tile_idx
    jsr InteractWithTileIdx

  PlayerReadControlsInteractionEnd:

  PlayerReadControlsEnd:

  rts