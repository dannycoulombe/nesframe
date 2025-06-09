; --------------------------------------
; PPU
PPU_CTRL              = $2000           ; Controls NMI, sprite size/pattern, background pattern, increment mode
PPU_MASK              = $2001           ; Controls rendering: background/sprite enable, color effects, clipping
PPU_STATUS            = $2002           ; Contains sprite overflow, sprite 0 hit, and vblank status flags
OAM_ADDR              = $2003           ; Set the address in OAM memory to read/write through $2004
OAM_DATA              = $2004           ; Read/write OAM (sprite) data. Address auto-increments after write
PPU_SCROLL            = $2005           ; Sets the scroll position, written twice: X scroll, then Y scroll
PPU_ADDR              = $2006           ; Sets PPU address for reading/writing VRAM. Written twice: high, low
PPU_DATA              = $2007           ; Read/write VRAM data. Address auto-increments after access
PPU_OAM_DMA           = $4014           ; Initiates DMA transfer of 256 bytes from CPU to OAM memory

; --------------------------------------
; OAM 
OAM_FLIP_H            = 1 << 6
OAM_FLIP_V            = 1 << 7
FLAG_N                = 1 << 7

; --------------------------------------
; CONTROLLERS
CONTROLLER_1          = $4016
CONTROLLER_2          = $4017

BUTTON_A              = 1 << 7
BUTTON_B              = 1 << 6
BUTTON_SELECT         = 1 << 5
BUTTON_START          = 1 << 4
BUTTON_UP             = 1 << 3
BUTTON_DOWN           = 1 << 2
BUTTON_LEFT           = 1 << 1
BUTTON_RIGHT          = 1 << 0

; --------------------------------------
; TILE
TILE_EMPTY            = $00             ; An empty tile with nothing in it
TILE_FULL             = $FA             ; A completely filled tile

; --------------------------------------
; NES Color Palette Constants

; Grayscale
COLOR_BLACK         = $0F
COLOR_DARK_GRAY     = $2D
COLOR_MEDIUM_GRAY   = $1D

; **** Do not use color $0D. It results in a "blacker than black" signal that may cause problems for some TVs.
; https://www.nesdev.org/wiki/Color_$0D_games
;COLOR_LIGHT_GRAY    = $0D

; Blue
COLOR_DARK_BLUE     = $02
COLOR_BLUE          = $12
COLOR_MEDIUM_BLUE   = $22
COLOR_LIGHT_BLUE    = $32

; Indigo
COLOR_DARK_INDIGO   = $03
COLOR_INDIGO        = $13
COLOR_BRIGHT_INDIGO = $23
COLOR_PALE_INDIGO   = $33

; Violet
COLOR_DARK_VIOLET   = $04
COLOR_VIOLET        = $14
COLOR_BRIGHT_VIOLET = $24
COLOR_PALE_VIOLET   = $34

; Magenta
COLOR_DARK_MAGENTA  = $05
COLOR_MAGENTA       = $15
COLOR_BRIGHT_MAGENTA= $25
COLOR_PALE_MAGENTA  = $35

; Red
COLOR_DARK_RED      = $06
COLOR_RED           = $16
COLOR_BRIGHT_RED    = $26
COLOR_PALE_RED      = $36

; Orange
COLOR_DARK_ORANGE   = $07
COLOR_ORANGE        = $17
COLOR_BRIGHT_ORANGE = $27
COLOR_PALE_ORANGE   = $37

; Yellow
COLOR_DARK_YELLOW   = $08
COLOR_YELLOW        = $18
COLOR_BRIGHT_YELLOW = $28
COLOR_PALE_YELLOW   = $38

; Olive
COLOR_DARK_OLIVE    = $09
COLOR_OLIVE         = $19
COLOR_BRIGHT_OLIVE  = $29
COLOR_PALE_OLIVE    = $39

; Green
COLOR_DARK_GREEN    = $0A
COLOR_GREEN         = $1A
COLOR_BRIGHT_GREEN  = $2A
COLOR_PALE_GREEN    = $3A

; Turquoise
COLOR_DARK_TURQUOISE= $0B
COLOR_TURQUOISE     = $1B
COLOR_BRIGHT_TURQUOISE = $2B
COLOR_PALE_TURQUOISE  = $3B

; Cyan
COLOR_DARK_CYAN     = $0C
COLOR_CYAN          = $1C
COLOR_BRIGHT_CYAN   = $2C
COLOR_PALE_CYAN     = $3C

; Steel
COLOR_DARK_STEEL    = $00
COLOR_STEEL         = $10
COLOR_BRIGHT_STEEL  = $20
COLOR_PALE_STEEL    = $30

; White
COLOR_WHITE         = $3D

; --------------------------------------
; SOUND

; Pulse Channel 1 ($4000-$4003)
PULSE1_CONTROL = $4000                  ; Duty, length halt, constant volume/envelope, volume
PULSE1_SWEEP   = $4001                  ; Sweep control
PULSE1_LOW     = $4002                  ; Period low byte
PULSE1_HIGH    = $4003                  ; Period high byte and length counter

; Pulse Channel 2 ($4004-$4007)
PULSE2_CONTROL = $4004                  ; Same as PULSE1_CONTROL
PULSE2_SWEEP   = $4005                  ; Same as PULSE1_SWEEP
PULSE2_LOW     = $4006                  ; Same as PULSE1_LOW
PULSE2_HIGH    = $4007                  ; Same as PULSE1_HIGH

; Triangle Channel ($4008-$400B)
TRI_CONTROL    = $4008                  ; Linear counter control
TRI_UNUSED     = $4009                  ; Unused
TRI_LOW        = $400A                  ; Period low byte
TRI_HIGH       = $400B                  ; Period high byte and length counter

; Noise Channel ($400C-$400F)
NOISE_CONTROL  = $400C                  ; Length halt, constant volume/envelope, volume
NOISE_UNUSED   = $400D                  ; Unused
NOISE_LOOP     = $400E                  ; Mode and period
NOISE_LENGTH   = $400F                  ; Length counter load

; DMC Channel ($4010-$4013)
DMC_CONTROL    = $4010                  ; Flags and frequency
DMC_LOAD       = $4011                  ; Direct load
DMC_ADDRESS    = $4012                  ; Sample address
DMC_LENGTH     = $4013                  ; Sample length

; Status and Frame Counter
APU_STATUS     = $4015                  ; Channel enable and status
APU_FRAME      = $4017                  ; Frame counter control

; --------------------------------------
; Mesen debug
MESEN_LOG_ADDR      = $00FC

; --------------------------------------
; Modulos
MOD_2   = %00000001   ; $01
MOD_4   = %00000011   ; $03
MOD_8   = %00000111   ; $07
MOD_16  = %00001111   ; $0F
MOD_32  = %00011111   ; $1F
MOD_64  = %00111111   ; $3F
MOD_128 = %01111111   ; $7F

; --------------------------------------
; Actor constants
ACTOR_TOTAL_BYTES     = 10
ACTOR_STATE_ACTIVATED = (1 << 7)
ACTOR_STATE_ANIMATED  = (1 << 6)

; Actor struct
ACTOR_DATA_PTR_LO     = 0
ACTOR_DATA_PTR_HI     = 1
ACTOR_STATE           = 2               ; EA-- ---- (E: Enabled?, A: Animate?)
ACTOR_FRAME           = 3
ACTOR_COUNTER         = 4
ACTOR_X               = 5
ACTOR_Y               = 6
ACTOR_CALLBACK_LO     = 7
ACTOR_CALLBACK_HI     = 8
ACTOR_NOT_USED_YET    = 9

