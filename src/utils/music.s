MUSIC_DUNGEON = 0

.scope Music

  .proc Pause
    lda #1
    jsr FamiToneMusicPause
    rts
  .endproc

  .proc Resume
    lda #0
    jsr FamiToneMusicPause
    rts
  .endproc

  .proc Stop
    jsr FamiToneMusicStop
    rts
  .endproc

  ; A = Music ID
  .proc Play
    jsr FamiToneMusicPlay
    rts
  .endproc

.endscope