;this file for FamiTone5 library generated by text2vol5 tool
;edited by Doug Fraker, 2019, to add volume column, all notes, 
;duty envelopes, and effects 1xx,2xx,3xx,4xx,Qxx,Rxx


music_music_data:
	.byte 1
	.word @instruments
	.word @samples-3
	.word @song0ch0,@song0ch1,@song0ch2,@song0ch3,@song0ch4,307,256 ; New song

@instruments:
	.word @env1,@env0,@env0,@env0
	.word @env1,@env0,@env0,@env0

@samples:
@env0:
	.byte $c0,$00,$00
@env1:
	.byte $ce,$cf,$00,$01


; New song
@song0ch0:
	.byte $fb,$10
@song0ch0loop:
@ref0:
	.byte $80,$0e,$83,$0d,$00,$8d,$07,$83,$06,$00,$9f
	.byte $fd
	.word @song0ch0loop

; New song
@song0ch1:
@song0ch1loop:
@ref1:
	.byte $c1
	.byte $fd
	.word @song0ch1loop

; New song
@song0ch2:
@song0ch2loop:
@ref2:
	.byte $97,$82,$2d,$83,$2c,$00,$9f
	.byte $fd
	.word @song0ch2loop

; New song
@song0ch3:
@song0ch3loop:
@ref3:
	.byte $c1
	.byte $fd
	.word @song0ch3loop

; New song
@song0ch4:
@song0ch4loop:
@ref4:
	.byte $c1
	.byte $fd
	.word @song0ch4loop
