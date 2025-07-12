; Structure of delayed item
.struct ArrayItem
  totalSize .byte
  itemSize  .byte
.endstruct

; Each array starts with 2 bytes:
; First: Count (total amount of items in array, not total amount possible)
; Second: Item size (bytes per item)
; Following bytes: Items of item size
.macro Array_Init array, size
  lda #0
  sta array
  lda size
  sta array+1
.endmacro

.macro Array_Add array, bytes, indirect
  ;arrayCount = array+0
  ;itemSize = array+1

  ; Set initial array position
  lda array+0 ; count                   ; Load current array size
  DYN_MUL_A array+1                     ; Multiply by item size
  tax

  ; Push all bytes at the end of array
  ldy #0                                ; Start looping bytes
  @Array_Add_Loop:
    .ifnblank indirect
      lda (bytes), y                    ; Load byte in register A
    .else
      lda bytes, y                      ; Load byte in register A
    .endif
    sta array+2, x                      ; Store byte at array index + byte index
    iny
    inx
    tya
    cmp array+1 ; itemSize
    bne @Array_Add_Loop

  ; Item added, now increment array size
  inc array+0                           ; Increment array size
.endmacro

.macro Array_AddLabel array, label

  ; Set initial array position
  lda array+0 ; count                   ; Load current array size
  DYN_MUL_A array+1                     ; Multiply by item size
  tax

  ; Push all bytes at the end of array
  lda #<label                           ; Load byte in register A
  sta array+2, x                        ; Store byte at array index + byte index
  lda #>label                           ; Load byte in register A
  sta array+3, x                        ; Store byte at array index + byte index

  ; Item added, now increment array size
  inc array+0                           ; Increment array size
.endmacro

.macro Array_Remove array, index
  Array_SetPosition array, index
  Array_RotateLeft array, array+0
  dec array+0
.endmacro

.macro Array_CopyItem ptr1, ptr2, itemSize
  ldy #0
  :
    lda ptr1, y                         ; Load first array's byte
    sta ptr2, y                         ; Copy it to second array's byte
    iny
    tya
    cmp itemSize
    bne :-
.endmacro

.macro Array_SetPosition array, index
  lda index
  DYN_MUL_A array+1
  clc
  adc array+2
  sta array+2
  lda array+3
  adc #0
  sta array+3
.endmacro

.macro Array_RotateLeft array, copyCurrent

  ; Skip if only one item
  lda array+0
  cmp #1
  beq @Array_RotateLeft_Skip

    .ifnblank copyCurrent
    ; Copy current index to memory
    Array_CopyItem array+2, array_temp, array+1
    .endif

    ; Set next pointer
    lda array+3
    clc
    adc array+1
    sta ptr
    lda array+4
    adc #0
    sta ptr+1

    ; Rotate all other bytes to the left
    ldy #0                              ; Current byte index
    lda array+0
    DYN_MUL_A array+1
    tax                                 ; X: Total bytes to copy
    @Array_RotateLeft_Loop:

      lda (ptr), y                      ; Load first array's byte
      sta array+2, y                    ; Copy it to second array's byte

      iny
      dex
      bne @Array_RotateLeft_Loop

    .ifnblank copyCurrent
    ; Copy item from memory to last index
    Array_CopyItem array_temp, array+2, array+1
    .endif
  @Array_RotateLeft_Skip:
.endmacro

.macro ForEachArrayItem array, callback

  lda array
  beq ForEachArrayItemLoopEnd

  Addr_Set indirect_jsr_ptr, callback, 1

  ldx #0                                ; Actor index counter
  ForEachArrayItemLoop:

    ; Multiple index by actor total bytes
    txa
    sta array_index                     ; First, keep actor index
    DYN_MUL_A array+1
    tay

    ; Run callback function
    Register_PushAll
    jsr IndirectJSR
    Register_PullAll

    ; Counter may have been changed during JSR
    lda array
    beq ForEachArrayItemLoopEnd

    ; Increase counter
    inx
    txa
    cmp array
    bne ForEachArrayItemLoop

  ForEachArrayItemLoopEnd:
.endmacro