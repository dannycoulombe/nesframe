; --------------------------------------
; Declarations

; Constants
DELAYED_TOTAL = 8
DELAYED_FLAG_EVERY_FRAME = 1
DELAYED_FLAG_DEFAULT = 0

; Structure of delayed item
.struct DelayedItem
  index     .byte
  counter   .byte
  memory    .word
  table     .word
.endstruct

; Structure of delayed table item
.struct DelayedTblItem
  delay     .byte
  flag      .byte
  label     .word
.endstruct

; Mapping
delayed_index = array_index
delayed_total = delayed_array
delayed_item = delayed_array + 2
delayed_item_table = delayed_item + DelayedItem::table
delayed_item_index = delayed_item + DelayedItem::index
delayed_item_counter = delayed_item + DelayedItem::counter
delayed_item_memory = delayed_item + DelayedItem::memory

; --------------------------------------
.segment "ZEROPAGE"
  delayed_tbl_idx_ptr:         .word 0
  delayed_tbl_idx_label_ptr:   .word 0

; --------------------------------------
.segment "RAM"
  delayed_tbl_index:  .byte 0           ; Current table index
  delayed_array:      .res 2 + (.sizeof(DelayedItem) * DELAYED_TOTAL), 0 ; DELAYED_TOTAL items possible (+2 bytes for array instance)

; --------------------------------------
; Initialization
.segment "CODE"

; --------------------------------------
; Macros
.macro StartDelayedTable table, memory

  ; Set initial array position
  lda delayed_array+0 ; count           ; Load current array size
  DYN_MUL_A delayed_array+1             ; Multiply by item size
  tax

  ; Push indirect memory address
  .ifnblank memory
  lda #<memory                          ; Load byte in register A
  sta delayed_item_memory, x            ; Store byte at array index + byte index
  lda #>memory                          ; Load byte in register A
  sta delayed_item_memory + 1, x        ; Store byte at array index + byte index
  .endif

  ; Push indirect table address
  lda #<table                           ; Load byte in register A
  sta delayed_item_table, x             ; Store byte at array index + byte index
  lda #>table                           ; Load byte in register A
  sta delayed_item_table + 1, x         ; Store byte at array index + byte index

  ; Item added, now increment array size
  inc delayed_total                     ; Increment array size

  ; Push first counter to memory
  lda table + DelayedTblItem::delay
  sta delayed_item_counter, x
.endmacro

; --------------------------------------
; Sub-routines
RunAllDelayedItems:
  ForEachArrayItem delayed_array, OnDelayedItem
  rts

OnDelayedItem:

  ; Update current table index pointer
  ldx delayed_index
  lda delayed_item + DelayedItem::table, x
  sta delayed_tbl_idx_ptr
  lda delayed_item + DelayedItem::table+1, x
  sta delayed_tbl_idx_ptr+1

  ; Set current table index
  lda delayed_item + DelayedItem::index, x
  DYN_MUL_A #.sizeof(DelayedTblItem)
  sta delayed_tbl_index

  ; Update current table index label pointer
  clc
  adc #DelayedTblItem::label
  tay
  lda (delayed_tbl_idx_ptr), y
  sta delayed_tbl_idx_label_ptr
  iny
  lda (delayed_tbl_idx_ptr), y
  sta delayed_tbl_idx_label_ptr+1

  ; Decrease counter by 1 and redirect to next step
  ldx delayed_index
  lda delayed_item + DelayedItem::counter, x
  tay
  beq :+ ; Only execute if not zero
    dey
    tya
    sta delayed_item + DelayedItem::counter, x
    bne OnDelayedTblItemNotCompleted
    beq OnDelayedTblItemCompleted
  :

  rts

OnDelayedTblItemNotCompleted:

  ; Check flag if needs to be ran every frame
  LdaPtrOffset delayed_tbl_idx_ptr, delayed_tbl_index, #DelayedTblItem::flag
  and #DELAYED_FLAG_EVERY_FRAME
  beq :+
    jsr RunDelayedItem
  :

  rts

OnDelayedTblItemCompleted:

  ; Run indirect callback
  jsr RunDelayedItem

  ; Update index (pending)
  ldx delayed_index
  lda delayed_item + DelayedItem::index, x
  clc
  adc #1
  pha

  ; Check if next item contains termination byte (0)
  LdaPtrOffset delayed_tbl_idx_ptr, delayed_tbl_index, #DelayedTblItem::delay + .sizeof(DelayedTblItem)
  tay
  bne :+
    jsr TerminateDelayedItem
    pla
    rts
  :

  ; It's now worth updating the index (completed)
  pla
  sta delayed_item + DelayedItem::index, x

  ; Update counter
  tya
  sta delayed_item + DelayedItem::counter, x

  rts

RunDelayedItem:
  IndirectJSR delayed_tbl_idx_label_ptr
  rts

TerminateDelayedItem:
  Array_Remove delayed_array, delayed_index
  rts
