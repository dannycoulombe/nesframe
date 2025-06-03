# Minimalist NES Header Explanation

The NES header is the first 16 bytes of an NES ROM file, as defined by the iNES format. Here's a bit-by-bit breakdown of its structure:

## Header Breakdown

### Bytes 0-3: NES Identifier  
- Contains the ASCII string `"NES"` followed by `$1A` (EOF marker).  
- This identifies the file as an NES ROM and must be present for compatibility.

### Byte 4: PRG-ROM Size  
- Specifies the size of the PRG-ROM in 16 KB units.  
- Example: `01` means the PRG-ROM is 16 KB.

### Byte 5: CHR-ROM Size  
- Specifies the size of the CHR-ROM in 8 KB units.  
- Example: `01` means the CHR-ROM is 8 KB.  
- If the game uses CHR-RAM instead of CHR-ROM, this value is `00`.

### Byte 6: Flags 6  
- Controls mapper number and memory configuration.  
  - **Bit 7**: Reserved (must be `0`).  
  - **Bit 6**: Battery-backed save RAM (`0` = No, `1` = Yes).  
  - **Bit 5**: Trainer present (`0` = No, `1` = Yes).  
  - **Bit 4**: Four-screen mirroring (`0` = No, `1` = Yes).  
  - **Bit 3**: Mirroring type (`0` = Horizontal, `1` = Vertical).  
  - **Bits 2-0**: Lower 3 bits of the mapper number.

### Byte 7: Flags 7  
- Extends the mapper number and defines additional system features.  
  - **Bit 7**: Reserved (must be `0`).  
  - **Bit 6**: VS Unisystem (`0` = No, `1` = Yes).  
  - **Bit 5**: PlayChoice-10 (`0` = No, `1` = Yes).  
  - **Bits 4-0**: Upper 5 bits of the mapper number.

### Byte 8: PRG-RAM Size  
- Specifies the size of PRG-RAM in 8 KB units.  
- If no PRG-RAM is present, this value is `00`.

### Byte 9: Flags 9  
- TV system configuration.  
  - **Bit 0**: TV system (`0` = NTSC, `1` = PAL).  
  - **Bits 1-7**: Reserved (must be `0`).

### Byte 10: Flags 10  
- Miscellaneous information.  
  - **Bits 0-3**: Reserved (must be `0`).  
  - **Bits 4-5**: PRG-RAM presence in specific ranges.  
  - **Bits 6-7**: Reserved (must be `0`).

### Bytes 11-15: Padding  
- These bytes are always set to `00` and reserved for future use.

## Summary  
The NES header defines the configuration and structure of an NES ROM. It includes information about PRG-ROM, CHR-ROM, memory configurations, mappers, and system compatibility. This minimalist configuration is often used for simple games without advanced features like battery-backed saves or mappers.