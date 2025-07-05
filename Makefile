build:
	ca65 src/main.s -o dist/game.o -g
	ld65 -C memory.cfg dist/game.o -o dist/game.nes --dbgfile dist/game.dbg

build_scripts:
	cc -o bin/generate_metatiles src/scripts/generate_metatiles.c
	cc -o bin/generate_maps src/scripts/generate_maps.c -lcjson
	cc -o bin/generate_palettes src/scripts/generate_palettes.c

generate_metatiles:
	./bin/generate_metatiles src/assets/nexxt/tiles.mtt2 src/data/metatiles.bin src/data/metatiles.prop

generate_maps:
	./bin/generate_maps src/assets/tiled/level*.json src/maps src/objects

generate_palettes:
	./bin/generate_palettes src/data

export_maps:
	/opt/Tiled.AppImage --export-map json src/assets/tiled/level1.tmx src/assets/tiled/level1.json

generate_music:
	wine /opt/famitracker/Dn-FamiTracker.exe src/assets/famitracker/music.dnm -export src/assets/famitracker/music.txt
	sed -i 's/# SEQUENCES block/# Macros/g' src/assets/famitracker/music.txt
	sed -i 's/# INSTRUMENTS block/# Instruments/g' src/assets/famitracker/music.txt
	wine /opt/famitone5/text2data/text2vol5.exe ./src/assets/famitracker/music.txt -ca65 -ntsc
	mv ./src/assets/famitracker/music.s ./src/data/music.s
	rm ./src/assets/famitracker/music.txt

generate_sfx:
	wine /opt/famitracker/Dn-FamiTracker.exe src/assets/famitracker/sfx.dnm -export src/assets/famitracker/sfx.nsf
	wine /opt/famitone5/nsf2data/nsf2data5.exe ./src/assets/famitracker/sfx.nsf -ca65 -ntsc
	mv ./src/assets/famitracker/sfx.s ./src/data/sfx.s
	rm ./src/assets/famitracker/sfx.nsf

build_run_scripts: export_maps build_scripts generate_metatiles generate_maps generate_palettes

clean:
	rm dist/*.o dist/*.nes

fceux: build
	fceux dist/game.nes

mesen: build
	/home/dcoulombe/dev/Mesen2/bin/linux-x64/Release/linux-x64/publish/Mesen dist/game.nes
	#/opt/Mesen dist/game.nes

complete: build_run_scripts generate_music generate_sfx mesen
