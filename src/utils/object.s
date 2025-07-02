; Variable assignations
objAmountPtr = ptr2
objMountedPtr = ptr3
objFramePtr = ptr3
objNMIPtr = ptr3
objCollisionPtr = ptr3

OBJ_X = 2
OBJ_Y = 3
OBJ_TILE_IDX = 4
OBJ_PPU_ADDR_LO = 2
OBJ_PPU_ADDR_HI = 3

; Read all objects from nametable index
.macro ApplyObjectsToNametable objTbl, objAmountTbl
  SetAbsPtrFromTable objAmountPtr, objAmountTbl
  SetDeepIndPtrFromTable object_ptr, objTbl, nametable_idx
  jsr ApplyObjectsToNametable
.endmacro
.proc ApplyObjectsToNametable
  jsr CleanAllObjectsMemory

  lda #0
  sta object_ptr_index

  ldy nametable_idx
  lda (objAmountPtr), y
  tax

  @PushAllObjectsToMemory_Loop:
    txa
    pha

    ldy object_ptr_index
    lda (object_ptr), y
    tay
    SetDeepIndPtrFromTable objMountedPtr, ObjectMountedTable
    IndirectJSR objMountedPtr

    ; Next object index
    inc object_size

    ; Move object pointer index to next 8 bytes
    lda object_ptr_index
    clc
    adc #8
    sta object_ptr_index

    pla
    tax
    dex
    bne @PushAllObjectsToMemory_Loop

  rts
.endproc

CleanAllObjectsMemory:
  ldx #0
  lda #0
  @CleanAllObjectsMemory_Loop:
    sta object_memory, x
    inx
    cpx #32
    bne @CleanAllObjectsMemory_Loop
  rts

RunObjectsFrameCallback:
  ldx object_size
  lda #0
  sta object_ptr_index
  sta object_memory_index
  @RunObjectsFrameCallback_Loop:
    txa
    pha

    ldy object_ptr_index
    lda (object_ptr), y
    tay
    SetDeepIndPtrFromTable objFramePtr, ObjectFrameTable
    IndirectJSR objFramePtr

    ; Move object pointer index to next 8 bytes
    lda object_ptr_index
    clc
    adc #8
    sta object_ptr_index

    ; Move object memory index to next 4 bytes
    lda object_memory_index
    clc
    adc #4
    sta object_memory_index

    pla
    tax
    dex
    bne @RunObjectsFrameCallback_Loop
  rts

.proc RunObjectsNMICallback
  ldx object_size
  lda #0
  sta object_ptr_index
  sta object_memory_index
  @loop:
    txa
    pha

    ; Set object pointer
    ldy object_ptr_index
    lda (object_ptr), y
    tay
    SetDeepIndPtrFromTable objNMIPtr, ObjectNMITable

    ; JSR to object callback function
    IndirectJSR objNMIPtr

    ; Move object pointer index to next 8 bytes
    lda object_ptr_index
    clc
    adc #8
    sta object_ptr_index

    ; Move object memory index to next 4 bytes
    lda object_memory_index
    clc
    adc #4
    sta object_memory_index

    pla
    tax
    dex
    bne @loop
  rts
.endproc

; Should be ran from current actor context
.proc RunObjectActorCollision
  ldx object_size
  lda #0
  sta object_ptr_index
  sta object_memory_index
  @loop:
    txa
    pha

    ; Set object pointer
    ldy object_ptr_index
    lda (object_ptr), y
    tay
    SetDeepIndPtrFromTable objCollisionPtr, ObjectCollisionTable

    ; If object collides with actor,
    ; JSR to object callback function
    lda object_ptr_index
    clc
    adc #OBJ_TILE_IDX
    tay
    lda (object_ptr), y
    cmp metasprite_metatile_idx
    bne @skipJsr
      IndirectJSR objCollisionPtr
    @skipJsr:

    ; Move object pointer index to next 8 bytes
    lda object_ptr_index
    clc
    adc #8
    sta object_ptr_index

    ; Move object memory index to next 4 bytes
    lda object_memory_index
    clc
    adc #4
    sta object_memory_index

    pla
    tax
    dex
    bne @loop
  rts
.endproc

.macro LDA_ObjData index
  SetObjDataY index
  lda (object_ptr), y
.endmacro

.macro LDY_ObjData index
  LDA_ObjData index
  tay
.endmacro

.macro LDX_ObjData index
  LDA_ObjData index
  tax
.endmacro

.macro SetObjDataY index
  lda object_ptr_index
  clc
  adc index
  tay
.endmacro

.macro SetObjDataX index
  lda object_ptr_index
  clc
  adc index
  tax
.endmacro

.macro LDA_ObjMem index
  ldy object_memory_index
  lda object_memory + index, y
.endmacro

.macro STA_ObjMem index
  ldy object_memory_index
  sta object_memory + index, y
.endmacro

.macro ObjMemSetBit index, memory, flag
  ldy object_memory_index
  lda object_memory + index, y

  .if flag = 1
    ora #(memory)
  .else
    and #<~(memory)
  .endif

  sta object_memory + index, y
.endmacro

.macro INC_ObjMem index
  LDA_ObjMem index
  clc
  adc #1
  sta object_memory + index, y
.endmacro

.macro JSR_ObjMemEqualsData label, memory, data
  LDA_ObjData data
  sta temp

  LDA_ObjMem memory
  cmp temp
  bne :+
    jsr label
  :
.endmacro

.macro JSR_ObjMemEqualsVal label, memory, value
  LDA_ObjMem memory
  ldy object_ptr_index
  cmp value
  bne :+
    jsr label
  :
.endmacro

.macro JSR_ObjMemFlag label, memory, flag
  LDA_ObjMem memory
  ldy object_ptr_index
  and flag
  bne :+
    jsr label
  :
.endmacro

.macro BEQ_ObjFlagSet memory, flag, label
  ldy object_memory_index
  lda object_memory + memory, y
  and flag
  bne :+
    jmp label
  :
.endmacro