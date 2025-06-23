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
  temp:                   .res 8,0      ; Whatever...
  ptr:                    .word 0       ; An indirect pointer to be used anywhere
  ptr2:                   .word 0       ; An second indirect pointer to be used anywhere

  ; Functions
  params_bytes:           .res 4,0      ; Bytes to be used as temporary parameters
  params_labels:          .res 4,0      ; Labels to be used as temporary parameters

  ; Buttons
  buttons:                .byte 0       ; Button states (RLDU SSBA)
  last_buttons:           .byte 0       ; Last button states (RLDU SSBA)
  pressed_buttons:        .byte 0       ; Newly pressed buttons (RLDU SSBA)

  ; Sprites/Metasprites
  oam_ptr:                .word 0       ; Current OAM pointer
  sprite_ptr:             .word 0       ; Current sprite pointer
  metasprite_x:           .byte 0
  metasprite_y:           .byte 0
  metasprite_delta_x:     .byte 0
  metasprite_delta_y:     .byte 0
  metasprite_direction:   .byte 0

  ; Scene
  scroll_x:               .byte 0       ; Scroll X position
  scroll_y:               .byte 0       ; Scroll Y position
  scene_nametable_label:  .word 0       ; Scene nametable address (0 if none)
  scene_init_label:       .word 0       ; Scene frame address to be executed (0 if none)
  scene_frame_addr:       .word 0       ; Scene frame address to be executed (0 if none)
  scene_nmi_addr:         .word 0       ; Scene NMI address to be executed (0 if none)

  ; Actors
  actor_array:            .res 8 * ACTOR_TOTAL_BYTES, 0
  actor_array_size:       .byte 0       ; Inner amount of actors (not total size of array)
  actor_index:            .byte 0       ; Current actor index
  actor_ptr:              .word 0       ; Current actor pointer

  ; Collision detection
  collision_check_x:      .byte 0       ; Current collision check X position
  collision_check_y:      .byte 0       ; Current collision check Y position
  collision_tl_tile_idx:  .byte 0       ; Current collision check top-left tile index
  collision_tr_tile_idx:  .byte 0       ; Current collision check top-right tile index
  collision_bl_tile_idx:  .byte 0       ; Current collision check bottom-left tile index
  collision_br_tile_idx:  .byte 0       ; Current collision check bottom-right tile index

  ; Hooks
  frame_hooks:            .res 8 * 2, 0 ; Jump table of things to execute every frame
  frame_hooks_size:       .byte 0       ; How many items currently in this jump table?
  nmi_hooks:              .res 8 * 2, 0 ; Jump table of things to execute every NMI
  nmi_hooks_size:         .byte 0       ; How many items currently in this jump table?

; --------------------------------------
; RAM (0100-07FF)
;      0100-01FF (256 bytes): Stack
;      0200-02FF (256 bytes): OAM (Sprite) memory
;      0300-07FF (1280 bytes): General purpose RAM
.segment "RAM"
  current_stage:          .byte 0       ; Current stage

; --------------------------------------
; Main code
; You can use a maximum of ~20'000 cycles
.segment "CODE"

  ; Declarations, utils, tools, etc.
  .include "utils/array.s"
  .include "utils/hooks.s"
  .include "utils/debug.s"
  .include "utils/general.s"
  .include "utils/reset.s"
  .include "utils/register.s"
  .include "utils/ppu.s"
  .include "utils/scroll.s"
  .include "utils/sound.s"
  .include "utils/addr.s"
  .include "utils/metasprite.s"
  .include "utils/actors.s"
  .include "utils/collision.s"
  .include "utils/controllers.s"
  .include "actors/player.s"
  .include "actors/round-rock.s"
  .include "actors/torch.s"

  ; Skip directly to reset
  jmp RESET

  ; Code and data to be referenced later on
  MetaspriteData: .include "data/metasprite.s"
  Level1Data: .include "maps/level1/level1.s"

  ; Initialize the NES
  RESET:

    ; Reset and wait for 2 VBlanks
    Reset_NES

    ; Reset execution state
    sta execution_state

    ; Safe to clear everything now
    PPU_Clear_Nametable $2000, #TILE_EMPTY, #0
    PPU_Clear_Nametable $2400, #TILE_EMPTY, #0
    ;PPU_Clear_Background_Palette #COLOR_BLACK
    ;PPU_Clear_Sprite_Palette #COLOR_BLACK

    ; Change background color by applying light
    ; blue to the first palette index
;    PPU_Write $3F00, #COLOR_BLACK

    ; First scene is level 1
;    Hook_Add frame_hooks, Stage_Level1_Init
    Addr_Set scene_init_label, Stage_Level1_Init, 1

  BeforeSceneInit:
    PPU_Disable_Rendering               ; Disable rendering (this code contains too many cycles)
    jmp (scene_init_label)

  AfterSceneInit:

    ; Enables NMI, background and sprites rendering
    PPU_Enable_Rendering

    ; Enable sound effects
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
      Actor_Run_Callback
      Actor_Push_To_OAM

      ; Jump to scene frame code if available
;      Hook_Run nmi_hooks
      Addr_BNE_Jump scene_frame_addr

      AfterSceneFrame:
        ; CPU cycle completed
        lda #%00000011                  ; Remove frame bit (bit #2)
        sta execution_state

        jmp Forever                     ; Infinite loop

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

  ; Apply current scroll position
  Scroll_Set_Position scroll_x, scroll_y

  ; Jump to scene initialization if available
  Addr_BNE_Jump scene_nmi_addr

  AfterSceneNMI:

    ; Trigger OAM DMA                   ; 512 CPU cycles to transfer all sprite data
    lda #$02                            ; Page number (high-byte $0200)
    sta PPU_OAM_DMA                     ; Trigger

    ; NMI execution completed
    lda execution_state
    and #%11111100                      ; Reset NMI and IRQ bit to 0 (ready to be executed again)
    sta execution_state

    Register_Pull_All
    rti                                 ; Return from NMI

; --------------------------------------
; Lower priority than NMI, always executed
; after if enabled (cli) and not disabled (sei)
; Good for sound updates, split-screen effets
; or timer-based events.
IRQ:
  rti

; --------------------------------------
; Additional data
Metatiles2x2Data: .incbin "data/tiles.2x2"

; --------------------------------------
; Sprites data
.segment "CHR"
  .incbin "data/tiles.chr"              ; Include CHR data (4 KB of tile data)
  .incbin "data/sprites.chr"            ; Include CHR data (4 KB of sprite data)

.segment "VECTORS"
  .word NMI                             ; NMI vector
  .word RESET                           ; Reset vector
  .word IRQ                             ; IRQ/BRK vector
