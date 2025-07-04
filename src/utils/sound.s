SOUND_PLAYER_STAIRS = 0
SOUND_PLAYER_HURT = 1
SOUND_PLAYER_DYING = 2
SOUND_PLAYER_SPIKES = 3
SOUND_OPEN_CHEST = 4

.scope Sound

  PlayerHurt:
    lda #SOUND_PLAYER_HURT
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts

  PlayerDead:
    lda #SOUND_PLAYER_DYING
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
