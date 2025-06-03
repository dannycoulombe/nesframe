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

