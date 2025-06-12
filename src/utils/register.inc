.macro Register_Push_All
  pha
  txa
  pha
  tya
  pha
  php
.endmacro

.macro Register_Pull_All
  plp
  pla
  tay
  pla
  tax
  pla
.endmacro

.macro Register_Push_XY
  pha
  txa
  pha
  tya
.endmacro

.macro Register_Pull_XY
  tay
  pla
  tax
  pla
.endmacro

.macro StackedXY_Call proc
  Register_Push_XY
  jsr proc
  Register_Pull_XY
.endmacro
