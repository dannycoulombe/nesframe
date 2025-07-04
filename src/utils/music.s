MUSIC_DUNGEON = 0

.scope Music

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