.byte "NES", $1A                        ; NES Identifier

.byte 1                                 ; PRG-ROM Size: 1x16kb (16kb)
.byte 1                                 ; CHR-ROM Size: 1x8kb (8kb)

.byte %01000010
      ;||||||||
      ;|||||||+- Nametable arrangement: 0: vertical arrangement ("horizontal mirrored") (CIRAM A10 = PPU A11)
      ;|||||||                          1: horizontal arrangement ("vertically mirrored") (CIRAM A10 = PPU A10)
      ;||||||+-- 1: Cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
      ;|||||+--- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
      ;||||+---- 1: Alternative nametable layout
      ;++++----- Lower nybble of mapper number

.byte %00000000                         ; Bit 7: Reserved (must be 0).
                                        ; Bit 6: VS Unisystem
                                        ; Bit 5: PlayChoice-10
                                        ; Bits 4-0: Mapper (Upper 5 bits)

.byte 0                                 ; PRG-RAM Size: 0x8kb (0kb)
.byte %00000000                         ; Bit 0: TV system
                                        ; Bits 1-7: Reserved (must be 0).

.byte %00000000                         ; Bits 0-3: Reserved (must be 0).
                                        ; Bits 4-5: PRG-RAM presence in specific ranges.
                                        ; Bits 6-7: Reserved (must be 0).

.byte 0, 0, 0, 0, 0                     ; These bytes are always set to 00 and reserved for future use.
