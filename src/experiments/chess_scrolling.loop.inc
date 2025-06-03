; Scroll right
lda buttons
tax                                     ; Move A to X since reading from registers takes less CPU cycles

; Right
and #BUTTON_RIGHT
beq :+
    inc scroll_x
:

; Left
txa
and #BUTTON_LEFT
beq :+
    dec scroll_x
:

; Up
txa
and #BUTTON_UP
beq :+
    dec scroll_y
:

; Down
txa
and #BUTTON_DOWN
beq :+
    inc scroll_y
:

; Following actions are only executed when pressed (once)
lda pressed_buttons
tax

; A
and #BUTTON_A
beq :+
    jsr Sound::Fall
:

; B
txa
and #BUTTON_B
beq :+
    jsr Sound::Rise
:
