#include <stdio.h>
#include <ftdi.h>

static int ftdi_send_cmd_0arg(struct ftdi_context *ftdic, uint8_t cmd) {
    int rc = ftdi_write_data(ftdic, &cmd, 1);
    if (rc != sizeof(cmd)) {
        printf("Error %d in function %s line %d\n", rc, __FUNCTION__, __LINE__);
        return rc ? rc : -1;
    }
    return 0;
}

static int ftdi_send_cmd_1arg(struct ftdi_context *ftdic, uint8_t cmd, uint8_t arg0) {
    uint8_t data[2] = {cmd, arg0};
    int rc = ftdi_write_data(ftdic, data, sizeof(data));
    if (rc != sizeof(data)) {
        printf("Error %d in function %s line %d\n", rc, __FUNCTION__, __LINE__);
        return rc ? rc : -777;
    }
    return 0;
}

static int ftdi_send_cmd_2arg(struct ftdi_context *ftdic, uint8_t cmd, uint8_t arg0, uint8_t arg1) {
    uint8_t data[3] = {cmd, arg0, arg1};
    int rc = ftdi_write_data(ftdic, data, sizeof(data));
    if (rc != sizeof(data)) {
        printf("Error %d in function %s line %d\n", rc, __FUNCTION__, __LINE__);
        return rc ? rc : -777;
    }
    return 0;
}

static int ftdi_read_data_retry(struct ftdi_context *ftdic, uint8_t *data, int len) {
    int i = 0;
    unsigned retry = 100;
    while (i < len && --retry) {
        int rc = ftdi_read_data(ftdic, &data[i], len);
        if (rc < 0) {
            printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
            return rc;
        }
        i += rc;
        if (rc == 0 && retry < 10) {
            usleep(100);
        }
    }
    return i;
}


#define FTDI_SPI_SCK 0x01
#define FTDI_SPI_MOSI 0x02
#define FTDI_SPI_MISO 0x03
#define FTDI_SPI_CS     0x10
#define FTDI_FPGA_CDONE 0x40
#define FTDI_FPGA_RESET 0x80

static int set_spi_cs(struct ftdi_context *ftdic, uint8_t cs) {
    uint8_t val = FTDI_FPGA_RESET | (cs ? FTDI_SPI_CS : 0);
    uint8_t dir = cs ? 0 : (FTDI_SPI_CS | FTDI_SPI_MOSI | FTDI_SPI_SCK);
    int rc = ftdi_send_cmd_2arg(ftdic, SET_BITS_LOW, val, dir);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }
    return 0;
}

static int spi_cs_hi(struct ftdi_context *ftdic) {
    int rc = set_spi_cs(ftdic, 1);
    usleep(10000);
    return rc;
}

static int spi_cs_lo(struct ftdi_context *ftdic) {
    int rc = set_spi_cs(ftdic, 0);
    usleep(10000);
    return rc;
}

int spi_init(struct ftdi_context *ftdic)
{
    int rc = 0;
    rc = ftdi_init(ftdic);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }

    rc = ftdi_set_interface(ftdic, INTERFACE_A);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }

    rc = ftdi_usb_open(ftdic, 0x0403, 0x6014);
    if (rc) {
        rc = ftdi_usb_open(ftdic, 0x0403, 0x6010);
        if (rc) {
            printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
            return rc;
        }
    }

    rc = ftdi_usb_reset(ftdic);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }

    rc = ftdi_usb_purge_buffers(ftdic);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }

    rc = ftdi_set_bitmode(ftdic, 0xff, BITMODE_MPSSE);
    if (rc < 0) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }

    rc = ftdi_send_cmd_0arg(ftdic, EN_DIV_5);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }
    rc = ftdi_send_cmd_2arg(ftdic, TCK_DIVISOR, 0, 0x01);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }

    return 0;
}

static int spi_xfer(struct ftdi_context *ftdic, uint8_t *tx, uint8_t *rx, int len)
{
    int rc = 0;
    const uint8_t cmd = (rx ? MPSSE_DO_READ : 0)
                        | MPSSE_DO_WRITE
                        | MPSSE_WRITE_NEG;

    rc = ftdi_send_cmd_2arg(ftdic, cmd, len - 1, (len - 1) >> 8);
    if (rc) {
        printf("Error in function %s line %d\n", __FUNCTION__, __LINE__);
        return rc;
    }

    rc = ftdi_write_data(ftdic, tx, len);
    if (rc != len) {
        printf("Error %d in function %s line %d\n", rc, __FUNCTION__, __LINE__);
        return rc ? rc : -666;
    }

    if (rx) {
        int rc = ftdi_read_data_retry(ftdic, rx, len);
        if (rc != len) {
            printf("Error %d in function %s line %d\n", rc, __FUNCTION__, __LINE__);
            return rc ? rc : -666;
        }
    }

    return 0;
}

static int spi_close(struct ftdi_context *ftdic) {
    ftdi_usb_close(ftdic);
}

int main()
{
    struct ftdi_context ftdic;
    int rc = 0;

    rc = spi_init(&ftdic);
    if (rc) {
        printf("Error during ftdi init, rc==%d\n", rc);
        spi_close(&ftdic);
        return rc;
    }

    uint8_t rx[8];
    uint8_t tx[8] = {101, 102, 103, 104, 105, 106, 107, 108};

    rc = spi_cs_lo(&ftdic);
    if (rc) {
        printf("Error during ftdi spi cs select, rc==%d\n", rc);
        spi_close(&ftdic);
        return rc;
    }

    rc = spi_xfer(&ftdic, tx, rx, sizeof(rx));
    if (rc) {
        printf("Error during ftdi spi xfer, rc==%d\n", rc);
        spi_close(&ftdic);
        return rc;
    }
    for (size_t i = 0; i < 8; i++) {
        printf("got 0x%02x\n", rx[i]);
    }

    rc = spi_cs_hi(&ftdic);
    if (rc) {
        printf("Error during ftdi spi cs deselect, rc==%d\n", rc);
        spi_close(&ftdic);
        return rc;
    }

    rc = spi_close(&ftdic);
    if (rc) {
        printf("Error closing ftdi spi, rc==%d\n", rc);
        return rc;
    }

    return 0;
}
