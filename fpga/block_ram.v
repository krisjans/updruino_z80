module block_ram (din, addr, write_en, clk, dout);// 512x8
parameter addr_width = 14;
parameter data_width = 8;
input [addr_width-1:0] addr;
input [data_width-1:0] din;
input write_en, clk;
output [data_width-1:0] dout;
reg [data_width-1:0] dout;

reg [data_width-1:0] memram [(1024*15)-1:0];
initial begin
    $readmemh("rom_15k.txt", memram);
end

always @(posedge clk)
begin
    if (write_en)
        memram[(addr)] <= din;
    dout = memram[addr];
end
endmodule