.include "consts.s"

.segment "HEADER"
  .include "header.s"                   ; Check docs/header.md

; --------------------------------------
; ZERO PAGE (0000-00FF)
; Fast memory (use less cycles)
; 256 bytes total available
.segment "ZEROPAGE"

  ; State management
  execution_state:        .byte 0       ; Execution in progress? ---- -FNI (F: Frame, N: NMI, I: IRQ)

  ; General parameters
  debug:                  .byte 0       ; Used for debugging purposes
  temp:                   .res 4,0      ; Whatever...
  array_temp:             .res 8,0      ; Keep array data in memory
  ptr:                    .word 0       ; An indirect pointer to be used anywhere
  ptr2:                   .word 0       ; An second indirect pointer to be used anywhere
  ptr3:                   .word 0       ; An third indirect pointer to be used anywhere
  tablePtr:               .word 0       ; Temporary jump table pointer

  ; Functions
  params_bytes:           .res 4,0      ; Bytes to be used as temporary parameters
  params_labels:          .res 4,0      ; Labels to be used as temporary parameters

  ; Buttons
  buttons:                .byte 0       ; Button states (RLDU SSBA)
  last_buttons:           .byte 0       ; Last button states (RLDU SSBA)
  pressed_buttons:        .byte 0       ; Newly pressed buttons (RLDU SSBA)

  ; Player
  player_coll_off_x:      .byte 0       ; Player collision offset X
  player_coll_off_y:      .byte 0       ; Player collision offset Y
  player_ori_dir:         .byte 0       ; Player original direction

  ; Sprites/Metasprites
  oam_ptr:                .word 0       ; Current OAM pointer
  sprite_ptr:             .word 0       ; Current sprite pointer
  metasprite_x:           .byte 0       ; Current X position
  metasprite_y:           .byte 0       ; Current Y position
  metasprite_delta_x:     .byte 0       ; Current delta X
  metasprite_delta_y:     .byte 0       ; Current delta Y
  metasprite_direction:   .byte 0       ; Current direction (4 first bytes)

  ; Scene
  scene_map_ptr_jt:       .word 0       ; Scene nametable address (0 if none)
  scene_init_label:       .word 0       ; Scene frame address to be executed (0 if none)
  scene_frame_addr:       .word 0       ; Scene frame address to be executed (0 if none)
  scene_nmi_addr:         .word 0       ; Scene NMI address to be executed (0 if none)
  nametable_idx:          .byte 0       ; Index of current nametable
  scroll_x:               .byte 0       ; Scroll X position
  scroll_y:               .byte 0       ; Scroll Y position
  scrolling_direction:    .byte 0       ; Currently scrolling to direction?

  ; Collision detection
  collision_check_x:      .byte 0       ; Check X position
  collision_check_y:      .byte 0       ; Check Y position
  collision_tl_tile_idx:  .byte 0       ; Check top-left tile index
  collision_tr_tile_idx:  .byte 0       ; Check top-right tile index
  collision_bl_tile_idx:  .byte 0       ; Check bottom-left tile index
  collision_br_tile_idx:  .byte 0       ; Check bottom-right tile index

  ; Hooks
  frame_hooks:            .res 2 + (4 * 2), 0 ; Jump table of things to execute every frame
  nmi_hooks:              .res 2 + (4 * 2), 0 ; Jump table of things to execute every NMI

  ; Actors
  actor_array:            .res 8 * ACTOR_TOTAL_BYTES, 0
  actor_index:            .byte 0       ; Current actor index
  actor_ptr:              .word 0       ; Current actor pointer

  ; Objects
  object_ptr:             .word 0       ; Current object pointer
  object_ptr_index:       .byte 0       ; Current pointer index (index * 8 bytes)
  object_size:            .byte 0       ; Total amount of objects in array
  object_memory:          .res 8*4,0    ; 4 bytes per object
  object_memory_index:    .byte 0       ; Current memory index (index * 4 bytes)

; --------------------------------------
; RAM (0100-07FF)
;      0100-01FF (256 bytes): Stack
;      0200-02FF (256 bytes): OAM (Sprite) memory
;      0300-07FF (1280 bytes): General purpose RAM
.segment "RAM"

  ; Location
  current_level:          .byte 0       ; Current level

  ; Player
  player_health:          .byte 0       ; Player health
  player_hearths:         .byte 0       ; Player total hearts
  player_magic_slot:      .byte 0       ; Player total magic slots
  player_magic:           .byte 0       ; Player magic

  ; Inventory
  total_keys:             .byte 0       ; Total amount of keys
  total_pebbles:          .byte 0,0     ; Total amount of pebbles (max 999)

; --------------------------------------
; Main code
; You can use a maximum of ~20'000 cycles
.segment "CODE"

  ; Declarations, utils, tools, etc.
  .include "utils/index.s"
  .include "objects/index.s"
  .include "actors/index.s"
  .include "logic/index.s"

  ; Initialize the NES
  RESET:

    ; Reset and wait for 2 VBlanks
    Reset_NES

    ; Safe to clear everything now
    PPU_Clear_Nametable $2000, #TILE_EMPTY, #0
    PPU_Clear_Nametable $2400, #TILE_EMPTY, #0

    ; Initialize array definitions
    Array_Init frame_hooks, #2
    Array_Init nmi_hooks, #2

    ; Ready to initialize
    jsr PPU::DisableRendering           ; Disable rendering (this code contains too many cycles)
    jsr InitializeGame
    PPU_LoadPalette Default_BG_Pal, $3F00, #16
    PPU_LoadPalette Default_Sprite_Pal, $3F10, #16

    ; Enables NMI, background, sprites rendering
    ; and sound effects
    jsr PPU::EnableRendering
    jsr Sound::Enable

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

      ; Convert actors to sprites
      jsr Actors::RunCallback
      jsr Actors::PushToOAM

      ; Execute frame hooks
      Hook_Run frame_hooks
      jsr RunObjectsFrameCallback

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

  Register_Push_All

  ; Do not execute if previous NMI code was not completed
  ; to prevent a too many cycles issue
  lda execution_state
  and #%00000010                        ; Check if NMI was running or not?
  bne :+                                ; NMI was not running, continue with the script
    Register_Pull_All
    rti
  :

  ; Flag NMI execution state as a new cycle
  lda execution_state
  ora #%00000010                        ; Set NMI execution bit to 1
  sta execution_state

  ; Run NMI hooks
  Hook_Run nmi_hooks
  jsr RunObjectsNMICallback

  ; Apply current scroll position
  jsr Scroll::UpdatePosition

  ; Trigger OAM DMA                     ; 512 CPU cycles to transfer all sprite data
  lda #$02                              ; Page number (high-byte $0200)
  sta PPU_OAM_DMA                       ; Trigger

  ; NMI execution completed
  lda execution_state
  and #%11111100                        ; Reset NMI and IRQ bit to 0 (ready to be executed again)
  sta execution_state

  Register_Pull_All
  rti                                   ; Return from NMI

; --------------------------------------
; Lower priority than NMI, always executed
; after if enabled (cli) and not disabled (sei)
; Good for sound updates, split-screen effets
; or timer-based events.
IRQ:
  rti

; --------------------------------------
; Additional data
MetaspritesData: .include "data/metasprites.s"
Metatiles2x2Data: .incbin "data/metatiles.bin"
Metatiles2x2Prop: .incbin "data/metatiles.prop"
Default_BG_Pal: .incbin "data/background.pal"
Default_Sprite_Pal: .incbin "data/sprite.pal"
Level1Data: .include "maps/level1.s"

; --------------------------------------
; Sprites data
.segment "CHR"
  .incbin "data/tiles.chr"              ; Include CHR data (4 KB of tile data)
  .incbin "data/sprites.chr"            ; Include CHR data (4 KB of sprite data)

.segment "VECTORS"
  .word NMI                             ; NMI vector
  .word RESET                           ; Reset vector
  .word IRQ                             ; IRQ/BRK vector
