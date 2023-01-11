module top(input [15:0] z80_a,
            inout [7:0] z80_d,
            input z80_rd,
            input z80_wr,
            input z80_m1,
            input z80_iorq,
            input z80_mreq,
            output z80_d_oe,
            output z80_d_dir,
            output z80_romcs,
            input spi_sck,
            input spi_ss,
            input spi_si,
            output spi_so);

wire clk;
SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
defparam inthosc.CLKHF_DIV = "0b01";

z80_addr_decode z80(.z80_a(z80_a),
                    .z80_d(z80_d),
                    .z80_rd(z80_rd),
                    .z80_wr(z80_wr),
                    .z80_m1(z80_m1),
                    .z80_iorq(z80_iorq),
                    .z80_mreq(z80_mreq),
                    .z80_d_oe(z80_d_oe),
                    .z80_d_dir(z80_d_dir),
                    .z80_romcs(z80_romcs),
                    .spi_sck(spi_sck),
                    .spi_ss(spi_ss),
                    .spi_si(spi_si),
                    .spi_so(spi_so),
                    .clk(clk));

endmodule
