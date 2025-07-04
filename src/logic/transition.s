.macro DoTransition type, callback
  .ifblank callback
    lda #0
    sta transition_callback
    sta transition_callback+1
  .else
    Addr_Set transition_callback, callback, 1
  .endif
  ldx type
  jsr StartTransition
.endmacro

CheckTransition:
  JSR_TableIndex TransitionTable, transition_type
  rts

StartTransition:
  stx transition_type
  lda #0
  sta transition_type_index
  rts

EndTransition:
  lda #0
  sta transition_type

  lda transition_callback+1             ; Just check high-byte
  bne :+
    rts
  :

  IndirectJSR transition_callback

  rts

.scope Transition

  NoTransition:
    rts

  FadeIn:
    rts

  FadeOut:
    ; Every 32 frames
    lda frame_count
    and #MOD_32
    bne @fadeOutEnd
      inc transition_type_index

      ; Write palette to PPU address
      PPU_Set_Addr $3F00
      SetDeepIndPtrFromTable ptr, FadeOutTable, transition_type_index
      ldy #0
      @loopForEach:
        lda (ptr), y
        sta PPU_DATA
        iny
        cpy #16
        bne @loopForEach

      ; Stop transition after end of table
      lda transition_type_index
      cmp #3
      bne :+
        jsr EndTransition
    @fadeOutEnd:
    rts
.endscope

; --------------------------------------
; Transition table
TransitionTable:
  .word Transition::NoTransition
  .word Transition::FadeIn
  .word Transition::FadeOut

; --------------------------------------
; Fade in table
FadeInTable:
  .word BlackPal
  .word BgPalDim2
  .word BgPalDim1
  .word DefaultBGPal

; --------------------------------------
; Fade out table
FadeOutTable:
  .word DefaultBGPal
  .word BgPalDim1
  .word BgPalDim2
  .word BlackPal
