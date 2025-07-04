.scope Audio

  .proc EnableMusic
    ldx #<MusicData
    ldy #>MusicData
    lda #1
    jsr FamiToneInit
    rts
  .endproc

  .proc EnableSFX
    ldx #<SFXData
    ldy #>SFXData
    jsr FamiToneSfxInit
    rts
  .endproc

.endscope