; --------------------------------------
; Declarations
PLAYER_PUSH_TIMER       = 14            ; 15 - 1 frame to avoid glitch

; --------------------------------------
; Variables
.segment "RAM"
player_push_timer:    .byte 0           ; Starts incrementing when player collide in one unique direction
player_is_pushing:    .byte 0           ; Player is pushing

; --------------------------------------
; Main code
.segment "CODE"

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
  bne PlayerStillnessCheckEnd

  ; If player is still, reset its metasprite
  jsr PlayerStillnessCheck
  jmp PlayerReadControlsMovementEnd
  PlayerStillnessCheckEnd:

  ; Apply player metasprite direction
  jsr SetPlayerMetaspriteDirection

  ; Skip if pushing
  lda player_is_pushing
  beq :+
    jsr PlayerPushingControlsCheck
    jmp PlayerReadControlsEnd
  :

  ; Check collision
  jsr PlayerCollisionCheck

  ; Update sprites
  lda metasprite_direction
  cmp player_ori_dir
  beq :+
    jsr SetPlayerMetasprite
  :

  ; Check interactions
  jsr PlayerInteractionCheck            ; Sets metasprite_metatile_touch_idx

  ; Check if player is pushing into solid object
  jsr PlayerPushCheck                   ; Sets player_push_timer and player metatile

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
  beq PlayerReadControlsInteractionAfterA
    lda metasprite_metatile_touch_idx
    bne PlayerReadControlsInteractionAfterA
    jsr InteractWithTileIdx

  PlayerReadControlsInteractionAfterA:
    txa
    and #BUTTON_B
    beq PlayerReadControlsInteractionAfterB

  PlayerReadControlsInteractionAfterB:

  PlayerReadControlsEnd:

  rts

; --------------------------------------
; Set player metasprite
SetPlayerMetasprite:
  lda metasprite_direction
  tax

  ; Up
  cmp #DIRECTION_UP
  bne :+
    lda #DIRECTION_UP
    sta player_ori_dir
    sta player_dir
    SetCurrentActorMetasprite GnomeWalkBackA
    rts
  :

  ; Down
  txa
  cmp #DIRECTION_DOWN
  bne :+
    lda #DIRECTION_DOWN
    sta player_ori_dir
    sta player_dir
    SetCurrentActorMetasprite GnomeWalkFrontA
    rts
  :

  ; Left
  txa
  cmp #DIRECTION_LEFT
  bne :+
    @PlayerReadControlsSetMetaspriteLeft:
    lda #DIRECTION_LEFT
    sta player_ori_dir
    sta player_dir
    SetCurrentActorMetasprite GnomeWalkLeft
    rts
  :

  ; Right
  txa
  cmp #DIRECTION_RIGHT
  bne :+
    @PlayerReadControlsSetMetaspriteRight:
    lda #DIRECTION_RIGHT
    sta player_ori_dir
    sta player_dir
    SetCurrentActorMetasprite GnomeWalkRight
    rts
  :

  ; Multiple buttons have been pressed at
  ; the same time
  lda player_ori_dir
  bne SetPlayerMetaspriteEnd
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

  SetPlayerMetaspriteEnd:
  rts

; --------------------------------------
; Check if player is still and reset required variables
PlayerStillnessCheck:

  ; If required, reset to stillness
  lda player_ori_dir
  tax

  ; Up
  and #DIRECTION_UP
  beq :+
    SetCurrentActorMetasprite GnomeStillBack
    jmp @PlayerReadControlsResetEnd
  :

  ; Down
  txa
  and #DIRECTION_DOWN
  beq :+
    SetCurrentActorMetasprite GnomeStillFront
    jmp @PlayerReadControlsResetEnd
  :

  ; Left
  txa
  and #DIRECTION_LEFT
  beq :+
    SetCurrentActorMetasprite GnomeStillLeft
    jmp @PlayerReadControlsResetEnd
  :

  ; Right
  txa
  and #DIRECTION_RIGHT
  beq :+
    SetCurrentActorMetasprite GnomeStillRight
    jmp @PlayerReadControlsResetEnd
  :

  @PlayerReadControlsResetEnd:

  lda player_ori_dir
  beq :+
    Pointer_SetVal actor_ptr, #0, #ACTOR_COUNTER
    lda #0
    sta player_ori_dir
    sta player_push_timer
    sta player_is_pushing
  :
  rts
; --------------------------------------
; Check if player is interacting with a metatile
; Sets the metasprite_metatile_touch_idx variable
PlayerInteractionCheck:

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
    jmp PlayerInteractionCheckDo
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
    jmp PlayerInteractionCheckDo
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
    jmp PlayerInteractionCheckDo
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
    jmp PlayerInteractionCheckDo
  :

  rts


  PlayerInteractionCheckDo:

  ; Reset touched metatile
  lda #0
  sta metasprite_metatile_touch_idx

  ; Set metatile touch index if touching a solid metatile
  jsr Collision_SpritePushback_GetTileIdx
  sta temp
  jsr GetMetatileProp
  cmp #COLLISION_SOLID
  bne :+
    lda temp
    sta metasprite_metatile_touch_idx
  :

  rts

; --------------------------------------
; Check if player pushing in the original direction
; as when if first started. Liberate the pushing flag
; if otherwise
PlayerPushingControlsCheck:
  lda metasprite_direction
  and player_ori_dir
  bne :+
    lda #0
    sta player_is_pushing
  :
  rts

; --------------------------------------
; Check if player is pushing into a solid object
PlayerPushCheck:

  ; Skip if no buttons are pressed
  lda buttons
  and #BUTTON_DIRECTION_ALL
  beq :++

  ; Skip if multiple directions
  sta temp
  sec
  sbc #1
  and temp
  bne :++

  ; Skip if not in contact with a metatile
  lda metasprite_metatile_touch_idx
  beq :++

  ; Branch based on timer progress
  lda player_push_timer
  cmp #PLAYER_PUSH_TIMER
  bne :+
    ; Timer expired, player officially pushes something
    jsr SetPlayerPushMetatile
    rts
  :
    ; Is pushing, increase timer
    inc player_push_timer
  :
  rts

; --------------------------------------
; Player is pushing, update its metatile
SetPlayerPushMetatile:
  lda player_ori_dir
  tax

  ; Up
  and #DIRECTION_UP
  beq :+
    lda #1
    sta player_is_pushing
    SetCurrentActorMetasprite GnomePushBack
    rts
  :

  ; Down
  txa
  and #DIRECTION_DOWN
  beq :+
    lda #1
    sta player_is_pushing
    SetCurrentActorMetasprite GnomePushFront
    rts
  :

  ; Left
  txa
  and #DIRECTION_LEFT
  beq :+
    lda #1
    sta player_is_pushing
    SetCurrentActorMetasprite GnomePushLeft
    rts
  :

  ; Right
  txa
  and #DIRECTION_RIGHT
  beq :+
    lda #1
    sta player_is_pushing
    SetCurrentActorMetasprite GnomePushRight
    rts
  :
  rts

SetPlayerMetaspriteDirection:

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

  rts

PlayerCollisionCheck:

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

  rts