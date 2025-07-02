.scope Sound

  ; Enable sound effects
  Enable:
    lda APU_STATUS
    ora #%00001111                      ; Enable pulse channel 1
    sta APU_STATUS
    rts

  PlayerDead:
    lda #%00000100      ; constant volume = 4, envelope off
    sta $400C

    lda #%00011110      ; white noise, lowest period ($0E)
    sta $400E

    lda #$08            ; ultra-short
    sta $400F
    rts

  PlayerHurt:

    ; Duty cycle = 50%, constant volume = 1, volume = 10
    lda #%01001010     ; $4A
    sta $4000          ; Pulse 1 volume/envelope

    ; Sweep: enabled, down, shift = 2 (fades down pitch)
    lda #%10001010     ; $8A
    sta $4001          ; Pulse sweep

    ; Timer low byte (sets pitch)
    lda #$E0
    sta $4002

    ; Timer high + length (short duration)
    lda #%00001000
    sta $4003
    rts

  ; Play spikes sound effect
  Spikes:
    lda #1
    sta APU_NOISE_VOL
    lda #0
    sta APU_NOISE_LO
    lda #$8F
    sta APU_NOISE_LEN
    rts
.endscope
