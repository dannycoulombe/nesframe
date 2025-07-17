; --------------------------------------
; Gnome
GnomeStillFront:
	.byte   4
	.byte <- 8,<-12,$00,0
	.byte    0,<-12,$00,0|OAM_FLIP_H
	.byte <- 8,<- 4,$10,0
	.byte    0,<- 4,$10,0|OAM_FLIP_H
	.byte 0

GnomeWalkFrontA:
	.byte   4
	.byte <- 8,<-12,$00,0
	.byte    0,<-12,$00,0|OAM_FLIP_H
	.byte <- 8,<- 4,$10,0
	.byte    0,<- 4,$11,0
	.byte 15

GnomeWalkFrontB:
	.byte   4
	.byte <- 8,<-12,$00,0
	.byte    0,<-12,$00,0|OAM_FLIP_H
	.byte <- 8,<- 4,$11,0|OAM_FLIP_H
	.byte    0,<- 4,$10,0|OAM_FLIP_H
	.byte 15 | FLAG_N
	.word GnomeWalkFrontA

GnomePushFront:
	.byte   4
	.byte <- 8,<-10,$00,0
	.byte    0,<-10,$00,0|OAM_FLIP_H
	.byte <- 8,<- 4,$18,0
	.byte    0,<- 4,$18,0|OAM_FLIP_H
  .byte 0

GnomeStillBack:
	.byte   4
	.byte <- 8,<-12,$02,0
	.byte    0,<-12,$02,0|OAM_FLIP_H
	.byte <- 8,<- 4,$12,0
	.byte    0,<- 4,$12,0|OAM_FLIP_H
	.byte 0

GnomeWalkBackA:
	.byte   4
	.byte <- 8,<-12,$02,0
	.byte    0,<-12,$02,0|OAM_FLIP_H
	.byte <- 8,<- 4,$12,0
	.byte    0,<- 4,$13,0
	.byte 15

GnomeWalkBackB:
	.byte   4
	.byte <- 8,<-12,$02,0
	.byte    0,<-12,$02,0|OAM_FLIP_H
	.byte <- 8,<- 4,$13,0|OAM_FLIP_H
	.byte    0,<- 4,$12,0|OAM_FLIP_H
	.byte 15 | FLAG_N
	.word GnomeWalkBackA

GnomePushBack:
	.byte   4
	.byte <- 8,<-11,$02,0
	.byte    0,<-11,$02,0|OAM_FLIP_H
	.byte <- 8,<- 4,$04,0
	.byte    0,<- 4,$04,0|OAM_FLIP_H
	.byte 0

GnomeStillRight:
	.byte   4
	.byte <- 8,<-12,$05,0
	.byte    0,<-12,$06,0
	.byte <- 8,<- 4,$15,0
	.byte    0,<- 4,$16,0
	.byte 15

GnomeWalkRight:
	.byte   4
	.byte <- 8,<-11,$05,0
	.byte    0,<-11,$06,0
	.byte <- 8,<- 3,$07,0
	.byte    0,<- 3,$08,0
	.byte 15 | FLAG_N
	.word GnomeStillRight

GnomePushRight:
	.byte   4
	.byte <- 7,<-11,$09,0
	.byte    1,<-11,$0a,0
	.byte <- 7,<- 3,$19,0
	.byte    1,<- 3,$1a,0
	.byte 0

GnomeStillLeft:
	.byte   4
	.byte <- 8,<-12,$06,0|OAM_FLIP_H
	.byte    0,<-12,$05,0|OAM_FLIP_H
	.byte <- 8,<- 4,$16,0|OAM_FLIP_H
	.byte    0,<- 4,$15,0|OAM_FLIP_H
	.byte 15

GnomeWalkLeft:
	.byte   4
	.byte <- 8,<-11,$06,0|OAM_FLIP_H
	.byte    0,<-11,$05,0|OAM_FLIP_H
	.byte <- 8,<- 3,$08,0|OAM_FLIP_H
	.byte    0,<- 3,$07,0|OAM_FLIP_H
	.byte 15 | FLAG_N
	.word GnomeStillLeft

GnomePushLeft:
	.byte   4
	.byte <- 8,<-11,$0a,0|OAM_FLIP_H
	.byte    0,<-11,$09,0|OAM_FLIP_H
	.byte <- 8,<- 3,$1a,0|OAM_FLIP_H
	.byte    0,<- 3,$19,0|OAM_FLIP_H
	.byte 0

GnomeDiesStart:
	.byte   6
	.byte <- 2,<- 8,$17,3|OAM_FLIP_H
	.byte <- 6,<- 8,$17,3
	.byte <- 8,<-12,$00,0
	.byte    0,<-12,$00,0|OAM_FLIP_H
	.byte <- 8,<- 4,$14,0
	.byte    0,<- 4,$14,0|OAM_FLIP_H
	.byte 0

GnomeDiesEnd:
	.byte   4
	.byte <- 8,   9,$02,0|OAM_FLIP_V
	.byte    0,   9,$02,0|OAM_FLIP_H|OAM_FLIP_V
	.byte <- 8,   1,$12,0|OAM_FLIP_V
	.byte    0,   1,$12,0|OAM_FLIP_H|OAM_FLIP_V
	.byte 0

GnomeSpinLeft:
	.byte   5
	.byte <- 7,<- 8,$17,3|OAM_FLIP_H
	.byte <- 8,<-12,$06,0|OAM_FLIP_H
	.byte    0,<-12,$05,0|OAM_FLIP_H
	.byte <- 8,<- 4,$16,0|OAM_FLIP_H
	.byte    0,<- 4,$15,0|OAM_FLIP_H
	.byte 6

GnomeSpinBack:
	.byte   4
	.byte <- 8,<-12,$02,0
	.byte    0,<-12,$02,0|OAM_FLIP_H
	.byte <- 8,<- 4,$12,0
	.byte    0,<- 4,$12,0|OAM_FLIP_H
	.byte 6

GnomeSpinRight:
	.byte   5
	.byte <- 1,<- 8,$17,3
	.byte    0,<-12,$06,0
	.byte <- 8,<-12,$05,0
	.byte    0,<- 4,$16,0
	.byte <- 8,<- 4,$15,0
	.byte 6

GnomeSpinFront:
	.byte   6
	.byte <- 2,<- 8,$17,3|OAM_FLIP_H
	.byte <- 6,<- 8,$17,3
	.byte <- 8,<-12,$00,0
	.byte    0,<-12,$00,0|OAM_FLIP_H
	.byte <- 8,<- 4,$10,0
	.byte    0,<- 4,$10,0|OAM_FLIP_H
	.byte 6 | FLAG_N
	.word GnomeSpinLeft

; --------------------------------------
; Others

TorchA:
	.byte   2
	.byte <- 4,<- 8,$0e,0|OAM_FLIP_H
	.byte <- 4,   0,$1f,1
	.byte 8

TorchB:
	.byte   2
	.byte <- 4,<- 8,$0f,0|OAM_FLIP_H
	.byte <- 4,   0,$1f,1
	.byte 8 | FLAG_N
	.word TorchA

MushroomA:
	.byte   1
	.byte <- 4,<- 4,$20,0
	.byte 0

Cane:
	.byte   2
	.byte <- 4,<- 8,$21,2
	.byte <- 4,  0,$31,2
	.byte 0

