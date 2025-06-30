.scope Sound

  ; Enable sound effects
  Enable:
    lda APU_STATUS
    ora #%00000001                      ; Enable pulse channel 1
    sta APU_STATUS

    rts

  FallingSpike:
    lda #%00100000         ; volume envelope decay
    sta APU_NOISE_VOL

    lda #%00000101         ; random mode, period index 5 (~mid)
    sta APU_NOISE_LO

    lda #$10               ; short duration
    sta APU_NOISE_LEN
    rts

  RisingSpike:
    lda #%00110000         ; constant volume envelope
    sta APU_NOISE_VOL

    lda #%10000001         ; loop noise, low period (~buzzier)
    sta APU_NOISE_LO

    lda #$20               ; longer duration
    sta APU_NOISE_LEN
    rts
.endscope
