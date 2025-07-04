TorchObject_Mounted:
  LDX_ObjData #OBJ_X
  LDY_ObjData #OBJ_Y
  Actor_Add TorchA, TorchObject_ActorFrame
  rts

TorchObject_ActorFrame:
  Pointer_IncVal actor_ptr, #ACTOR_COUNTER
  rts

TorchObject_Frame:
  rts

TorchObject_NMIOnce:
  rts

TorchObject_NMI:
  rts

TorchObject_Interaction:
  rts

TorchObject_Collision:
  rts

TorchObject_Destroyed:
  rts
