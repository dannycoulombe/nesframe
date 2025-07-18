; --------------------------------------
; Sub-routines
.segment "RAM"
treasure_metasprite:    .word 0

; --------------------------------------
; Sub-routines
.segment "CODE"

OpenTreasure:
  StartDelayedTable TreasureAnimTbl
  rts

ShowTreasureDialog:
  jsr Sound::TreasureFound
  OpenDialogMiddle #8, #2
  OnceDuringNMI PrintTreasureText
  rts

PrintTreasureText:
  PrintText $21EA, YouFoundTxt
  PrintText $220A, TheCaneTxt
  rts

.macro OpenTreasure metasprite
  Addr_Set treasure_metasprite, metasprite, 1
  jsr OpenTreasure
.endmacro

; --------------------------------------
; Delayed tables
.segment "RODATA"

TreasureAnimTbl:
  .byte 60, DELAYED_FLAG_DEFAULT
  .word ShowTreasureDialog
  .byte 0