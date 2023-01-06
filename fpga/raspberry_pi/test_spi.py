import spidev

print ("hello")

spi = spidev.SpiDev()
spi.open(0, 0)
spi.max_speed_hz = 10000000
spi.mode = 0b00

tx = [1, 22, 133, 4, 5, 6, 7, 88]

print ("Transmit 8 bytes to /dev/spidev0.0:")
print (tx)

rx = spi.xfer(tx)

print ("Received:")
print (rx)

spi.close()
