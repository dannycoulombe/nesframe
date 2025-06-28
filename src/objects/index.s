.include "torch.s"
.include "chest.s"
.include "door.s"
.include "stairs.s"
.include "spikes.s"

ObjectInitTable:
  .word TorchObject_Init
  .word ChestObject_Init
  .word DoorObject_Init
  .word StairsObject_Init
  .word SpikesObject_Init

ObjectFrameTable:
  .word TorchObject_Frame
  .word ChestObject_Frame
  .word DoorObject_Frame
  .word StairsObject_Frame
  .word SpikesObject_Frame

ObjectNMITable:
  .word TorchObject_NMI
  .word ChestObject_NMI
  .word DoorObject_NMI
  .word StairsObject_NMI
  .word SpikesObject_NMI

ObjectCollisionTable:
  .word TorchObject_Collision
  .word ChestObject_Collision
  .word DoorObject_Collision
  .word StairsObject_Collision
  .word SpikesObject_Collision
