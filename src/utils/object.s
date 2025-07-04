; Variable assignations
objAmountPtr = ptr2
objMountedPtr = ptr3
objFramePtr = ptr3
objNMIPtr = ptr3
objNMIOncePtr = ptr3
objCollisionPtr = ptr3
objInteractionPtr = ptr3

OBJ_X = 2
OBJ_Y = 3
OBJ_TILE_IDX = 4
OBJ_PPU_ADDR_LO = 2
OBJ_PPU_ADDR_HI = 3
OBJ_MEM_FLAG = 0
OBJ_MEM_FLAG_STATE_CHANGED = 1 << 7



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

.macro BNE_ObjFlagSet memory, flag, label
  ldy object_memory_index
  lda object_memory + memory, y
  and flag
  bne @BNE_ObjFlagSetEnd
    jmp label
  @BNE_ObjFlagSetEnd:
.endmacro

.macro BEQ_ObjFlagSet memory, flag, label
  ldy object_memory_index
  lda object_memory + memory, y
  and flag
  beq @BNE_ObjFlagSetEnd
    jmp label
  @BNE_ObjFlagSetEnd:
.endmacro

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
    SetDeepIndPtrFromTable indirect_jsr_ptr, ObjectMountedTable
    jsr IndirectJSR

    ; Next object index
    inc object_size

    jsr FetchNextObjBytes

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

FetchNextObjBytes:

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

  rts

; Y: Tile index
.proc InteractWithTileIdx
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
    SetDeepIndPtrFromTable indirect_jsr_ptr, ObjectInteractionTable

    ; If object collides with actor,
    ; JSR to object callback function
    lda object_ptr_index
    clc
    adc #OBJ_TILE_IDX
    tay
    lda (object_ptr), y
    cmp interaction_tile_idx
    bne @skipJsr
      jsr IndirectJSR
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
    SetDeepIndPtrFromTable indirect_jsr_ptr, ObjectFrameTable
    jsr IndirectJSR

    jsr FetchNextObjBytes

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
    SetDeepIndPtrFromTable indirect_jsr_ptr, ObjectNMITable

    ; JSR to object callback function
    jsr IndirectJSR

    BNE_ObjFlagSet OBJ_MEM_FLAG, #OBJ_MEM_FLAG_STATE_CHANGED, @noChange
      ObjMemSetBit OBJ_MEM_FLAG, OBJ_MEM_FLAG_STATE_CHANGED, 0

      ; Set object pointer
      ldy object_ptr_index
      lda (object_ptr), y
      tay
      SetDeepIndPtrFromTable indirect_jsr_ptr, ObjectNMIOnceTable

      ; JSR to object callback function
      jsr IndirectJSR
    @noChange:

    jsr FetchNextObjBytes

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
  RunObjectActorCollision_Loop:
    txa
    pha

    ; Set object pointer
    ldy object_ptr_index
    lda (object_ptr), y
    tay
    SetDeepIndPtrFromTable indirect_jsr_ptr, ObjectCollisionTable

    ; If object collides with actor,
    ; JSR to object callback function
    lda object_ptr_index
    clc
    adc #OBJ_TILE_IDX
    tay
    lda (object_ptr), y
    cmp metasprite_metatile_idx
    bne RunObjectActorCollision_SkipJSR
      jsr IndirectJSR
    RunObjectActorCollision_SkipJSR:

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
    bne RunObjectActorCollision_Loop
  rts
.endproc

.proc RunObjNMIOnce
  ObjMemSetBit OBJ_MEM_FLAG, OBJ_MEM_FLAG_STATE_CHANGED, 1
  rts
.endproc