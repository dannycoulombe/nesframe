CHEST_METATILE_OPENED = $1F*4
CHEST_MEM_FLAG_OPENED = 1 << 0
SPIKE_MEM_FLAG = 0

ChestObject_Mounted:
  rts

ChestObject_Frame:
  rts

ChestObject_NMIOnce:

  ; Change object metatile to open chest
  LDA_ObjData #OBJ_PPU_ADDR_LO
  sta temp
  LDA_ObjData #OBJ_PPU_ADDR_HI
  sta temp+1
  SetMetatile temp, #CHEST_METATILE_OPENED, 0, 1

  rts

ChestObject_NMI:
  rts

ChestObject_Interaction:

  ; Can only be opened when looking up
  lda player_ori_dir
  and #DIRECTION_UP
  beq :+

    BEQ_ObjFlagSet OBJ_MEM_FLAG, #CHEST_MEM_FLAG_OPENED, :+
      ObjMemSetBit OBJ_MEM_FLAG, CHEST_MEM_FLAG_OPENED, 1
      jsr Sound::OpenChest
      jsr RunObjNMIOnce
  :

  rts

ChestObject_Collision:
  rts

ChestObject_Destroyed:
  rts
