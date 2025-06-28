; --------------------------------------
; Initialization
Stage_Level1_Init:

;  Scene_Set Stage_Level1_Map, #2, Stage_Level1_Objects, Default_BG_Pal, Default_Sprite_Pal

  Addr_Set scene_map_ptr_jt, Stage_Level1_Map, 1

  ; Load nametable
  lda #0
  sta nametable_idx
  jsr PrintHeader
  PPU_Load_2x2_Screen LEVEL_OFFSET, #13, Stage_Level1_Map, Default_BG_Pal
  PPU_LoadPalette Default_Sprite_Pal, $3F10, #16

  ; Prepare actors
  Actor_Add GnomeStillFront, #40, #88, PlayerCallback
;  Actor_Add GnomeStillFront, #60, #120, PlayerCallback
;  Actor_Add TorchA, #184, #168, TorchCallback
;  Actor_Add RoundRock, #88, #120, RoundRockCallback, #ACTOR_STATE_ACTIVATED
;  Actor_Add MushroomA, #136, #72, RoundRockCallback, #ACTOR_STATE_ACTIVATED

  rts

; --------------------------------------
; Will be ran on each frame
Stage_Level1_Frame:

  rts

; --------------------------------------
; Will be ran on each NMI
Stage_Level1_NMI:

  rts

; --------------------------------------
; Map JumpTable
Stage_Level1_Map:
  .word Stage_Level1_Map_0
  .word Stage_Level1_Map_1
  .word Stage_Level1_Map_2
  .word Stage_Level1_Map_3
  .word Stage_Level1_Map_4
  .word Stage_Level1_Map_5
  .word Stage_Level1_Map_6
  .word Stage_Level1_Map_7

; --------------------------------------
; Maps data
Stage_Level1_Objects: .incbin "maps/level1/level1.obj"
Stage_Level1_Map_0: .incbin "maps/level1/level1_0.2x2"
Stage_Level1_Map_1: .incbin "maps/level1/level1_1.2x2"
Stage_Level1_Map_2: .incbin "maps/level1/level1_2.2x2"
Stage_Level1_Map_3: .incbin "maps/level1/level1_3.2x2"
Stage_Level1_Map_4: .incbin "maps/level1/level1_4.2x2"
Stage_Level1_Map_5: .incbin "maps/level1/level1_5.2x2"
Stage_Level1_Map_6: .incbin "maps/level1/level1_6.2x2"
Stage_Level1_Map_7: .incbin "maps/level1/level1_7.2x2"
