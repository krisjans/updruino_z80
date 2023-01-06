import sys
import spidev
import RPi.GPIO as GPIO
from time import sleep

print ("Program fpga ower /dev/spidev0.0")

if (len(sys.argv) < 2):
    print ("Error! no FPGA hardware file provided!")
    print ("Example:");
    print ("        " + sys.argv[0] + " hardware.bin")
    exit (1)

spi = spidev.SpiDev()
spi.open(0, 0)
spi.max_speed_hz = 10000000
spi.mode = 0b00
print (spi.cshigh)

with open(sys.argv[1], mode="rb") as file:
    fpga_data = file.read()

print ("fpga file size == " + str(len(fpga_data)))

fpga_reset = 25
fpga_ss = 24
GPIO.setmode(GPIO.BCM)
GPIO.setup(fpga_reset, GPIO.OUT)
GPIO.setup(fpga_ss, GPIO.OUT)
GPIO.output(fpga_reset, 0)
GPIO.output(fpga_ss, 0)
sleep(0.01)
GPIO.setup(fpga_reset, GPIO.IN)
sleep(0.01)
GPIO.setup(fpga_ss, GPIO.IN)
sleep(0.1)
spi.writebytes2(fpga_data)
spi.writebytes2([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])

GPIO.cleanup()
spi.close()
