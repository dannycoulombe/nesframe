.segment "CODE"

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
    jsr CheckIfPlayerIsSpinning
    jmp PlayerCallbackEnd
  :

  ; Check collision with objects
  jsr RunObjectActorCollision

  ; Check controls
  .include "player.controls.s"

  PlayerCallbackEnd:
  rts

CheckIfPlayerIsSpinning:
  ldx delayed_index
  lda delayed_item + DelayedItem::index, x
  cmp #2
  bne :+
    Pointer_IncVal actor_ptr, #ACTOR_COUNTER
  :
  rts

PlayerIsDead:

  ; Change metasprite to dead one
  SetCurrentActorIdx #0
  SetCurrentActorMetasprite GnomeDiesEnd

  ; Update death screen
  jsr PPU::ClearNametable
  OnceDuringNMI PlayerIsDeadNMI

  rts

PlayerIsDeadNMI:
  PPU_LoadPalette DefaultBGPal, $3F00, #16
  PrintText $21CC, DeadTxt
  rts

PlayerDies:
  SetCurrentActorMetasprite GnomeDiesStart
  ForEachActor Player_HideOtherActors
  StartDelayedTable PlayerRotateTbl
  DoTransition #TRANSITION_TYPE_FADEOUT, NoOp
  jsr Music::Stop
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

Player_HideOtherActors:
  lda actor_index
  beq :+
    jsr Actors::HideCurrent
  :
  rts

PlayerSpinStart:
  jsr Sound::PlayerDead
  rts

PlayerSpinContinue:
  SetCurrentActorIdx #0
  lda #0
  sta actor_array + ACTOR_COUNTER, y
  SetCurrentActorMetasprite GnomeSpinLeft
  rts

PlayerSpinStop:
  SetCurrentActorMetasprite GnomeSpinFront
  rts

.segment "RODATA"
DeadTxt: .byte "YOU DIED", 0

PlayerRotateTbl:
  .byte 60, DELAYED_FLAG_DEFAULT
  .word PlayerSpinStart
  .byte 5, DELAYED_FLAG_DEFAULT
  .word PlayerSpinContinue
  .byte (6 * (4 * 3)) - 6, DELAYED_FLAG_DEFAULT
  .word PlayerSpinStop
  .byte 55, DELAYED_FLAG_DEFAULT
  .word PlayerIsDead
  .byte 60
  .word DeathScreen
  .byte 0