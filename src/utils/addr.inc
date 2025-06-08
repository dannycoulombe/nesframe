; Set an immerdiate 2 bytes address
; Parameters:
; addr - Address
; value - Value to set
; immediate - Get immediate value?
.macro Addr_Set addr, value, immediate
  .if immediate
    lda #<value
    sta addr
    lda #>value
    sta addr+1
  .else
    lda value
    sta addr
    lda value+1
    sta addr+1
  .endif
.endmacro

; Set an indirect 2 bytes address
; Parameters:
; pointer - Address
; value - Value to set
; immediate - Get immediate value?
.macro Addr_SetPointer addr, value, immediate
  .if immediate
    ldy #1
    lda #>value
    sta (addr),y
    dey
    lda #<value
    sta (addr),y
  .else
    ldy #1
    lda value+1
    sta (addr),y
    dey
    lda value
    sta (addr),y
  .endif
.endmacro

; Clear address
; Parameters:
; addr - Address to clear
.macro Addr_Clear addr
  lda #0
  sta addr
  sta addr+1
.endmacro

; Run given address if not equals to 0
; Parameters:
; addr - Address
.macro Addr_BNE_Jump addr
  lda addr                        ; load low byte
  ora addr+1                      ; OR with high byte
  beq :+                          ; if both were 0, skip the jump
      jmp (addr)                  ; jump to the address
  :
.endmacro
