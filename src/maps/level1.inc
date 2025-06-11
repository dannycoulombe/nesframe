; Data declaration
Stage_Level1_Map: .incbin "maps/level1/map.nam"
Stage_Level1_Bg_Palette: .incbin "maps/level1/background.pal"
Stage_Level1_Sprite_Palette: .incbin "maps/level1/sprite.pal"

; Initialization
Stage_Level1_Init:

  ; Set level address labels
  Addr_Set scene_frame_addr, Stage_Level1_Frame, 1
  Addr_Set scene_nmi_addr, Stage_Level1_NMI, 1

  ; Load nametable
  PPU_Load_Screen Stage_Level1_Map, Stage_Level1_Bg_Palette
  PPU_Load_Palette Stage_Level1_Sprite_Palette, $3F10, #16

  ; Prepare actors
  Actor_Add GnomeStillFront, #40, #90, PlayerCallback
  Actor_Add RoundRock, #88, #120, RoundRockCallback, #ACTOR_STATE_ACTIVATED
  Actor_Add TorchA, #184, #167, TorchCallback
  Actor_Add MushroomA, #136, #72, RoundRockCallback, #ACTOR_STATE_ACTIVATED

  jmp AfterSceneInit

; Will be ran on each frame
Stage_Level1_Frame:

  ;PPU_Wait_VBlank                       ; Wait for next VBlank

  jmp AfterSceneFrame

; Will be ran on each NMI
Stage_Level1_NMI:

  jmp AfterSceneNMI
