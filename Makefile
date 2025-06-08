build:
	ca65 src/main.s -o dist/game.o -g
	ld65 -C memory.cfg dist/game.o -o dist/game.nes --dbgfile dist/game.dbg

clean:
	rm dist/*.o dist/*.nes

fceux: build
	fceux game.nes

mesen: build
	/home/dcoulombe/dev/Mesen2/bin/linux-x64/Release/linux-x64/publish/Mesen dist/game.nes
	#/opt/Mesen dist/game.nes
