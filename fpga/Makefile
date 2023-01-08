all: clean rom_1k.txt rom_15k.txt
	apio clean
	apio verify
	apio build -v
	apio upload -s
	make -C test_tool

clean:
	apio clean
	make -C test_tool clean
	rm -f rom_15k.txt rom_1k.txt
	rm -f .sconsign.dblite

rom_15k.txt: z80_16k.rom Makefile
	hexdump -n $$((1024*15)) -s 0 -v -e '1/1 "%02x\n"' z80_16k.rom > rom_15k.txt

rom_1k.txt: z80_16k.rom Makefile
	hexdump -n 1024 -s $$((1024*15)) -v -e '1/1 "%02x\n"' z80_16k.rom > rom_1k.txt
