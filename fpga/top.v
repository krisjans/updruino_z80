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

reg [15:0] z80_a_f = 16'b0;
reg [15:0] z80_a_fo = 16'b0;
reg z80_mreq_f = 1;
reg z80_iorq_f = 1;
reg z80_rd_f = 1;
reg z80_rd_f2 = 1;
reg z80_rd_fo = 1;
reg z80_wr_f = 1;
reg z80_wr_f2 = 1;
reg z80_wr_fo = 1;

always @(posedge clk) begin
    z80_a_f <= z80_a;
    z80_mreq_f <= z80_mreq;
    z80_iorq_f <= z80_iorq;
    z80_rd_f <= z80_rd;
    z80_rd_f2 <= z80_rd_f;
    z80_wr_f <= z80_wr;
    z80_wr_f2 <= z80_wr_f;
    if ((z80_rd_f == 0 && z80_rd_f2 == 1)
        || (z80_wr_f == 0 && z80_wr_f2 == 1)) begin
        z80_a_fo <= z80_a_f;
        z80_rd_fo <= z80_rd_f;
        z80_wr_fo <= z80_wr_f;
    end
    if (z80_rd_f == 1) begin
        z80_rd_fo <= 1;
    end
    if (z80_wr_f == 1) begin
        z80_wr_fo <= 1;
    end
end

z80_addr_decode z80(.z80_a(z80_a_fo),
                    .z80_d(z80_d),
                    .z80_rd(z80_rd_fo),
                    .z80_wr(z80_wr_fo),
                    .z80_m1(z80_m1),
                    .z80_iorq(z80_iorq_f),
                    .z80_mreq(z80_mreq_f),
                    .z80_d_oe(z80_d_oe),
                    .z80_d_dir(z80_d_dir),
                    .z80_romcs(z80_romcs),
                    .spi_sck(spi_sck),
                    .spi_ss(spi_ss),
                    .spi_si(spi_si),
                    .spi_so(spi_so),
                    .clk(clk));

endmodule
