; --------------------------------------
; Push all actors to OAM
.macro Actor_Push_To_OAM
  Push_ParamsBytes 3
  Addr_Set oam_ptr, $0200, 1            ; Set OAM initial address

  ; Some variables
  animData = params_bytes+0
  animIndex = params_bytes+1
  actorIndex = params_bytes+2

  ldx #0                                ; Actor index (up to 8)
  ldy #0                                ; Pointer address (index * actor total bytes)
  @ActorPushToOAMLoop:
    tya
    sta actorIndex

    lda actor_array + ACTOR_STATE, y    ; Get actor state
    and #ACTOR_STATE_ACTIVATED
    bne :+
      jmp @ActorPushToOAMSkip           ; Skip if not active
    :

      ; Check if need to switch to next metasprite if animation active
      lda actor_array + ACTOR_STATE, y  ; Get actor state
      and #ACTOR_STATE_ANIMATED
      beq @ActorPushToOAMSkipUpdateData ; Skip animation if not active

        ; Set metasprite pointer
        lda actor_array + ACTOR_DATA_PTR_LO, y
        sta ptr
        lda actor_array + ACTOR_DATA_PTR_HI, y
        sta ptr+1

        ; Fetch animation data index
        ldy #0
        lda (ptr), y                    ; Tile amount
        asl
        asl                             ; Multiple by 4 bytes
        tay                             ; Copy to register Y
        iny                             ; Move to last byte
        sty animIndex

        ; If animated, check if we need to fetch
        ; next metasprite or return to the first
        ; one if already at the last one
        lda (ptr), y                    ; Get animation data
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
            and #FLAG_N                 ; Check if loop flag
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
              clc
              lda ptr
              inc animIndex
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
    txa
    MUL_A #ACTOR_TOTAL_BYTES
    tay

    cpx actor_index
    beq :+
      jmp @ActorPushToOAMLoop
    :

  Pull_ParamsBytes 3
.endmacro

; --------------------------------------
; Add an actor in memory, position it on
; the screen define its state and define
; a callback function to be run on each
; frame.
; Parameters:
; dataLabel - Metadata label data
; xPos - Position on the X axis
; yPos - Position on the Y axis
; callback - Function called on each frame
; state - State of the actor
.macro Actor_Add dataLabel, xPos, yPos, callback, state
  Push_ParamsBytes 3

  Set_ParamLabel dataLabel, 0
  Set_ParamLabel callback, 1
  Set_ParamByte xPos, 0
  Set_ParamByte yPos, 1

  .ifnblank state
    Set_ParamByte state, 2
  .else
    Set_ParamByte #ACTOR_STATE_ACTIVATED | ACTOR_STATE_ANIMATED, 2
  .endif

  jsr Actor_Add

  Pull_ParamsBytes 3
.endmacro
.proc Actor_Add

  ; Map parameters to constants
  dataLabel = params_labels
  xPos = params_bytes+0
  yPos = params_bytes+1
  state = params_bytes+2
  callback = params_labels+2

  ; Calculate Y index (actor_index * actor total bytes)
  lda actor_index;
  MUL_A #ACTOR_TOTAL_BYTES
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

  inc actor_index

  rts
.endproc

; --------------------------------------
; Run actors callback functions
.macro Actor_Run_Callback

  lda actor_array
  ldx #0                                ; Actor index counter
  ActorRunCallbackLoop:
    ; Multiple index by actor total bytes
    txa
    MUL_A #ACTOR_TOTAL_BYTES
    tay

    ; Move current actor pointer by ACTOR_TOTAL_BYTES amount
    adc #<actor_array
    sta actor_ptr

    ; Prepare actor callback pointer
    lda actor_array+ACTOR_CALLBACK_LO,y
    sta ptr
    lda actor_array+ACTOR_CALLBACK_HI,y
    sta ptr+1

    ; Set current actor index and jump to actor's callback
    Register_Push_All
    jmp (ptr)                           ; Jump to callback

    ; Once completed, switch to next actor if available
    AfterActorRunCallback:
      Register_Pull_All

      ; Increase counter
      inx
      txa
      cmp actor_index
      bne ActorRunCallbackLoop
.endmacro

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

.macro CurActor_SetMetasprite label
  Addr_SetPointer actor_ptr+ACTOR_DATA_PTR_LO, label, 1
.endmacro
