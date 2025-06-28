.macro Object_ApplyToScreen objectsLabel
  SetPtrFromTable ptr, objectsLabel
  jsr ReadAndApplyScreenObjects
.endmacro

ReadAndApplyScreenObjects:

  rts