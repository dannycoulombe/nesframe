.include "level1/index.s"

; --------------------------------------
; Initialization
Level1_Init:

  LoadMap Level1_MapTable, #0, Level1_ObjTable

  ; Prepare actors
  Actor_Add GnomeStillFront, #40, #88, PlayerCallback
;  Actor_Add GnomeStillFront, #60, #120, PlayerCallback
;  Actor_Add TorchA, #184, #168, TorchCallback
;  Actor_Add RoundRock, #88, #120, RoundRockCallback, #ACTOR_STATE_ACTIVATED
;  Actor_Add MushroomA, #136, #72, RoundRockCallback, #ACTOR_STATE_ACTIVATED

  rts

; --------------------------------------
; Will be ran on each frame
Level1_Frame:

  rts

; --------------------------------------
; Will be ran on each NMI
Level1_NMI:

  rts