; Data declaration
Stage_Level1_Map: .incbin "maps/level1/map.nam"
Stage_Level1_Bg_Palette: .incbin "maps/level1/background.pal"
Stage_Level1_Sprite_Palette: .incbin "maps/level1/sprite.pal"

; Initialization
Stage_Level1_Init:

  ; Set level address labels
  Addr_Set scene_frame_addr, Stage_Level1_Frame
  Addr_Set scene_nmi_addr, Stage_Level1_NMI

  ; Disable rendering (this code contains too many cycles)
  lda #0
  sta PPU_CTRL
  sta PPU_MASK

  ; Load nametable
  PPU_Load_Screen Stage_Level1_Map, Stage_Level1_Bg_Palette

  ; Add player on screen
  PPU_Load_Palette Stage_Level1_Sprite_Palette, $3F10, #16
  Metasprite_Set GnomeStillFront, #40, #104, $0200

  ; Re-enable rendering
  PPU_Set_CtrlMask #%10001000, #%00011110

  jmp (scene_return_label)

; Will be ran on each frame
Stage_Level1_Frame:
  jmp (scene_return_label)

; Will be ran on each NMI
Stage_Level1_NMI:

  jmp (scene_return_label)
