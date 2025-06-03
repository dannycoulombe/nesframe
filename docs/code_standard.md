## Labels & Subroutines
- All caps for main entry points and important routines
``` 6502
  RESET:
  NMI:
  IRQ:
```
- Title case for general subroutines
``` 6502
  UpdateSprites:
  LoadPalette:
```
- Local labels (often used in macros or short loops) start with @ or .
``` 6502
  @loop:
  .done:
```
## Variables/Memory Locations
- Snake case with descriptive names
``` 6502
  player_x:
  enemy_count:
  scroll_position:
```
- Common to prefix with the size (optional)
``` 6502
  byte_score:
  word_timer:
```
## Constants
- All caps with underscores
``` 6502
  SPRITE_SIZE = 4
  MAX_ENEMIES = 8
  PPU_CTRL   = $2000
```
## Macros
- Title case with underscores for readability
``` 6502
  .macro Load_Palette
  .macro Update_Sprite_Position
```
## Zero Page Variables
- Sometimes prefixed with zp_ to indicate zero page location
``` 6502
  zp_temp:
  zp_sprite_pos:
```
## Registers (when referenced in comments)
- Typically uppercase
``` 6502
  ; X = counter
  ; A = sprite index
```
These conventions help with:
- Code readability
- Understanding scope/purpose
- Distinguishing between different types of identifiers
- Making code maintenance easier

Remember that while these are common conventions, the most important thing is consistency within your own project.
