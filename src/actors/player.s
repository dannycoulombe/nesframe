PlayerCallback:

  ; Check warping
  jsr WarpingCheck
  lda warping_direction
  beq :+
    rts
  :

  ; Check controls
  .include "player.controls.s"

  rts
