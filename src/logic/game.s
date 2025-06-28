InitializeGameVars:
  lda #5
  sta player_health
  lda #4
  sta player_hearths
  lda #1
  sta current_level
  lda #0
  sta total_keys

  PPU_LoadPalette Default_BG_Pal, $3F00, #16
  PPU_LoadPalette Default_Sprite_Pal, $3F10, #16

  rts
