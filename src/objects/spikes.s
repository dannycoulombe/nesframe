SPIKE_DATA_DELAY = 5
SPIKE_DATA_INTERVAL = 6
SPIKE_MEM_COUNTER = 1
SPIKE_MEM_FLAG_RAISED = 1 << 0
SPIKE_METATILE_RAISED = $8C
SPIKE_METATILE_LOWER = $60

; --------------------------------------
; Hooks
SpikesObject_Mounted:

  ; Initialize with delay
  LDA_ObjData #SPIKE_DATA_DELAY
  STA_ObjMem SPIKE_MEM_COUNTER

  rts

.proc SpikesObject_Frame

  ; Jump to matching sub-routine if flag match count
  BNE_ObjFlagSet SPIKE_MEM_FLAG, #SPIKE_MEM_FLAG_RAISED, @else
    JSR_ObjMemEqualsVal SpikesObject_Lower, SPIKE_MEM_COUNTER, #60
    jmp @end
  @else:
    JSR_ObjMemEqualsData SpikesObject_Raise, SPIKE_MEM_COUNTER, #SPIKE_DATA_INTERVAL
  @end:

  ; Increment counter
  INC_ObjMem SPIKE_MEM_COUNTER

  rts
.endproc

SpikesObject_NMI:
  rts

.proc SpikesObject_NMIOnce

  ; Switch between lower and raised if state changed
  LDA_ObjData #OBJ_PPU_ADDR_LO
  sta temp
  LDA_ObjData #OBJ_PPU_ADDR_HI
  sta temp+1

  BNE_ObjFlagSet SPIKE_MEM_FLAG, #SPIKE_MEM_FLAG_RAISED, @else
    SetMetatile temp, #SPIKE_METATILE_RAISED, 0, 1
    rts
  @else:
    SetMetatile temp, #SPIKE_METATILE_LOWER, 0, 1

  rts
.endproc

SpikesObject_Interaction:
  rts

SpikesObject_Collision:
  BNE_ObjFlagSet SPIKE_MEM_FLAG, #SPIKE_MEM_FLAG_RAISED, @else
    lda #1
    jsr HurtCurrentActor
  @else:
  rts

SpikesObject_Destroyed:
  rts

; --------------------------------------
; Actions
SpikesObject_Raise:

  jsr Sound::Spikes
  jsr RunObjNMIOnce

  lda #0
  STA_ObjMem SPIKE_MEM_COUNTER
  ObjMemSetBit SPIKE_MEM_FLAG, SPIKE_MEM_FLAG_RAISED, 1

  rts

SpikesObject_Lower:

  jsr RunObjNMIOnce

  lda #0
  STA_ObjMem SPIKE_MEM_COUNTER
  ObjMemSetBit SPIKE_MEM_FLAG, SPIKE_MEM_FLAG_RAISED, 0

  rts
