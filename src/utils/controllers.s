.scope Controller

  ; Read all inputs and push the information
  ; into ZP variables
  Read:

    ; Save to last buttons
    lda buttons
    sta last_buttons

    ; Strobe/Latch the controller to capture button states
    lda #$01
    sta CONTROLLER_1                      ; Tells the controller to take a snapshot
    lda #$00
    sta CONTROLLER_1                      ; Set the controller back to read mode

    ; Initialize buttons
    lda #0
    sta buttons

    ; Read all 8 bits of the controller snapshot
    ldx #8
    :
      clc                                 ; Clear the carry (since we're using ROL)
      lda CONTROLLER_1
      lsr A                               ; Shift right, bit 0 goes into Carry
      rol buttons                         ; Rotate Carry into buttons variable
      dex
      bne :-

    ; Calculate newly pressed buttons
    lda last_buttons
    eor #$FF                              ; Invert all bits from last_buttons
    and buttons                           ; Compare (AND) with current buttons
    sta pressed_buttons

    rts
.endscope
