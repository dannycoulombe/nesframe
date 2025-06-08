; --------------------------------------
; Actor constants
ACTOR_DATA_PTR_LO = 0
ACTOR_DATA_PTR_HI = 1
ACTOR_X           = 2
ACTOR_Y           = 3
ACTOR_STATE       = 4                   ; 0--- ---- (A: Active?)
ACTOR_COUNTER     = 5
ACTOR_CALLBACK_LO = 6
ACTOR_CALLBACK_HI = 7
ACTOR_ANIM_DATA   = 8

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
.macro Actor_Add dataLabel, xPos, yPos, callback
  Set_Param_Label dataLabel, 0
  Set_Param_Label callback, 1
  Set_Param_Byte xPos, 0
  Set_Param_Byte yPos, 1
  jsr Actor_Add
.endmacro
.proc Actor_Add

  ; Map parameters to constants
  dataLabel = params_labels
  xPos = params_bytes
  yPos = params_bytes+1
  callback = params_labels+2

  ; Calculate Y index (actor_index * 8)
  lda actor_index
  asl
  asl
  asl
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
  lda #(1 << 7)                         ; Set active
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
  ldx #0
  :
    ; Multiple index by 8
    txa
    asl
    asl
    asl
    tay

    ; Move current actor pointer by 8 bytes
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
      bne :-
.endmacro

; --------------------------------------
; Push all actors to OAM
.macro Actor_Push_To_OAM
  Addr_Set oam_ptr, $0200, 1            ; Set OAM initial address

  ldx #0                                ; Actor index (up to 8)
  ldy #0                                ; Pointer address (index*8)
  @loop:
    lda actor_array + ACTOR_STATE, y    ; Get actor state
    and #(1 << 7)
    beq @skip                             ; Skip if not active

      ; Switch to next metasprite if animation completed
      tya
      pha
        ldy #0
        lda (sprite_ptr),y              ; Tile amount
        asl
        asl                             ; Multiple by 4 bytes
        tay
        lda (sprite_ptr+1), y           ; Animation data
        beq :+                          ; Skip if 0 (static)
        cmp actor_array + ACTOR_COUNTER, y
        bne :+                          ; Skip if not completed
          iny
        :

        ; Set actor low/high byte
        lda actor_array + ACTOR_DATA_PTR_LO, y
        sta sprite_ptr
        lda actor_array + ACTOR_DATA_PTR_HI, y
        sta sprite_ptr+1
      pla
      tay

      ; Set position
      lda actor_array + ACTOR_X, y
      sta metasprite_x
      lda actor_array + ACTOR_Y, y
      sta metasprite_y

      ; Push metasprite to OAM
      StackedXY_Call Metasprite_Set
    @skip:

    ; Get next actor index (index * 8)
    inx
    txa
    asl
    asl
    asl
    tay

    cpx actor_index
    bne @loop
.endmacro

.macro CurActor_IncVal ptr, index
  ldy index
  lda (ptr),y
  clc
  adc #1
  sta (ptr),y
.endmacro

.macro CurActor_DecVal ptr, index
  ldy index
  lda (ptr),y
  sec
  sbc #1
  sta (ptr),y
.endmacro

.macro CurActor_SetValue value, index
  ldy index
  lda value
  sta (actor_ptr),y
.endmacro

.macro CurActor_SetStateFlagAll value
  ldy #ACTOR_STATE
  lda value
  sta (actor_ptr),y
.endmacro

.macro CurActor_SetStateFlagBit bit_number, activate
  ldy #ACTOR_STATE
  lda (actor_ptr),y
  .if activate
    ora #(1 << bit_number)
  .else
    ora #~(1 << bit_number)
  .endif
  sta (actor_ptr),y
.endmacro

.macro CurActor_SetMetasprite label
  Addr_SetPointer actor_ptr+ACTOR_DATA_PTR_LO, label, 1
.endmacro
