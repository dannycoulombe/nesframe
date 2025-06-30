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

.macro SetIndPtrFromTable ptr, table
  ldy #1
  lda #>table
  sta (ptr),y
  dey
  lda #<table
  sta (ptr),y
.endmacro

.macro MovePtrToNextYBytes ptr, amount
  .ifnblank amount
  lda amount
  .else
  tya
  .endif
  clc
  adc ptr
  sta ptr
  lda ptr+1
  adc #0
  sta ptr+1
.endmacro

; If index blank, use register Y
.macro SetDeepIndPtrFromTable ptr, table, index
  lda #<table
  sta tablePtr
  lda #>table
  sta tablePtr+1

  ; Multiply index by 2
  .ifnblank index
  lda index
  .else
  tya
  .endif
  asl
  tay

  lda (tablePtr), y
  sta ptr
  iny
  lda (tablePtr), y
  sta ptr+1
.endmacro

.macro SetAbsPtrFromTable ptr, table
  ldy #1
  lda #>table
  sta ptr,y
  dey
  lda #<table
  sta ptr,y
.endmacro

; Set an indirect 2 bytes address
; Parameters:
; pointer - Address
; value - Value to set
; immediate - Get immediate value?
.macro Addr_SetPointer addr, value, immediate
  tya
  pha
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
  pla
  tay
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

.macro Pointer_IncVal ptr, index
  tya
  pha
  ldy index
  lda (ptr),y
  clc
  adc #1
  sta (ptr),y
  pla
  tay
.endmacro

.macro Pointer_DecVal ptr, index
  tya
  pha
  ldy index
  lda (ptr),y
  sec
  sbc #1
  sta (ptr),y
  pla
  tay
.endmacro

.macro Pointer_SetVal ptr, value, index
  tya
  pha
  ldy index
  lda value
  sta (ptr),y
  pla
  tay
.endmacro

.macro IndirectJSR ptr
  lda #>:+
  pha
  lda #<:+
  pha
  jmp (ptr)
  pla
  :
  pla
.endmacro

