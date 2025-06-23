.macro Array_Add ptr, arrSize, itemSize, bytes

  ; Set initial array position
  lda arrSize                           ; Load current array size
  MUL_A itemSize                        ; Multiply by item size
  clc
  adc ptr
  sta ptr                               ; Update ptr position

  ; Push all bytes at the end of array
  ldy #0
  ldx #0                                ; Start looping bytes
  @Array_Add_Loop:
    lda bytes, x                        ; Load byte in register A
    sta ptr, y                          ; Store byte at array index + byte index
    inc ptr
    inx
    cmp bytes
    bne @Array_Add_Loop

  ; Item added, now increment array size
  inc arrSize                           ; Increment array size
.endmacro

.macro Array_Remove ptr, index, size
  Array_RotateLeft ptr, index, size
  dec size
.endmacro

.macro Array_CopyItem arr1, arr2, bytes
  ldy #0
  @Array_SaveIndex:
    lda arr1, y                         ; Load first array's byte
    sta arr2, y                         ; Copy it to second array's byte
    iny
    cmp bytes
    bne @Array_SaveIndex
.endmacro

.macro Array_SetPosition ptr, index, size
  lda index
  MUL_A size
  clc
  adc ptr
  sta ptr
  lda ptr+1
  adc #0
  sta ptr+1
.endmacro

.macro Array_IncPosition ptr, size
  lda ptr
  clc
  adc size
  sta ptr
  lda ptr+1
  adc #0
  sta ptr+1
.endmacro

.macro Array_RotateLeft ptr, index, size, copyCurrent

  ; Set pointer position
  Array_SetPosition ptr, index, size

  .ifnblank copyCurrent
  ; Copy current index to memory
  Array_CopyItem ptr, temp, size
  .endif

  ; Rotate all other bytes to the left
  lda index
  tax
  @Array_RotateLeft_Loop:

    ; Move to next index
    Array_IncPosition ptr, size




    bne @Array_RotateLeft_Loop

  .ifnblank copyCurrent
  ; Copy item from memory to last index
  Array_SetPosition ptr, index, size
  Array_CopyItem temp, ptr, size
  .endif
.endmacro
