.macro Hook_Add array, bytes
  Addr_Set ptr, bytes, 1
  Array_Add array, ptr
.endmacro

.macro Hook_Remove array, index
  Array_Remove array, index
.endmacro

.macro Hook_Run array

  Addr_Set ptr, array+2, 0

  lda array
  beq @Hook_Run_End

  ldy #0
  @Hook_Run_Loop:

    ; Run hook
    tya
    pha
    IndirectJSR ptr
    pla
    tay

    ; Fetch next pointer position
    inc ptr
    inc ptr
    iny
    cpy array
    bne @Hook_Run_Loop
  @Hook_Run_End:
.endmacro
