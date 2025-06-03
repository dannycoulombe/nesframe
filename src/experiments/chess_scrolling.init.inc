PPU_Clear_Nametable $2000, #TILE_FULL, #0
PPU_Clear_Nametable $2400, #TILE_FULL, #0

PPU_Write $3F01, #COLOR_MEDIUM_GRAY
PPU_Write $3F05, #COLOR_DARK_GRAY

; Nametable 1
PPU_Set_Addr $23C0
ldx #$40                                ; 32 iterations (x2 = 64 bytes)
:
    lda #%00010100
    sta PPU_DATA
    dex
    bne :-

; Nametable 2
PPU_Set_Addr $27C0
ldx #$40                                ; 32 iterations (x2 = 64 bytes)
:
    lda #%00010100
    sta PPU_DATA
    dex
    bne :-

