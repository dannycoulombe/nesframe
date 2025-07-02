.include "player.s"
.include "torch.s"

; Register X contains damage amount
ActorDamageTable:
  .word Player_OnDamage
  .word Torch_OnDamage
