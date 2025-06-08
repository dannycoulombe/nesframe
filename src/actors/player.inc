MAX_SPEED        = $02                  ; Maximum speed value
ACCELERATION     = $01                  ; Acceleration value per frame
STATE_DIRECTION_UP = 3
STATE_DIRECTION_RIGHT = 2
STATE_DIRECTION_DOWN = 1
STATE_DIRECTION_LEFT = 0
STATE_DEFAULT = %10000000

PlayerCallback:

  ; ------------------------------------
  ; Maintained buttons

  ; Read buttons
  lda buttons
  tax                                   ; Move A to X since reading from registers takes less CPU cycles

  bne :+
    CurActor_SetStateFlagAll #STATE_DEFAULT
  :

  ; Up
  and #BUTTON_UP
  beq :+
    CurActor_DecVal actor_ptr, #ACTOR_Y
    jmp :++
  :

  ; Down
  txa
  and #BUTTON_DOWN
  beq :+
    CurActor_IncVal actor_ptr, #ACTOR_Y
  :

  ; Right
  txa
  and #BUTTON_RIGHT
  beq :+
    CurActor_IncVal actor_ptr, #ACTOR_X
    jmp :++
  :

  ; Left
  txa
  and #BUTTON_LEFT
  beq :+
    CurActor_DecVal actor_ptr, #ACTOR_X
  :

  ; ------------------------------------
  ; Newly pressed buttons
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
    CurActor_SetStateFlagBit 2, 1
    CurActor_SetMetasprite GnomeWalkRight
      jmp :++
  :

  ; Left
  txa
  and #BUTTON_LEFT
  beq :+
    CurActor_SetStateFlagBit 0, 1
    CurActor_SetMetasprite GnomeWalkLeft
  :

  jmp AfterActorRunCallback
