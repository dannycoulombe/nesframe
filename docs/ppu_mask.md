# PPU_MASK ($2001) - PPU Control Register 2

The PPU mask register controls the rendering of sprites and backgrounds, as well as color effects.

## Register Layout (8 bits)
```
7  bit  0
---- ----
BGRs bMmG
|||| ||||
|||| |||+- Greyscale (0: normal color, 1: greyscale)
|||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
|||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
|||| +---- 1: Show background
|||+------ 1: Show sprites
||+------- Emphasize red (green on PAL)
|+-------- Emphasize green (red on PAL)
+--------- Emphasize blue
```


## Common Values
```
%00011110 ($1E) ; Background and sprites enabled
%00011111 ($1F) ; Background and sprites enabled, show in leftmost 8 pixels
%00000000 ($00) ; Screen off
%00000110 ($06) ; Background only
%00010110 ($16) ; Sprites only
```


## Bit Details

| Bit | Description | Effect when Set (1) |
|-----|-------------|-------------------|
| 0 | Greyscale | Disables color, only brightness levels shown |
| 1 | Left background | Show background in leftmost 8 pixels |
| 2 | Left sprites | Show sprites in leftmost 8 pixels |
| 3 | Background | Enable background rendering |
| 4 | Sprites | Enable sprite rendering |
| 5 | Red emphasis | Emphasize red colors |
| 6 | Green emphasis | Emphasize green colors |
| 7 | Blue emphasis | Emphasize blue colors |

## Important Notes
- Bits 0-4 are commonly used for general rendering control
- Setting both background and sprite enable bits (3,4) is required for normal rendering
- Color emphasis bits (5-7) work differently on PAL vs NTSC systems
- Turning off both background and sprites (bits 3,4 = 0) will disable rendering and can be used for:
    - V-blank sprite updates
    - Mid-frame effects
    - CPU performance optimization

## Example Usage
```
; Enable rendering with both background and sprites
lda #%00011110
sta PPU_MASK

; Disable rendering (screen off)
lda #%00000000
sta PPU_MASK

; Background only, with leftmost 8 pixels
lda #%00000111
sta PPU_MASK
```


## Common Tasks

### Screen Enable/Disable
```
EnableScreen:
    lda #%00011110      ; Enable background and sprites
    sta PPU_MASK
    rts

DisableScreen:
    lda #%00000000      ; Disable all rendering
    sta PPU_MASK
    rts
```


### Show Background in Left Column
```
lda PPU_MASK
    ora #%00000010      ; Set bit 1
    sta PPU_MASK
```


### Hide Sprites Only
```
lda PPU_MASK
    and #%11101111      ; Clear bit 4
    sta PPU_MASK
```


Remember that changes to PPU_MASK should typically be done during V-blank to avoid visual artifacts.