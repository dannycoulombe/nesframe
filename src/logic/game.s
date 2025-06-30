InitializeGame:
  lda #9
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

  jsr Level1_Init

  rts
