MUSIC_DUNGEON = 0

.scope Music

  ; A = Music ID
  .proc Play
    jsr FamiToneMusicPlay
    rts
  .endproc

.endscope