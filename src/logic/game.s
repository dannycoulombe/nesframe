InitializeGame:

  ; Initialize player values
  lda #1
  sta player_health
  lda #8
  sta player_hearths
  lda #5
  sta player_magic
  lda #8
  sta player_magic_slot
  lda #1
  sta current_level
  lda #0
  sta total_keys

  ; Load level
  jsr Level1_Init

  ; JUST A TEST
  Actor_Add Cane, NoOp, #152, #15
  Actor_Add TorchA, TorchCallback, #184, #15

  ; Play dungeon music
  lda #MUSIC_DUNGEON
  jsr Music::Play

  rts
