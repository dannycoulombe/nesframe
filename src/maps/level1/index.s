; --------------------------------------
; Map Table
Level1_MapTable:
  .word Level1_Map0
  .word Level1_Map1
  .word Level1_Map2
  .word Level1_Map3
  .word Level1_Map4
  .word Level1_Map5
  .word Level1_Map6
  .word Level1_Map7

; --------------------------------------
; Object Table
Level1_ObjTable:
  .word Level1_Obj0
  .word Level1_Obj1
  .word Level1_Obj2
  .word Level1_Obj3
  .word Level1_Obj4
  .word Level1_Obj5
  .word Level1_Obj6
  .word Level1_Obj7

; --------------------------------------
; Total amount of objects per nametable
Level1_ObjAmountTable:
  .byte 6
  .byte 2
  .byte 2
  .byte 0
  .byte 7
  .byte 3
  .byte 2
  .byte 0

; --------------------------------------
; Objects data
Level1_Obj0: .incbin "level1_0.obj"
Level1_Obj1: .incbin "level1_1.obj"
Level1_Obj2: .incbin "level1_2.obj"
Level1_Obj3: .incbin "level1_3.obj"
Level1_Obj4: .incbin "level1_4.obj"
Level1_Obj5: .incbin "level1_5.obj"
Level1_Obj6: .incbin "level1_6.obj"
Level1_Obj7: .incbin "level1_7.obj"

; --------------------------------------
; Maps data
Level1_Map0: .incbin "level1_0.2x2"
Level1_Map1: .incbin "level1_1.2x2"
Level1_Map2: .incbin "level1_2.2x2"
Level1_Map3: .incbin "level1_3.2x2"
Level1_Map4: .incbin "level1_4.2x2"
Level1_Map5: .incbin "level1_5.2x2"
Level1_Map6: .incbin "level1_6.2x2"
Level1_Map7: .incbin "level1_7.2x2"
