GnomeStillFront:
	.byte   4
	.byte <- 8,<- 8,$00,0
	.byte   0,<- 8,$01,0
	.byte <- 8,  0,$10,0
	.byte   0,  0,$10,0|OAM_FLIP_H
	.byte 0

GnomeWalkFrontA:
	.byte   4
	.byte <- 8,<- 8,$00,0
	.byte   0,<- 8,$01,0
	.byte <- 8,  0,$10,0
	.byte   0,  0,$11,0
	.byte 15

GnomeWalkFrontB:
	.byte   4
	.byte <- 8,<- 8,$00,0
	.byte   0,<- 8,$01,0
	.byte   0,  0,$10,0|OAM_FLIP_H
	.byte <- 8,  0,$11,0|OAM_FLIP_H
.byte 15 | FLAG_N

GnomePushFront:
	.byte   4
	.byte <- 8,<- 7,$00,0
	.byte   0,<- 7,$01,0
	.byte <- 8,  1,$14,0
	.byte   0,  1,$14,0|OAM_FLIP_H
.byte 0

GnomeStillBack:
	.byte   4
	.byte <- 8,<- 8,$02,0
	.byte   0,<- 8,$03,0
	.byte <- 8,  0,$12,0
	.byte   0,  0,$12,0|OAM_FLIP_H
.byte 0

GnomeWalkBackA:
	.byte   4
	.byte <- 8,<- 8,$02,0
	.byte   0,<- 8,$03,0
	.byte <- 8,  0,$12,0
	.byte   0,  0,$13,0
.byte 15

GnomeWalkBackB:
	.byte   4
	.byte <- 8,<- 8,$02,0
	.byte   0,<- 8,$03,0
	.byte <- 8,  0,$13,0|OAM_FLIP_H
	.byte   0,  0,$12,0|OAM_FLIP_H
.byte 15 | FLAG_N

GnomePushBack:
	.byte   4
	.byte <- 8,<- 7,$02,0
	.byte   0,<- 7,$03,0
	.byte <- 8,  0,$04,0
	.byte   0,  0,$04,0|OAM_FLIP_H
.byte 0

GnomeStillRight:
	.byte   4
	.byte <- 8,<- 8,$05,0
	.byte   0,<- 8,$06,0
	.byte <- 8,  0,$15,0
	.byte   0,  0,$16,0
.byte 0

GnomeWalkRight:
	.byte   4
	.byte <- 8,<- 7,$05,0
	.byte   0,<- 7,$06,0
	.byte <- 8,  1,$07,0
	.byte   0,  1,$08,0
.byte 15 | FLAG_N

GnomePushRight:
	.byte   4
	.byte <- 8,<- 7,$09,0
	.byte   0,<- 7,$0a,0
	.byte <- 8,  1,$19,0
	.byte   0,  1,$1a,0
.byte 15

GnomeStillLeft:
	.byte   4
	.byte   0,<- 8,$05,0|OAM_FLIP_H
	.byte <- 8,<- 8,$06,0|OAM_FLIP_H
	.byte   0,  0,$15,0|OAM_FLIP_H
	.byte <- 8,  0,$16,0|OAM_FLIP_H
.byte 0

GnomeWalkLeft:
	.byte   4
	.byte   0,<- 7,$05,0|OAM_FLIP_H
	.byte <- 8,<- 7,$06,0|OAM_FLIP_H
	.byte   0,  1,$07,0|OAM_FLIP_H
	.byte <- 8,  1,$08,0|OAM_FLIP_H
.byte 15 | FLAG_N

GnomePushLeft:
	.byte   4
	.byte   0,<- 7,$09,0|OAM_FLIP_H
	.byte <- 8,<- 7,$0a,0|OAM_FLIP_H
	.byte   0,  1,$19,0|OAM_FLIP_H
	.byte <- 8,  1,$1a,0|OAM_FLIP_H
.byte 15

RoundRock:
	.byte   4
	.byte <- 8,<- 8,$0b,2
	.byte   0,<- 8,$0c,2
	.byte <- 8,  0,$0b,2|OAM_FLIP_V
	.byte   0,  0,$0b,2|OAM_FLIP_H|OAM_FLIP_V
.byte 0

TorchA:
	.byte   2
	.byte <- 4,<- 8,$0e,0|OAM_FLIP_H
	.byte <- 4,  0,$1f,1
.byte 8

TorchB:
	.byte   2
	.byte <- 4,<- 8,$0f,0|OAM_FLIP_H
	.byte <- 4,  0,$1f,1
.byte 8 | FLAG_N

MushroomA:
	.byte   1
	.byte <- 4,<- 4,$20,0
.byte 0

Cane:
	.byte   2
	.byte <- 4,<- 8,$21,2
	.byte <- 4,  0,$31,2
.byte 0

MetaspritePointers:

	.word GnomeStillFront
	.word GnomeWalkFrontA
	.word GnomeWalkFrontB
	.word GnomePushFront
	.word GnomeStillBack
	.word GnomeWalkBackA
	.word GnomeWalkBackB
	.word GnomePushBack
	.word GnomeStillRight
	.word GnomeWalkRight
	.word GnomePushRight
	.word GnomeStillLeft
	.word GnomeWalkLeft
	.word GnomePushLeft
	.word RoundRock
	.word TorchA
	.word TorchB
	.word MushroomA
	.word Cane

