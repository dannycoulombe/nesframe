.macro Hook_Add array, bytes
  Array_Add array, frame_hooks_size, #2, bytes
.endmacro

.macro Hook_Remove array, index
  Array_Remove array, index, frame_hooks_size
.endmacro

.macro Hook_Run array
  ldy #0
  @Hook_Run_Loop:

    ; Run hook
    tya
    pha
    jsr (array), y
    pla
    tay

    ; Fetch next pointer position
    inc array
    inc array
    dey
    cmp frame_hooks_size
    bne @Hook_Run_Loop
.endmacro
