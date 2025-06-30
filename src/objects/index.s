.include "torch.s"
.include "chest.s"
.include "door.s"
.include "stairs.s"
.include "spikes.s"

ObjectMountedTable:
  .word TorchObject_Mounted
  .word ChestObject_Mounted
  .word DoorObject_Mounted
  .word StairsObject_Mounted
  .word SpikesObject_Mounted

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

ObjectInteractionTable:
  .word TorchObject_Interaction
  .word ChestObject_Interaction
  .word DoorObject_Interaction
  .word StairsObject_Interaction
  .word SpikesObject_Interaction

ObjectCollisionTable:
  .word TorchObject_Collision
  .word ChestObject_Collision
  .word DoorObject_Collision
  .word StairsObject_Collision
  .word SpikesObject_Collision

ObjectDestroyedTable:
  .word TorchObject_Destroyed
  .word ChestObject_Destroyed
  .word DoorObject_Destroyed
  .word StairsObject_Destroyed
  .word SpikesObject_Destroyed
