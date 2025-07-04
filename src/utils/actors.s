; --------------------------------------
; Add an actor in memory, position it on
; the screen define its state and define
; a callback function to be run on each
; frame.
; Parameters:
; dataLabel - Metadata label data
; callback - Function called on each frame
; xPos - Position on the X axis
; yPos - Position on the Y axis
.macro Actor_Add dataLabel, callback, xPos, yPos
  Push_ParamsBytes 3

  Set_ParamLabel dataLabel, 0
  Set_ParamLabel callback, 1

  .ifnblank xPos
    Set_ParamByte xPos, 0
  .else
    stx params_bytes+0
  .endif
  .ifnblank yPos
    Set_ParamByte yPos, 1
  .else
    sty params_bytes+1
  .endif

  Set_ParamByte #ACTOR_STATE_VISIBLE | ACTOR_STATE_ANIMATED, 2

  jsr Actor_Add

  Pull_ParamsBytes 3
.endmacro
.proc Actor_Add

  ACTOR_TOTAL_BYTES = 16                  ; Needed because is a proc

  ; Map parameters to constants
  dataLabel = params_labels
  xPos = params_bytes+0
  yPos = params_bytes+1
  state = params_bytes+2
  callback = params_labels+2

  ; Calculate Y index (actor_size * actor total bytes)
  lda actor_size
  MUL_A ACTOR_TOTAL_BYTES
  tay

  ; Set actor metasprite label
  lda dataLabel                         ; Pointer low
  sta actor_array + ACTOR_DATA_PTR_LO, y
  lda dataLabel+1                       ; Pointer high
  sta actor_array + ACTOR_DATA_PTR_HI, y

  ; Set X/Y position
  lda xPos                              ; X position
  sta actor_array + ACTOR_X, y
  lda yPos                              ; Y position
  sta actor_array + ACTOR_Y, y

  ; Set state
  lda state;
  sta actor_array + ACTOR_STATE, y

  ; Set counter
  lda #0                                ; Start at 0
  sta actor_array + ACTOR_COUNTER, y

  ; Set callback function
  lda callback                          ; Callback pointer low
  sta actor_array + ACTOR_CALLBACK_LO, y
  lda callback+1                        ; Callback pointer high
  sta actor_array + ACTOR_CALLBACK_HI, y

  inc actor_size

  rts
.endproc

.macro ForEachActor callback
  Addr_Set indirect_jsr_ptr, callback, 1
  jsr ForEachActor
.endmacro
.proc ForEachActor
  lda actor_array
  ldx #0                                ; Actor index counter
  ForEachActorLoop:

    ; Multiple index by actor total bytes
    txa
    sta actor_index                     ; First, keep actor index
    MUL_A 16 ; ACTOR_TOTAL_BYTES
    tay

    ; Move current actor pointer by ACTOR_TOTAL_BYTES amount
    clc
    adc #<actor_array
    sta actor_ptr
    lda #>actor_array
    adc #0
    sta actor_ptr+1

    ; Run callback function
    Register_PushAll
    jsr IndirectJSR
    Register_PullAll

    ; Increase counter
    inx
    txa
    cmp actor_size
    bne ForEachActorLoop

  rts
.endproc

.macro CurActor_SetStateOr value
  ldy #ACTOR_STATE
  lda (actor_ptr),y
  ora value
  sta (actor_ptr),y
.endmacro

.macro CurActor_SetStateAnd value
  ldy #ACTOR_STATE
  lda (actor_ptr),y
  and value
  sta (actor_ptr),y
.endmacro

.macro CurActor_SetStateBit bit_number, positive
  ldy #ACTOR_STATE
  lda (actor_ptr),y
  .if positive = 1
    ora #bit_number
  .else
    and #<~bit_number
  .endif
  sta (actor_ptr),y
.endmacro

.macro SetCurrentActorIdx index
  lda index
  clc
  adc #<actor_array
  sta actor_ptr
  lda #>actor_array
  adc #0
  sta actor_ptr+1
.endmacro

.macro CurActor_SetMetasprite label
  Addr_SetPointer actor_ptr+ACTOR_DATA_PTR_LO, label, 1
.endmacro

.scope Actors

  ; --------------------------------------
  ; Run actors callback functions
  .proc RunCallback

    lda actor_array
    ldx #0                              ; Actor index counter
    ActorRunCallbackLoop:
      ; Multiple index by actor total bytes
      txa
      sta actor_index                   ; First, keep actor index
      MUL_A 16 ; ACTOR_TOTAL_BYTES
      tay

      ; Move current actor pointer by ACTOR_TOTAL_BYTES amount
      clc
      adc #<actor_array
      sta actor_ptr
      lda #>actor_array
      adc #0
      sta actor_ptr+1

      ; Prepare actor callback pointer
      lda actor_array+ACTOR_CALLBACK_LO,y
      sta indirect_jsr_ptr
      lda actor_array+ACTOR_CALLBACK_HI,y
      sta indirect_jsr_ptr+1

      ; Compute actor metatile
      ldy #ACTOR_Y
      lda (actor_ptr), y
      and #%11110000
      sta metasprite_metatile_idx
      ldy #ACTOR_X
      lda (actor_ptr), y
      and #%11110000
      lsr
      lsr
      lsr
      lsr
      clc
      adc metasprite_metatile_idx
      sta metasprite_metatile_idx

      ; Check damage countdown
      jsr ActorDamageCountdown

      ; Set current actor index and jump to actor's callback
      txa
      pha
      jsr IndirectJSR
      pla
      tax

      ; Increase counter
      inx
      txa
      cmp actor_size
      bne ActorRunCallbackLoop

      rts
  .endproc

  ; --------------------------------------
  ; Push all actors to OAM
  .proc PushToOAM
    Push_ParamsBytes 3
    Addr_Set oam_ptr, $0200, 1          ; Set OAM initial address

    ; Some variables
    animData = params_bytes+0
    animIndex = params_bytes+1
    actorIndex = params_bytes+2

    ldx #0                              ; Actor index (up to 8)
    stx actor_index
    ldy #0                              ; Pointer address (index * actor total bytes)
    @ActorPushToOAMLoop:
      tya
      sta actorIndex

      lda actor_array + ACTOR_STATE, y  ; Get actor state
      and #ACTOR_STATE_VISIBLE
      bne :+
        jmp @ActorPushToOAMSkip         ; Skip if not active
      :

        ; Check if need to switch to next metasprite if animation active
        lda actor_array + ACTOR_STATE, y; Get actor state
        and #ACTOR_STATE_ANIMATED
        beq @ActorPushToOAMSkipUpdateData ; Skip animation if not active

          ; Set metasprite pointer
          lda actor_array + ACTOR_DATA_PTR_LO, y
          sta ptr
          lda actor_array + ACTOR_DATA_PTR_HI, y
          sta ptr+1

          ; Fetch animation data index
          ldy #0
          lda (ptr), y                  ; Tile amount
          asl
          asl                           ; Multiple by 4 bytes
          tay                           ; Copy to register Y
          iny                           ; Move to last byte
          sty animIndex

          ; If animated, check if we need to fetch
          ; next metasprite or return to the first
          ; one if already at the last one
          lda (ptr), y                  ; Get animation data
          sta animData
          beq @ActorPushToOAMSkipUpdateData ; Skip if 0 (static)

            ; Update pointer value to next/first
            ; metasprite if required
            ldy actorIndex
            lda animData
            and #$7F
            cmp actor_array + ACTOR_COUNTER, y
            bne @ActorPushToOAMSkipUpdateData ; Skip if not completed

              ; Reset counter to 0
              lda #0
              sta actor_array + ACTOR_COUNTER, y

              ; Update frame index
              txa
              pha
              lda animData
              and #FLAG_N               ; Check if loop flag
              ; Redirect to metasprite label
              beq :+
                ldy animIndex
                ldx actorIndex
                iny
                lda (ptr), y
                sta actor_array + ACTOR_DATA_PTR_LO, x
                iny
                lda (ptr), y
                sta actor_array + ACTOR_DATA_PTR_HI, x
                jmp @ActorPushToOAMUpdatedFrame
              : ; Fetch next sprite
                ldy #0
                ldx actorIndex
                lda ptr
                inc animIndex
                clc
                adc animIndex
                sta actor_array + ACTOR_DATA_PTR_LO, x
                lda ptr+1
                adc #$00
                sta actor_array + ACTOR_DATA_PTR_HI, x

        @ActorPushToOAMUpdatedFrame:
              pla
              tax

        @ActorPushToOAMSkipUpdateData:

        ; Set metasprite
        ldy actorIndex
        lda actor_array + ACTOR_DATA_PTR_LO, y
        sta sprite_ptr
        lda actor_array + ACTOR_DATA_PTR_HI, y
        sta sprite_ptr+1

        ; Set position
        lda actor_array + ACTOR_X, y
        sta metasprite_x
        lda actor_array + ACTOR_Y, y
        sta metasprite_y

        ; Push metasprite to OAM
        StackedXY_Call Metasprite_Set
      @ActorPushToOAMSkip:

      ; Get next actor index (index * actor total bytes)
      inx
      stx actor_index
      txa
      MUL_A 16 ; ACTOR_TOTAL_BYTES
      tay

      cpx actor_size
      beq :+
        jmp @ActorPushToOAMLoop
      :

    ; Clear rest of OAM
    ldy #0
    ldx oam_ptr
    lda #$FF
    :
      sta (oam_ptr), y
      iny
      inx
      bne :-

    Pull_ParamsBytes 3

    rts
  .endproc
.endscope

; REG_A = damage
.proc HurtCurrentActor

  ; Check if actor damaged
  tax
  ldy #ACTOR_STATE
  lda (actor_ptr), y
  and #ACTOR_STATE_DAMAGE
  bne @else

    ; Flag actor as damaged
    lda (actor_ptr), y
    ora #ACTOR_STATE_DAMAGE
    sta (actor_ptr), y

    ; Set invulnerability timer
    ldy #ACTOR_INVULN_TIMER
    lda (actor_ptr), y
    lda #90
    sta (actor_ptr), y

    ; Decrease actor's health
    stx temp
    ldy #ACTOR_HEALTH
    lda (actor_ptr), y
    sec
    sbc temp
    sta (actor_ptr), y

    ; JSR to current actor damage callback
    JSR_TableIndex ActorDamageTable, actor_index
  @else:
  rts
.endproc
.proc ActorDamageCountdown
  ldy #ACTOR_STATE
  lda (actor_ptr), y
  and #ACTOR_STATE_DAMAGE
  beq @notDamaged

    ldy #ACTOR_INVULN_TIMER
    lda (actor_ptr), y
    sec
    sbc #1
    sta (actor_ptr), y
    bne @notZeroYet
      ldy #ACTOR_STATE
      lda (actor_ptr), y
      and #<~ACTOR_STATE_DAMAGE
      sta (actor_ptr), y
    @notZeroYet:
  @notDamaged:
  rts
.endproc
