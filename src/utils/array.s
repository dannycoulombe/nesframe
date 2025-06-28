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

.macro Array_Add array, bytes
  count = array+0
  itemSize = array+1

  ; Set initial array position
  lda count                             ; Load current array size
  DYN_MUL_A itemSize                    ; Multiply by item size
  clc
  adc array+2
  sta array+2                           ; Update array position
  lda array+3
  adc #0
  sta array+3

  ; Push all bytes at the end of array
  ldy #0                                ; Start looping bytes
  @Array_Add_Loop:
    lda bytes, y                        ; Load byte in register A
    sta array+2, y                      ; Store byte at array index + byte index
    iny
    tya
    cmp itemSize
    bne @Array_Add_Loop

  ; Item added, now increment array size
  inc count                             ; Increment array size
.endmacro

.macro Array_Remove array, index
  Array_SetPosition array, index
  Array_RotateLeft array, count
  dec count
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
  DYN_MUL_A itemSize
  clc
  adc array+2
  sta array+2
  lda array+3
  adc #0
  sta array+3
.endmacro

.macro Array_RotateLeft array, copyCurrent
  arrSize = array+0

  ; Skip if only one item
  lda count
  cmp #1
  beq @Array_RotateLeft_Skip

    .ifnblank copyCurrent
    ; Copy current index to memory
    Array_CopyItem array+2, array_temp, itemSize
    .endif

    ; Set next pointer
    lda #array+3
    clc
    adc itemSize
    sta ptr
    lda #array+4
    adc #0
    sta ptr+1

    ; Rotate all other bytes to the left
    ldy #0                              ; Current byte index
    lda array+0
    DYN_MUL_A itemSize
    tax                                 ; X: Total bytes to copy
    @Array_RotateLeft_Loop:

      lda (ptr), y                      ; Load first array's byte
      sta array+2, y                    ; Copy it to second array's byte

      iny
      dex
      bne @Array_RotateLeft_Loop

    .ifnblank copyCurrent
    ; Copy item from memory to last index
    Array_CopyItem array_temp, array+2, itemSize
    .endif
  @Array_RotateLeft_Skip:
.endmacro
