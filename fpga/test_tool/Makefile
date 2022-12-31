all: test_fpga_spi
	./test_fpga_spi

test_fpga_spi: main.c
	gcc main.c -o test_fpga_spi -lftdi

clean:
	rm -f test_fpga_spi main
