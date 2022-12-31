all:
	apio clean
	apio verify
	apio build
	apio upload -s
	make -C test_tool

clean:
	apio clean
	make -C test_tool clean
