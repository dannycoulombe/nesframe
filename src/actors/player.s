PlayerCallback:

  ; Check warping
  jsr ScrollingCheck
  lda scrolling_direction
  beq :+
    rts
  :

  ; Check controls
  .include "player.controls.s"

  rts
