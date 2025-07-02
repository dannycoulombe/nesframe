.include "level1/index.s"

Level1_Init:
  ;Actor_Add GnomeStillFront, PlayerCallback, #40, #88
  Actor_Add GnomeStillFront, PlayerCallback, #144, #176
  LoadMap Level1_MapTable, #0, Level1_ObjTable, Level1_ObjAmountTable
  rts

Level1_Frame:
  rts

Level1_NMI:
  rts