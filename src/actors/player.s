.segment "RODATA"
DeadTxt: .byte "YOU DIED", 0

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
    jmp PlayerCallbackEnd
  :

  ; Check collision with objects
  jsr RunObjectActorCollision

  ; Check controls
  .include "player.controls.s"

  PlayerCallbackEnd:
  rts

PlayerIsDead:

  ; Change metasprite to dead one
  jsr Sound::PlayerDead
  SetCurrentActorIdx #0
  CurActor_SetMetasprite GnomeDiesEnd

  ; Update death screen
  jsr PPU::ClearNametable
  OnceDuringNMI PlayerIsDeadNMI

  rts

PlayerIsDeadNMI:
  PPU_LoadPalette DefaultBGPal, $3F00, #16
  PrintText $21CC, DeadTxt
  rts

Player_HideOtherActors:
  lda actor_index
  beq :+
    ldy #ACTOR_STATE
    lda (actor_ptr), y
    tax
    and #ACTOR_STATE_VISIBLE
    beq :+
      txa
      and #<~ACTOR_STATE_VISIBLE
      sta (actor_ptr), y
  :
  rts

PlayerDies:
  CurActor_SetMetasprite GnomeDiesStart
  ForEachActor Player_HideOtherActors
  DoTransition #TRANSITION_TYPE_FADEOUT, PlayerIsDead
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