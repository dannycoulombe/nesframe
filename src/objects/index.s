.include "torch.s"
.include "chest.s"
.include "door.s"
.include "stairs.s"
.include "spikes.s"

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
