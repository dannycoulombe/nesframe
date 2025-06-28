.macro Register_Push_All
  txa
  pha
  tya
  pha
;  php
.endmacro

.macro Register_Pull_All
;  plp
  pla
  tay
  pla
  tax
.endmacro

.macro Register_Push_XY
  txa
  pha
  tya
  pha
;  php
.endmacro

.macro Register_Pull_XY
;  plp
  pla
  tay
  pla
  tax
.endmacro

.macro StackedXY_Call proc
  Register_Push_XY
  jsr proc
  Register_Pull_XY
.endmacro
