; Initializes the self-modifying JMP target with STA absolute instruction
; Example use:
;   SetSeqOffset $0300, SeqTarget
;
; Params:
;   addr   - starting destination address for sequential push
;   target - 3-byte buffer (usually in RAM) for self-modifying STA instruction
.macro SetSeqOffset addr, target
  lda #<addr                            ; Low byte of destination address
  sta target+1                          ; Store at operand low byte of STA
  lda #>addr                            ; High byte of destination address
  sta target+2                          ; Store at operand high byte of STA
  lda #$8D                              ; Opcode for STA absolute
  sta target                            ; Write to start of instruction
.endmacro

; Performs a sequential store using the STA at 'addr'
; It auto-increments the target address after each store.
;
; Usage:
;   lda value
;   SeqPush SeqTarget
;
; You MUST call SetSeqOffset first.
.macro SeqPush addr
  :
    sta addr                            ; Execute self-modified STA (e.g., STA $0300)
    inc :- + 1                          ; Increment low byte of address
    bne :+                              ; If it doesn't overflow, skip next
    inc :- + 2                          ; If low byte overflowed, increment high byte
  :
.endmacro
.macro SeqPushX addr
  :
    stx addr                            ; Execute self-modified STA (e.g., STA $0300)
    inc :- + 1                          ; Increment low byte of address
    bne :+                              ; If it doesn't overflow, skip next
    inc :- + 2                          ; If low byte overflowed, increment high byte
  :
.endmacro
.macro SeqPushY addr
  :
    sty addr                            ; Execute self-modified STA (e.g., STA $0300)
    inc :- + 1                          ; Increment low byte of address
    bne :+                              ; If it doesn't overflow, skip next
    inc :- + 2                          ; If low byte overflowed, increment high byte
  :
.endmacro

; Performs a sequential pull using the LDA at 'addr'
; It auto-increments the target address after each store.
;
; Usage:
;   lda value
;   SeqPull SeqTarget
;
; You MUST call SetSeqOffset first.
.macro SeqPull addr
  :
    lda addr                            ; Execute self-modified LDA (e.g., LDA $0300)
    inc :- + 1                          ; Increment low byte of address
    bne :+                              ; If it doesn't overflow, skip next
    inc :- + 2                          ; If low byte overflowed, increment high byte
  :
.endmacro
.macro SeqPullX addr
  :
    ldx addr                            ; Execute self-modified LDA (e.g., LDA $0300)
    inc :- + 1                          ; Increment low byte of address
    bne :+                              ; If it doesn't overflow, skip next
    inc :- + 2                          ; If low byte overflowed, increment high byte
  :
.endmacro
.macro SeqPullY addr
  :
    ldy addr                            ; Execute self-modified LDA (e.g., LDA $0300)
    inc :- + 1                          ; Increment low byte of address
    bne :+                              ; If it doesn't overflow, skip next
    inc :- + 2                          ; If low byte overflowed, increment high byte
  :
.endmacro