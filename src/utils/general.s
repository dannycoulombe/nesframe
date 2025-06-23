.macro Set_ParamByte value, index
  lda value
  sta params_bytes+index
.endmacro

.macro Push_ParamsBytes amount
;  pha
  .if amount > 0
    lda params_bytes+0
    pha
  .endif
  .if amount > 1
    lda params_bytes+1
    pha
  .endif
  .if amount > 2
    lda params_bytes+2
    pha
  .endif
  .if amount > 3
    lda params_bytes+3
    pha
  .endif
;  php
.endmacro

.macro Pull_ParamsBytes amount
;  plp
  .if amount > 3
    pla
    sta params_bytes+3
  .endif
  .if amount > 2
    pla
    sta params_bytes+2
  .endif
  .if amount > 1
    pla
    sta params_bytes+1
  .endif
  .if amount > 0
    pla
    sta params_bytes+0
  .endif
;  pla
.endmacro

.macro Set_ParamLabel label, index
  lda #<label
  sta params_labels+(index * 2)
  lda #>label
  sta params_labels+(index * 2)+1
.endmacro

.macro MUL_A amount
  .if amount = 2
    asl
  .elseif amount = 4
    asl
    asl
  .elseif amount = 8
    asl
    asl
    asl
  .elseif amount = 16
    asl
    asl
    asl
    asl
  .else
    beq @MULAEnd
    stx temp
    tax
    lda #0
    @MULALoop:
      clc
      adc amount                          ; Add value to A
      dex                                 ; Decrement counter
      bne @MULALoop                       ; Branch if still positive
      ldx temp
    @MULAEnd:
  .endif
.endmacro
