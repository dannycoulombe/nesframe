.include "consts.s"

.segment "HEADER"
  .include "header.s"                   ; Check docs/header.md

; --------------------------------------
; ZERO PAGE (0000-00FF)
; Fast memory (use less cycles)
; 256 bytes total available
.segment "ZEROPAGE"

  frame_count:            .byte 0       ; A global frame count
  array_index:            .byte 0

  ; State management
  execution_state:        .byte 0       ; Execution in progress? ---- -FNI (F: Frame, N: NMI, I: IRQ)

  ; General parameters
  debug:                  .byte 0       ; Used for debugging purposes
  temp:                   .res 4,0      ; Whatever...
  array_temp:             .res 8,0      ; Keep array data in memory
  ptr:                    .word 0       ; An indirect pointer to be used anywhere
  ptr2:                   .word 0       ; An second indirect pointer to be used anywhere
  ptr3:                   .word 0       ; An third indirect pointer to be used anywhere
  table_ptr:              .word 0       ; Temporary jump table pointer

  ; Functions
  params_bytes:           .res 4,0      ; Bytes to be used as temporary parameters
  params_labels:          .res 4,0      ; Labels to be used as temporary parameters

  ; Buttons
  buttons:                .byte 0       ; Button states (RLDU SSBA)
  last_buttons:           .byte 0       ; Last button states (RLDU SSBA)
  pressed_buttons:        .byte 0       ; Newly pressed buttons (RLDU SSBA)

  ; States
  header_state:           .byte 0       ; (Km HMBA): K=Key, m=Money, H:Hearts, M:Magic, B:ItemB, A:ItemA

  ; Player
  player_coll_off_x:      .byte 0       ; Player collision offset X
  player_coll_off_y:      .byte 0       ; Player collision offset Y
  player_ori_dir:         .byte 0       ; Player original direction
  player_dir:             .byte 0       ; Player current direction

  ; Sprites/Metasprites
  metasprite_x:           .byte 0       ; Current X position
  metasprite_y:           .byte 0       ; Current Y position
  metasprite_delta_x:     .byte 0       ; Current delta X
  metasprite_delta_y:     .byte 0       ; Current delta Y
  metasprite_metatile_idx:.byte 0       ; Current metatile index
  metasprite_metatile_touch_idx: .byte 0; Metatile is touching tile indx
  metasprite_direction:   .byte 0       ; Current direction (4 first bits)

  ; Scene
  scene_map_ptr_jt:       .word 0       ; Scene nametable address (0 if none)
  scene_init_label:       .word 0       ; Scene frame address to be executed (0 if none)
  scene_frame_addr:       .word 0       ; Scene frame address to be executed (0 if none)
  scene_nmi_addr:         .word 0       ; Scene NMI address to be executed (0 if none)
  nametable_idx:          .byte 0       ; Index of current nametable
  scroll_x:               .byte 0       ; Scroll X position
  scroll_y:               .byte 0       ; Scroll Y position
  scrolling_direction:    .byte 0       ; Currently scrolling to direction?

  ; Hooks
  nmi_once_hooks:         .res 2 + (4 * 2), 0 ; Jump table of things to execute once during NMI

  ; Actors
  actor_ptr:              .word 0       ; Current actor pointer

  ; Objects
  object_ptr:             .word 0       ; Current object pointer
  object_ptr_index:       .byte 0       ; Current pointer index (index * 8 bytes)

  ; Pointers
  indirect_jsr_ptr:       .word 0
  oam_ptr:                .word 0       ; Current OAM pointer
  sprite_ptr:             .word 0       ; Current sprite pointer
  map_ptr:                .word 0

; --------------------------------------
; RAM (0100-07FF)
;      0100-01FF (256 bytes): Stack
;      0200-02FF (256 bytes): OAM (Sprite) memory
;      0300-07FF (1280 bytes): General purpose RAM
.segment "RAM"

  ; Game
  current_level:          .byte 0       ; Current level
  game_flag:              .byte 0       ; Game flags
                                        ; Bit 7   6   5   4   3   2   1   0
                                        ;     |   |   |   |   |   |   |   |
                                        ;     |   |   |   |   |   |   |   +-- Paused
                                        ;     |   |   |   |   |   |   +------ Unused
                                        ;     |   |   |   |   |   +---------- Unused
                                        ;     |   |   |   |   +-------------- Unused
                                        ;     |   |   |   +------------------ Unused
                                        ;     |   |   +---------------------- Unused
                                        ;     |   +-------------------------- Unused
                                        ;     +------------------------------ Unused

  ; Player
  player_health:          .byte 0       ; Player health
  player_hearths:         .byte 0       ; Player total hearts
  player_magic_slot:      .byte 0       ; Player total magic slots
  player_magic:           .byte 0       ; Player magic

  ; Inventory
  total_keys:             .byte 0       ; Total amount of keys
  total_pebbles:          .byte 0,0     ; Total amount of pebbles (max 999)

  ; Actors structure
  actor_array:            .res 8 * ACTOR_TOTAL_BYTES, 0
  actor_size:             .byte 0       ; Actor array size
  actor_index:            .byte 0       ; Current actor index

  ; Objects structure
  object_size:            .byte 0       ; Total amount of objects in array
  object_memory:          .res 8*4,0    ; 4 bytes per object
  object_memory_index:    .byte 0       ; Current memory index (index * 4 bytes)

; --------------------------------------
; Main code
; You can use a maximum of ~27'000 cycles
.segment "CODE"

  ; Declarations, utils, tools, etc.
  .include "utils/index.s"
  .include "lib/index.s"
  .include "texts/index.s"
  .include "logic/index.s"
  .include "objects/index.s"
  .include "actors/index.s"

  ; Initialize the NES
  RESET:

    ; Reset and wait for 2 VBlanks
    Reset_NES
    jsr PPU::ClearNametable

    ; Initialize array definitions
    Array_Init nmi_once_hooks, #2
    Array_Init delayed_array, #.sizeof(DelayedItem)

    ; Enable audio
    jsr Audio::EnableMusic
    jsr Audio::EnableSFX

    ; Ready to initialize
    jsr PPU::DisableRendering           ; Disable rendering (this code contains too many cycles)
    PPU_LoadPalette DefaultBGPal, $3F00, #16
    PPU_LoadPalette DefaultSpritePal, $3F10, #16
    jsr InitializeGame

    ; Enables NMI, background, sprites rendering
    jsr PPU::EnableRendering

    ; Main game loop
    Forever:

      ; Skip uncompleted game cycles
      lda execution_state
      and #%00000111                    ; Check if frame was running or not?
      bne Forever                       ; Frame is already running (1), skip...

      ; Flag execution state as a new cycle
      lda #%00000111
      sta execution_state

      ; Read controller inputs
      jsr Controller::Read
      jsr Pause::Check

      ; Convert actors to sprites
      jsr Actors::PushToOAM

      ; Skip if game paused
      lda game_flag
      and #GAME_FLAG_PAUSED
      bne AfterFrame

      ; Run callbacks
      jsr Actors::RunCallback
      jsr RunAllDelayedItems

      ; Execute frame hooks
      lda player_health
      beq AfterFrame
        jsr RunObjectsFrameCallback
      AfterFrame:

      ; CPU cycle completed
      lda #%00000011                    ; Remove frame bit (bit #2)
      sta execution_state

      jmp Forever                       ; Infinite loop

; --------------------------------------
; Operations like updating scroll position
; and sprites need to be synchronized with VBlank
; to avoid visual artifacts. Remember that
; the PPU scroll position needs to be reset during
; each NMI/VBlank because the PPU hardware
; automatically changes the scroll position
; as it renders the screen.
NMI:                                    ; Maximum of ~2273 cycles

  Register_Push_XY

  ; Do not execute if previous NMI code was not completed
  ; to prevent a too many cycles issue
  lda execution_state
  and #%00000010                        ; Check if NMI was running or not?
  bne :+                                ; NMI was not running, continue with the script
    jmp AfterNMI
  :

  ; Flag NMI execution state as a new cycle
  lda execution_state
  ora #%00000010                        ; Set NMI execution bit to 1
  sta execution_state

  ; Run NMI hooks
  RunHooks nmi_once_hooks
  ClearHooks nmi_once_hooks, #10

  ; Skip if game paused
  lda game_flag
  and #GAME_FLAG_PAUSED
  bne SkipNMIHooks

  ; Run other hooks
  jsr RunObjectsNMICallback
  jsr HeaderNMICallback
  jsr CheckTransition

  SkipNMIHooks:

  ; Trigger OAM DMA                     ; 512 CPU cycles to transfer all sprite data
  lda #$02                              ; Page number (high-byte $0200)
  sta PPU_OAM_DMA                       ; Trigger

  ; Increase global frame count
  inc frame_count

  AfterNMI:

  ; Apply current scroll position
  jsr Scroll::UpdatePosition

  ; Update famitone
  jsr FamiToneUpdate

  ; NMI execution completed
  lda execution_state
  and #%11111100                        ; Reset NMI and IRQ bit to 0 (ready to be executed again)
  sta execution_state

  Register_Pull_XY

  rti                                   ; Return from NMI

; --------------------------------------
; Lower priority than NMI, always executed
; after if enabled (cli) and not disabled (sei)
; Good for sound updates, split-screen effets
; or timer-based events.
IRQ:
  rti

; --------------------------------------
; Read-only data
.segment "RODATA"
Level1Data: .include "maps/level1.s"
MusicData: .include "data/music.s"
SFXData: .include "data/sfx.s"
MetaspritesData: .include "data/metasprites.s"
Metatiles2x2Data: .incbin "data/metatiles.bin"
Metatiles2x2Prop: .incbin "data/metatiles.prop"
DefaultBGPal: .incbin "data/background.pal"
BgPalDim1: .incbin "data/background-dim1.pal"
BgPalDim2: .incbin "data/background-dim2.pal"
BgPalDim3: .incbin "data/background-dim3.pal"
DefaultSpritePal: .incbin "data/sprite.pal"
BlackPal: .incbin "data/black.pal"

; --------------------------------------
; Sprites data
.segment "CHR"
  .incbin "data/tiles.chr"              ; Include CHR data (4 KB of tile data)
  .incbin "data/sprites.chr"            ; Include CHR data (4 KB of sprite data)

.segment "VECTORS"
  .word NMI                             ; NMI vector
  .word RESET                           ; Reset vector
  .word IRQ                             ; IRQ/BRK vector
