.scope Sound

    ; Enable sound effects
    Enable:
        lda APU_STATUS
        ora #%00000001                  ; Enable pulse channel 1
        sta APU_STATUS

        rts

    ; Play a fall sound effect
    Fall:
        lda #%10111111                  ; Duty 10 (50%), constant volume, full volume
        sta PULSE1_CONTROL

        lda #%10000100                  ; Falling bomb effect
        sta PULSE1_SWEEP

        lda #%11110000
        sta PULSE1_LOW

        lda #%00001000
        sta PULSE1_HIGH

        rts

    ; Play a rising sound effect
    Rise:
        lda #%10111111                  ; Duty 10 (50%), constant volume, full volume
        sta PULSE1_CONTROL

        lda #%10001100                  ; Rising effect
        sta PULSE1_SWEEP

        lda #%11110000
        sta PULSE1_LOW

        lda #%00001000
        sta PULSE1_HIGH

        rts
.endscope
