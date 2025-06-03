# NES Memory Architecture Guide

## CPU Memory Map ($0000-$FFFF)
The 6502 processor can address 64KB of memory space (16-bit addressing).

### Zero Page ($0000-$00FF)
- Fast access memory (requires fewer CPU cycles)
- Commonly used for variables and pointers
- Special addressing modes available for this page

### Stack ($0100-$01FF)
- 256 bytes dedicated to stack operations
- Stack pointer starts at $FF and grows downward
- Used for subroutine calls and temporary storage

### RAM ($0200-$07FF)
- General purpose RAM
- Available for program variables and data

### PPU Registers ($2000-$2007)
- Memory-mapped registers to control the PPU
```
$2000 - PPUCTRL   (Write)  PPU control register
$2001 - PPUMASK   (Write)  PPU mask register
$2002 - PPUSTATUS (Read)   PPU status register
$2003 - OAMADDR   (Write)  OAM address register
$2004 - OAMDATA   (R/W)    OAM data register
$2005 - PPUSCROLL (Write)  PPU scroll register
$2006 - PPUADDR   (Write)  PPU address register
$2007 - PPUDATA   (R/W)    PPU data register
```


### APU and IO Registers ($4000-$401F)
- Audio processing and I/O control

### Cartridge Space ($4020-$FFFF)
- PRG-ROM (program code)
- PRG-RAM (save data/extra RAM)
- Mapper registers

## PPU Memory Map ($0000-$3FFF)

### Pattern Tables ($0000-$1FFF)
- Stores tile/character data
- Two 4KB pattern tables:
    - $0000-$0FFF: Pattern Table 0
    - $1000-$1FFF: Pattern Table 1

### Nametables ($2000-$2FFF)
- Four 1KB nametables:
    - $2000-$23FF: Nametable 0
    - $2400-$27FF: Nametable 1 (mirror if vertical)
    - $2800-$2BFF: Nametable 2 (mirror if horizontal)
    - $2C00-$2FFF: Nametable 3 (mirror if vertical or horizontal)
- Each nametable includes:
    - 960 bytes of tile indices ($2000-$23BF)
    - 64 bytes of attribute data ($23C0-$23FF)

### Palette Memory ($3F00-$3F1F)
- $3F00-$3F0F: Background palette
- $3F10-$3F1F: Sprite palette
- Each palette contains 4 colors
- $3F00 is universal background color

## Important Notes

1. **CPU to PPU Communication**
    - CPU can only access PPU memory through PPU ports ($2006 and $2007)
    - Two writes to $2006 required to set PPU address
    - Data transfer through $2007

2. **PPU Memory Access**
    - After writing to PPU_DATA ($2007), address auto-increments
    - Increment amount controlled by PPUCTRL bit 2:
        - 0: Increment by 1
        - 1: Increment by 32

3. **Memory Mirroring**
    - PPU addresses above $3FFF wrap around
    - Nametables typically mirror depending on cartridge configuration
    - Palette memory repeats every 32 bytes

4. **Timing Considerations**
    - PPU memory can only be safely accessed during VBlank
    - Or when rendering is disabled (PPUMASK)
    - Reading $2002 clears VBlank flag and address latch

This documentation covers the basic memory layout and important considerations for NES programming. Understanding this memory structure is crucial for effective NES development.