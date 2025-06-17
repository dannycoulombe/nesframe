.include "consts.inc"

.segment "HEADER"
    .include "header.inc"               ; Check docs/header.md

; -------------------------------------------------------------------------------
; ZERO PAGE (0000-00FF)
; Fast memory (use less cycles)
; 256 bytes total available
.segment "ZEROPAGE"
    frame_count:            .byte 0     ; Total amount of frames (255 loop)
    execution_state:        .byte 0     ; Execution in progress? ---- -FNI (F: Frame, N: NMI, I: IRQ)
    ptr:                    .word 0     ; An indirect pointer to be used anywhere
    debug:                  .byte 0     ; Used for debugging purposes
    temp:                   .byte 0     ; Whatever...
    temp2:                  .byte 0     ; Whatever...
    tile_ptr:               .word 0     ; An indirect tile pointer
    params_bytes:           .res 4,0
    params_labels:          .res 4,0
    scroll_x:               .byte 0     ; Scroll X position
    scroll_y:               .byte 0     ; Scroll Y position
    buttons:                .byte 0     ; Button states (RLDU SSBA)
    last_buttons:           .byte 0     ; Last button states (RLDU SSBA)
    pressed_buttons:        .byte 0     ; Newly pressed buttons (RLDU SSBA)
    oam_ptr:                .word 0     ; Current OAM pointer
    sprite_ptr:             .word 0     ; Current sprite pointer
    metasprite_direction:   .byte 0
    metasprite_x:           .byte 0
    metasprite_y:           .byte 0
    scene_init_label:       .word 0     ; Scene frame address to be executed (0 if none)
    scene_nametable_label:  .word 0     ; Scene nametable address (0 if none)
    scene_frame_addr:       .word 0     ; Scene frame address to be executed (0 if none)
    scene_nmi_addr:         .word 0     ; Scene NMI address to be executed (0 if none)
    actor_index:            .byte 0     ; Current actor index
    actor_ptr:              .word 0     ; Current actor pointer
    actor_array:            .res 8*ACTOR_TOTAL_BYTES,0  ; 8 actors times total bytes each
    collision_check_x:      .byte 0
    collision_check_y:      .byte 0
    collision_map:          .res 30     ; Keep

; -------------------------------------------------------------------------------
; RAM (0100-07FF)
;      0100-01FF (256 bytes): Stack
;      0200-02FF (256 bytes): OAM (Sprite) memory
;      0300-07FF (1280 bytes): General purpose RAM
.segment "RAM"
    current_stage:          .byte 0     ; Current stage

; -------------------------------------------------------------------------------
; Main code
; You can use a maximum of ~20'000 cycles
.segment "CODE"

    ; Declarations, utils, tools, etc.
    .include "utils/debug.inc"
    .include "utils/general.inc"
    .include "utils/reset.inc"
    .include "utils/register.inc"
    .include "utils/ppu.inc"
    .include "utils/scroll.inc"
    .include "utils/sound.inc"
    .include "utils/addr.inc"
    .include "utils/metasprite.inc"
    .include "utils/actors.inc"
    .include "utils/collision.inc"
    .include "utils/tilemap.inc"
    .include "actors/player.inc"
    .include "actors/round-rock.inc"
    .include "actors/torch.inc"

    ; Skip directly to reset
    jmp RESET

    ; Code and data to be referenced later on
    MetaspriteData: .include "data/metasprite.s"
    Level1Data: .include "maps/level1/level1.inc"

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

        ; Change background color by applying light blue to the first palette index
        PPU_Write $3F00, #COLOR_BLACK

        ; First scene is level 1
        Addr_Set scene_init_label, Stage_Level1_Init, 1

    BeforeSceneInit:
        PPU_Disable_Rendering           ; Disable rendering (this code contains too many cycles)
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
        and #%00000111                  ; Check if frame was running or not?
        bne Forever                     ; Frame is already running (1), skip...

        ; Flag execution state as a new cycle
        lda #%00000111
        sta execution_state

        ; Read controller inputs
        .include "lib/controllers.read.inc"

        ; Convert actors to sprites
        Actor_Run_Callback
        Actor_Push_To_OAM

        ; Jump to scene frame code if available
        Addr_BNE_Jump scene_frame_addr

        AfterSceneFrame:
            ; CPU cycle completed
            lda #%00000011              ; Remove frame bit (bit #2)
            sta execution_state

            jmp Forever                 ; Infinite loop

; -------------------------------------------------------------------------------
; Operations like updating scroll position and sprites need to be synchronized with VBlank
; to avoid visual artifacts. Remember that the PPU scroll position needs to be reset during
; each NMI/VBlank because the PPU hardware automatically changes the scroll position
; as it renders the screen.
NMI:                                    ; Maximum of ~2273 cycles

    Register_Push_All

    ; Do not execute if previous NMI code was not completed
    ; to prevent a too many cycles issue
    lda execution_state
    and #%00000010                      ; Check if NMI was running or not?
    bne :+                              ; NMI was not running, continue with the script
        Register_Pull_All
        rti
    :

    ; Flat NMI execution state as a new cycle
    lda execution_state
    ora #%00000010                      ; Set NMI execution bit to 1
    sta execution_state

    inc frame_count                     ; Increment frame count

    ; Apply current scroll position
    Scroll_Set_Position scroll_x, scroll_y

    ; Jump to scene initialization if available
    Addr_BNE_Jump scene_nmi_addr

    AfterSceneNMI:

        ; Trigger OAM DMA
        lda #$02                        ; Page number (high-byte $0200)
        sta PPU_OAM_DMA                 ; Trigger

        ; NMI execution completed
        lda execution_state
        and #%11111100                  ; Reset NMI and IRQ bit to 0 (ready to be executed again)
        sta execution_state

        Register_Pull_All
        rti                             ; Return from NMI

; -------------------------------------------------------------------------------
; Lower priority than NMI, always executed after if enabled (cli) and not disabled (sei)
; Good for sound updates, split-screen effets or timer-based events.
IRQ:
  rti

; -------------------------------------------------------------------------------
; Additional data
Metatiles2x2Data: .incbin "data/tiles.2x2"

; -------------------------------------------------------------------------------
; Sprites data
.segment "CHR"
    .incbin "data/tiles.chr"           ; Include CHR data (4 KB of tile data)
    .incbin "data/sprites.chr"         ; Include CHR data (4 KB of sprite data)

.segment "VECTORS"
    .word NMI                           ; NMI vector
    .word RESET                         ; Reset vector
    .word IRQ                           ; IRQ/BRK vector
