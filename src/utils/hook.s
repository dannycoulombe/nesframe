.macro AddHook array, label
  Array_AddLabel array, label
.endmacro

.macro RemoveHook array, index
  Array_Remove array, index
.endmacro

.macro ClearHooks array, total
  lda array
  beq ClearHooksEnd

  ldx #0                                ; Array index counter
  ClearHooksLoop:

    ; Multiple index by array total bytes
    txa
    pha
    sta array_index                     ; First, keep array index
    DYN_MUL_A array+1
    tay
    iny
    iny

    ; Clear bytes
    ldx array+1
    @ClearHooksByteLoop:
      lda #0
      sta array, y
      iny
      txa
      dex
      bne @ClearHooksByteLoop

    ; Increase counter
    pla
    tax
    inx
    txa
    cmp array
    bne ClearHooksLoop

  ClearHooksEnd:

  ; Reset array item to zero
  lda #0
  sta array
.endmacro

.macro RunHooks array

  lda array
  beq Hook_Run_End

  ldy array
  ldx #0
  Hook_Run_Loop:

    ; Fetch next pointer position
    txa
    clc
    adc array+1
    tax

    ; Fetch pointer
    lda array, x
    sta indirect_jsr_ptr
    lda array+1, x
    sta indirect_jsr_ptr+1

    ; Run hook
    Register_Push_XY
    jsr IndirectJSR
    Register_Pull_XY

    dey
    bne Hook_Run_Loop
  Hook_Run_End:
.endmacro
