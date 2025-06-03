build:
	ca65 src/main.s -o dist/game.o -g
	ld65 -C memory.cfg dist/game.o -o dist/game.nes --dbgfile dist/game.dbg

clean:
	rm dist/*.o dist/*.nes

fceux: build
	fceux dist/game.nes

mesen: build
	mono /home/dcoulombe/Downloads/Mesen.exe dist/game.nes
