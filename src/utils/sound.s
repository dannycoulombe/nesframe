SOUND_PLAYER_STAIRS = 0
SOUND_PLAYER_HURT = 1
SOUND_PLAYER_DYING = 2
SOUND_PLAYER_SPIKES = 3
SOUND_OPEN_LOCK = 4
SOUND_TREASURE = 5
SOUND_TEXT = 6
SOUND_PAUSE_IN = 7
SOUND_PAUSE_OUT = 8

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

  OpenLock:
    lda #SOUND_OPEN_LOCK
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts

  TreasureFound:
    lda #SOUND_TREASURE
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts

  PauseIn:
    lda #SOUND_PAUSE_IN
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts

  PauseOut:
    lda #SOUND_PAUSE_OUT
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    rts
.endscope
