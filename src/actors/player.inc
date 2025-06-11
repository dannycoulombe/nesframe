STATE_DEFAULT = ACTOR_STATE_ACTIVATED | ACTOR_STATE_ANIMATED
STATE_DIRECTION_UP = 3
STATE_DIRECTION_RIGHT = 2
STATE_DIRECTION_DOWN = 1
STATE_DIRECTION_LEFT = 0

PlayerCallback:

  ; ------------------------------------
  ; Maintained buttons

  ; Read buttons
  lda buttons
  tax                                   ; Move A to X since reading from registers takes less CPU cycles

  bne @AfterPlayerCallbackDirectionReset

    ; Set original direction to stillness
    ldy #ACTOR_STATE

    ; Up
    lda (actor_ptr), y
    and #(1 << STATE_DIRECTION_UP)
    beq :+
      CurActor_SetMetasprite GnomeStillBack
      jmp @PlayerCallbackDirectionResetFinish
    :

    ; Down
    lda (actor_ptr), y
    and #(1 << STATE_DIRECTION_DOWN)
    beq :+
      CurActor_SetMetasprite GnomeStillFront
      jmp @PlayerCallbackDirectionResetFinish
    :

    ; Left
    lda (actor_ptr), y
    and #(1 << STATE_DIRECTION_LEFT)
    beq :+
      CurActor_SetMetasprite GnomeStillLeft
      jmp @PlayerCallbackDirectionResetFinish
    :

    ; Right
    lda (actor_ptr), y
    and #(1 << STATE_DIRECTION_RIGHT)
    beq :+
      CurActor_SetMetasprite GnomeStillRight
      jmp @PlayerCallbackDirectionResetFinish
    :

    @PlayerCallbackDirectionResetFinish:

    ; Reset all flags
    CurActor_SetStateFlagAll #STATE_DEFAULT
    Pointer_SetVal actor_ptr, #0, #ACTOR_COUNTER
  @AfterPlayerCallbackDirectionReset:

  ; Up
  and #BUTTON_UP
  beq :+
    Pointer_DecVal actor_ptr, #ACTOR_Y
    jmp :++
  :

  ; Down
  txa
  and #BUTTON_DOWN
  beq :+
    Pointer_IncVal actor_ptr, #ACTOR_Y
  :

  ; Right
  txa
  and #BUTTON_RIGHT
  beq :+
    Pointer_IncVal actor_ptr, #ACTOR_X
    jmp :++
  :

  ; Left
  txa
  and #BUTTON_LEFT
  beq :+
    Pointer_DecVal actor_ptr, #ACTOR_X
  :

  ; ------------------------------------
  ; Newly pressed buttons

  lda #0
  LogA 0

  ldy #ACTOR_STATE
  lda (actor_ptr), y
  and #%00001111
  bne @PlayerCallbackDirectionEnd

    ; Read buttons
    lda pressed_buttons
    tax                                   ; Move A to X since reading from registers takes less CPU cycles

    ; Up
    and #BUTTON_UP
    beq :+
      CurActor_SetStateFlagBit STATE_DIRECTION_UP, 1
      CurActor_SetMetasprite GnomeWalkBackA
      jmp :++
    :

    ; Down
    txa
    and #BUTTON_DOWN
    beq :+
      CurActor_SetStateFlagBit STATE_DIRECTION_DOWN, 1
      CurActor_SetMetasprite GnomeWalkFrontA
    :

    ; Right
    txa
    and #BUTTON_RIGHT
    beq :+
      CurActor_SetStateFlagBit STATE_DIRECTION_RIGHT, 1
      CurActor_SetMetasprite GnomeWalkRight
      jmp :++
    :

    ; Left
    txa
    and #BUTTON_LEFT
    beq :+
      CurActor_SetStateFlagBit STATE_DIRECTION_LEFT, 1
      CurActor_SetMetasprite GnomeWalkLeft
    :
  @PlayerCallbackDirectionEnd:

  ; Increase frame counter if player is
  ; moving in a direction
  ldy #ACTOR_STATE
  lda (actor_ptr), y
  and #%00001111
  beq :+
    Pointer_IncVal actor_ptr, #ACTOR_COUNTER
  :

  jmp AfterActorRunCallback
