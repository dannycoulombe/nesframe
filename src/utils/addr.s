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
.macro SetDeepIndPtrFromTable ptr, table, index, singleByte
  lda #<table
  sta table_ptr
  lda #>table
  sta table_ptr+1

  ; Get index from variable or Y
  .ifnblank index
  lda index
  .else
  tya
  .endif

  ; Multiply index by 2
  .ifblank singleByte
    asl
  .endif
  tay

  lda (table_ptr), y
  sta ptr
  iny
  lda (table_ptr), y
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
  .ifnblank immediate
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

.macro IndirectJSR label
  lda label
  sta indirect_jsr_ptr
  lda label+1
  sta indirect_jsr_ptr+1
  jsr IndirectJSR
.endmacro
.proc IndirectJSR
  jmp (indirect_jsr_ptr)
.endproc

; Y = index if not provided
.macro JSR_TableIndex table, index
  .ifblank index
    tay
  .else
    ldy index
  .endif
  SetDeepIndPtrFromTable indirect_jsr_ptr, table
  jsr IndirectJSR
.endmacro
