all: build
	apio upload -s
	make -C test_tool

sim:
	apio sim

build: clean rom_1k.txt rom_15k.txt
	rm -f apio_log.txt
	apio verify | tee apio_log.txt
	apio build -v | tee apio_log.txt
	@grep -i "warning" apio_log.txt || echo "no warnings"
	@grep -i "error" apio_log.txt || echo "no errors"
	@grep "Device utilisation:" -A 15 apio_log.txt

clean:
	apio clean
	make -C test_tool clean
	rm -f rom_15k.txt rom_1k.txt
	rm -f .sconsign.dblite

rom_15k.txt: z80_16k.rom Makefile
	hexdump -n $$((1024*15)) -s 0 -v -e '1/1 "%02x\n"' z80_16k.rom > rom_15k.txt

rom_1k.txt: z80_16k.rom Makefile
	hexdump -n 1024 -s $$((1024*15)) -v -e '1/1 "%02x\n"' z80_16k.rom > rom_1k.txt
