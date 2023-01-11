`timescale 100 ns / 10 ns

module z80_bus_tb();

`define DUMPSTR(x) `"x.vcd`"

parameter DURATION = 100000;

reg clk = 0;
always #0.5 clk = ~clk;

reg [15:0] z80_a;
wire [7:0] z80_d;
reg z80_wr;
reg z80_rd;
reg z80_iorq;
reg z80_mreq;
reg z80_m1;

initial begin
    z80_a = 1020;
    z80_wr = 1;
    z80_rd = 1;
    z80_iorq = 1;
    z80_mreq = 1;
    z80_m1 = 1;
end

z80_addr_decode UUT(
    .z80_a(z80_a),
    .z80_d(z80_d),
    .z80_wr(z80_wr),
    .z80_rd(z80_rd),
    .z80_iorq(z80_iorq),
    .z80_mreq(z80_mreq),
    .z80_m1(z80_m1),
    .clk(clk)
);

always @(posedge clk) begin
    #10;
    z80_rd = 0;
    z80_m1 = 0;
    z80_mreq = 0;
    #10;
    z80_rd = 1;
    z80_m1 = 1;
    z80_mreq = 1;
    #10;
    z80_a += 1;
    #10;
end

initial begin

  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, z80_bus_tb);

   #(DURATION);
  $finish;
end

endmodule
