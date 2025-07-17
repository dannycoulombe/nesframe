.segment "RODATA"
PauseTxt1: .byte "GAME", 0
PauseTxt2: .byte "PAUSED", 0

.segment "CODE"
.scope Pause

  Check:

    ; Can't pause if dead
    lda player_health
    bne :+
      jmp @end
    :

    ; Pause/Unpause on press start
    lda pressed_buttons
    and #BUTTON_START
    beq @end

      ; Invert game flag bit
      lda game_flag
      eor #GAME_FLAG_PAUSED
      sta game_flag

      ; Pause or unpause the game
      and #GAME_FLAG_PAUSED
      beq @pause
        jsr PauseGame
        jmp @complete
      @pause:
        jsr ResumeGame
      @complete:
    @end:

    rts

  PauseGame:
    jsr Music::Pause
    jsr Sound::PauseIn
    ;OnceDuringNMI PPU::Clone
    OpenDialogMiddle #6, #2
    OnceDuringNMI PrintPauseText
    ForEachActor Actors::HideCurrent
    rts

  ResumeGame:
    jsr Music::Resume
    jsr Sound::PauseOut
    jsr CloseDialog
    ForEachActor Actors::ShowCurrent
    OnceDuringNMI ReloadScreen
    rts

  PrintPauseText:
    PrintText $21EE, PauseTxt1
    PrintText $220D, PauseTxt2
    rts

  ReloadScreen:
    jsr PPU::DisableRendering
    PPU_Load_2x2_Screen NM0_LEVEL_OFFSET, #13, Level1_MapTable
    PPU_LoadAttributes Level1_MapTable
    jsr PPU::EnableRendering
    rts

.endscope