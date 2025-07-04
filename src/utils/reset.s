;------------------------------------------------------------------------------
; Macro to initialize the NES by disabling rendering and clearing RAM values
.macro Reset_NES
  sei                                   ; Disable all IRQ interrupts
  cld                                   ; Clear decimal mode (not supported by the NES)
  ldx #$FF
  txs                                   ; Initialize the stack pointer at address $FF

  inx                                   ; Increment X, causing a rolloff from $FF to $00
  stx PPU_CTRL                          ; Disable NMI
  stx PPU_MASK                          ; Disable rendering (masking background and sprites)
  stx $4010                             ; Disable DMC IRQs

  lda #$40
  sta $4017                             ; Disable APU frame IRQ

  bit PPU_STATUS                        ; Read from PPU_STATUS to reset the VBlank flag
  Wait1stVBlank:                        ; Wait for the first VBlank from the PPU
  bit PPU_STATUS                        ; Perform a bit-wise check with the PPU_STATUS port
  bpl Wait1stVBlank                     ; Loop until bit-7 (sign bit) is 1 (inside VBlank)

  txa                                   ; A = 0
  Clear_RAM

  Wait2ndVBlank:                        ; Wait for the second VBlank from the PPU
  bit PPU_STATUS                        ; Perform a bit-wise check with the PPU_STATUS port
  bpl Wait2ndVBlank                     ; Loop until bit-7 (sign bit) is 1 (inside VBlank)

  ; Reset execution state
  sta execution_state
  sta scrolling_direction
.endmacro

.macro Clear_RAM
ClearRAM:
  sta $0000,x                           ; Zero RAM addresses from $0000 to $00FF
  sta $0100,x                           ; Zero RAM addresses from $0100 to $01FF

  lda #$FF                              ; We cannot load $0200-$02FF (OAM) with zero
  sta $0200,x                           ; So we load it with $FF (all sprites off-screen)

  lda #0                                ; And we proceed to zero the next ranges
  sta $0300,x                           ; Zero RAM addresses from $0300 to $03FF
  sta $0400,x                           ; Zero RAM addresses from $0400 to $04FF
  sta $0500,x                           ; Zero RAM addresses from $0500 to $05FF
  sta $0600,x                           ; Zero RAM addresses from $0600 to $06FF
  sta $0700,x                           ; Zero RAM addresses from $0700 to $07FF
  inx
  bne ClearRAM
.endmacro
