.macro Set_Param_Byte value, index
  lda value
  sta params_bytes+index
.endmacro

.macro Set_Param_Label label, index
  lda #<label
  sta params_labels+(index * 2)
  lda #>label
  sta params_labels+(index * 2)+1
.endmacro
