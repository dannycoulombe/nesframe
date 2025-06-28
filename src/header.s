.byte "NES", $1A                        ; NES Identifier

.byte 1                                 ; PRG-ROM Size: 1x16kb (16kb)
.byte 1                                 ; CHR-ROM Size: 1x8kb (8kb)

.byte %00011011                         ; Bit 7: Reserved (must be 0).
                                        ; Bit 6: Is battery backed?
                                        ; Bit 5: Trainer present?
                                        ; Bit 4: Four screens mirroring?
                                        ; Bit 3: Mirroring type?
                                        ; Bits 2-0: Mapper (Lower 3 bits)

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
