.macro AddHook array, label
  Array_AddLabel array, label
.endmacro

.macro RemoveHook array, index
  Array_Remove array, index
.endmacro

.macro ClearHooks array, total
  ldy #0
  lda #0
  ldx total
  :
    sta array, y
    iny
    dex
    bne :-
.endmacro

.macro RunHooks array

  lda array+2
  sta indirect_jsr_ptr
  lda array+3
  sta indirect_jsr_ptr+1

  lda array
  beq Hook_Run_End

  ldy #0
  Hook_Run_Loop:

    ; Run hook
    tya
    pha
    jsr IndirectJSR
    pla
    tay

    ; Fetch next pointer position
    inc indirect_jsr_ptr
    inc indirect_jsr_ptr
    iny
    cpy array
    bne Hook_Run_Loop
  Hook_Run_End:
.endmacro
