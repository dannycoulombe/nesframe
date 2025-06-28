InitializeGameVars:
  lda #5
  sta player_health
  lda #4
  sta player_hearths
  lda #1
  sta current_level
  lda #0
  sta total_keys

  rts
