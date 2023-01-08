FTDI_USB_VID_DID = "i:0x0403:0x6014"
FTDI_USB_RECOVER_DEV = "d:001/039" # lsusb output: "Bus 001 Device 039: ID 0000:0000 Acme Inc. USB Serial Converter"

.PHONY: ftdi_eeprom_read.bin
ftdi_eeprom_read.bin:
	echo "filename=ftdi_eeprom_read.bin" > ftdi_read_eeprom.conf
	ftdi_eeprom --device $(FTDI_USB_VID_DID) --verbose --read-eeprom ftdi_read_eeprom.conf
	ls -lah ftdi_eeprom_read.bin

read_ftdi_eeprom: ftdi_eeprom_read.bin

set_ftdi_battery_charge_detection_enable: ftdi_eeprom_read.bin
	echo "filename=ftdi_eeprom_write.bin" > ftdi_write_eeprom.conf
	echo "user_data_addr=0" >> ftdi_write_eeprom.conf
	echo "user_data_file=ftdi_eeprom_patched.bin" >> ftdi_write_eeprom.conf
	cp ftdi_eeprom_read.bin ftdi_eeprom_patched.bin
	/usr/bin/printf '\x11' | dd conv=notrunc of=ftdi_eeprom_patched.bin bs=1 seek=0
	ftdi_eeprom --device $(FTDI_USB_VID_DID) --verbose --build-eeprom --flash-eeprom ftdi_write_eeprom.conf

set_ftdi_battery_charge_detection_disable: ftdi_eeprom_read.bin
	echo "filename=ftdi_eeprom_write.bin" > ftdi_write_eeprom.conf
	echo "user_data_addr=0" >> ftdi_write_eeprom.conf
	echo "user_data_file=ftdi_eeprom_patched.bin" >> ftdi_write_eeprom.conf
	cp ftdi_eeprom_read.bin ftdi_eeprom_patched.bin
	/usr/bin/printf '\x10' | dd conv=notrunc of=ftdi_eeprom_patched.bin bs=1 seek=0
	ftdi_eeprom --device $(FTDI_USB_VID_DID) --verbose --build-eeprom --flash-eeprom ftdi_write_eeprom.conf

set_ftdi_upduino3_1:
	echo "filename=ftdi_eeprom_write.bin" > ftdi_write_eeprom.conf
	echo "user_data_addr=0" >> ftdi_write_eeprom.conf
	echo "user_data_file=ftdi_eeprom_upduino_v3_1.bin" >> ftdi_write_eeprom.conf
	ftdi_eeprom --device $(FTDI_USB_VID_DID) --verbose --build-eeprom --flash-eeprom ftdi_write_eeprom.conf

recover_upduino_ftdi:
	echo "filename=ftdi_eeprom_write.bin" > ftdi_write_eeprom.conf
	echo "user_data_addr=0" >> ftdi_write_eeprom.conf
	echo "user_data_file=ftdi_eeprom_upduino_v3_1.bin" >> ftdi_write_eeprom.conf
	@echo "If recovery fails, you might lack privilegies to write to specific usb device. Try adding 'sudo' before next command"
	#sudo ftdi_eeprom --device $(FTDI_USB_RECOVER_DEV) --verbose --build-eeprom --flash-eeprom ftdi_write_eeprom.conf
	ftdi_eeprom --device $(FTDI_USB_RECOVER_DEV) --verbose --build-eeprom --flash-eeprom ftdi_write_eeprom.conf


.PHONY: clean
clean:
	rm -f ftdi_read_eeprom.conf ftdi_write_eeprom.conf
	rm -f ftdi_eeprom_read.bin ftdi_eeprom_patched.bin ftdi_eeprom_write.bin
