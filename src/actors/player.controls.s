STATE_DEFAULT = ACTOR_STATE_ACTIVATED | ACTOR_STATE_ANIMATED
STATE_DIRECTION_UP = 1 << 3
STATE_DIRECTION_RIGHT = 1 << 2
STATE_DIRECTION_DOWN = 1 << 1
STATE_DIRECTION_LEFT = 1 << 0

PlayerReadControls:

  Pull_ParamsByte 0
  Pull_ParamsByte 1

  direction = params_bytes+0
  originalDirection = params_bytes+2

  ; Read buttons
  lda buttons
  tax
  beq :+
    jmp PlayerReadControlsStillnessEnd
  :
    pha

    ; If required, reset to stillness
    lda originalDirection
    tax

    ; Up
    and #STATE_DIRECTION_UP
    beq :+
      CurActor_SetMetasprite GnomeStillBack
      jmp @PlayerReadControlsResetEnd
    :

    ; Down
    txa
    and #STATE_DIRECTION_DOWN
    beq :+
      CurActor_SetMetasprite GnomeStillFront
      jmp @PlayerReadControlsResetEnd
    :

    ; Left
    txa
    and #STATE_DIRECTION_LEFT
    beq :+
      CurActor_SetMetasprite GnomeStillLeft
      jmp @PlayerReadControlsResetEnd
    :

    ; Right
    txa
    and #STATE_DIRECTION_RIGHT
    beq :+
      CurActor_SetMetasprite GnomeStillRight
      jmp @PlayerReadControlsResetEnd
    :

    @PlayerReadControlsResetEnd:

    lda originalDirection
    beq :+
      CurActor_SetStateFlagAll #STATE_DEFAULT
      Pointer_SetVal actor_ptr, #0, #ACTOR_COUNTER

      lda #0
      sta originalDirection
      sta direction
    :

    pla
    tax
    jmp PlayerReadControlsEnd
  PlayerReadControlsStillnessEnd:

    ; ----------------------------------
    ; Maintained buttons

    ; Up
    txa
    and #BUTTON_UP
    beq :++
      txa
      and #%00001111
      cmp #BUTTON_UP
      bne :+
        lda #STATE_DIRECTION_UP
        sta direction
      :
      Pointer_DecVal actor_ptr, #ACTOR_Y
      jmp :+++
    :

    ; Down
    txa
    and #BUTTON_DOWN
    beq :++
      txa
      and #%00001111
      cmp #BUTTON_DOWN
      bne :+
        lda #STATE_DIRECTION_DOWN
        sta direction
      :
      Pointer_IncVal actor_ptr, #ACTOR_Y
    :

    ; Right
    txa
    and #BUTTON_RIGHT
    beq :++
      txa
      and #%00001111
      cmp #BUTTON_RIGHT
      bne :+                            ; Redirect if more than one button pressed
        lda #STATE_DIRECTION_RIGHT
        sta direction
      :
      Pointer_IncVal actor_ptr, #ACTOR_X
      jmp :+++
    :

    ; Left
    txa
    and #BUTTON_LEFT
    beq :++
      txa
      and #%00001111
      cmp #BUTTON_LEFT
      bne :+
        lda #STATE_DIRECTION_LEFT
        sta direction
      :
      Pointer_DecVal actor_ptr, #ACTOR_X
    :

    ; Skip if no direction
    lda direction
    beq @PlayerReadControlsSetMetaspriteEnd

    lda direction
    cmp originalDirection
    beq @PlayerReadControlsSetMetaspriteEnd

      lda direction
      sta originalDirection
      tax

      ; Up
      cmp #STATE_DIRECTION_UP
      bne :+
        CurActor_SetMetasprite GnomeWalkBackA
      :

      ; Down
      txa
      cmp #STATE_DIRECTION_DOWN
      bne :+
        CurActor_SetMetasprite GnomeWalkFrontA
      :

      ; Left
      txa
      cmp #STATE_DIRECTION_LEFT
      bne :+
        CurActor_SetMetasprite GnomeWalkLeft
      :

      ; Right
      txa
      cmp #STATE_DIRECTION_RIGHT
      bne :+
        CurActor_SetMetasprite GnomeWalkRight
      :
    @PlayerReadControlsSetMetaspriteEnd:

    ; Increment counter if player moving
    lda originalDirection
    beq :+
      Pointer_IncVal actor_ptr, #ACTOR_COUNTER
    :

    ; Update direction
    CurActor_SetStateFlagBit direction, 1

  PlayerReadControlsEnd:

  Push_ParamsByte 1
  Push_ParamsByte 0
