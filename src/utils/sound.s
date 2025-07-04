SOUND_PLAYER_HURT = 1
SOUND_PLAYER_DEAD = 2
SOUND_PLAYER_STAIRS = 3
SOUND_PLAYER_SPIKES = 4
SOUND_OPEN_CHEST = 5

.scope Sound

  PlayerHurt:
    lda #SOUND_PLAYER_HURT
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts

  PlayerDead:
    lda #SOUND_PLAYER_DEAD
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts

  ; Play spikes sound effect
  Spikes:
    lda #SOUND_PLAYER_SPIKES
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts

  OpenChest:
    lda #SOUND_OPEN_CHEST
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts
.endscope
