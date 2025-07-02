DeadTxt: .byte "YOU DIED", 0

PlayerCallback:

  ; Check scrolling
  jsr ScrollingCheck
  lda scrolling_direction
  beq :+
    rts
  :

  ; Is player still alive?
  lda player_health
  bne :+
    jmp PlayerCallbackEnd
  :

  ; Check collision with objects
  jsr RunObjectActorCollision

  ; Check controls
  .include "player.controls.s"

  PlayerCallbackEnd:
  rts

PlayerIsDead:
  SetCurrentActorIdx #0
  CurActor_SetMetasprite GnomeDiesEnd
  jsr Sound::PlayerDead
  PrintText $218C, DeadTxt
  rts

PlayerDies:
  CurActor_SetMetasprite GnomeDiesStart
  DoTransition #TRANSITION_TYPE_FADEOUT, PlayerIsDead
  rts

Player_OnDamage:

  ; Lower player's health
  lda player_health
  beq :++
    stx temp
    lda player_health
    sec
    sbc temp
    sta player_health

    ; Play hurt sound effect
    jsr Sound::PlayerHurt

    ; Enable hearts in header state so it'll update during NMI
    lda header_state
    ora #HEADER_STATE_HEARTHS
    sta header_state

    ; If health 0, trigger player's death
    lda player_health
    bne :+
      jsr PlayerDies
    :
  :

  rts