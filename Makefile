build:
	ca65 src/main.s -o dist/game.o -g
	ld65 -C memory.cfg dist/game.o -o dist/game.nes --dbgfile dist/game.dbg

build_scripts:
	cc -o bin/generate_metatiles src/scripts/generate_metatiles.c
	cc -o bin/compress_maps src/scripts/compress_maps.c

generate_metatiles:
	./bin/generate_metatiles src/nexxt/tiles.mtt2 src/data/tiles.2x2

compress_maps:
	./bin/compress_maps src/maps src/data/tiles.2x2

build_run_scripts: build_scripts generate_metatiles compress_maps

clean:
	rm dist/*.o dist/*.nes

fceux: build
	fceux game.nes

mesen: build
	/home/dcoulombe/dev/Mesen2/bin/linux-x64/Release/linux-x64/publish/Mesen dist/game.nes
	#/opt/Mesen dist/game.nes

complete: build_run_scripts mesen
