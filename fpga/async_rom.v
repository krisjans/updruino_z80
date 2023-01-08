module async_rom (
        input  [9:0] addr,
        output [7:0] data
    );

    localparam ROM_SIZE = 1024;

    reg [7:0] memory [ROM_SIZE - 1:0];

    initial begin
        $readmemh("rom_1k.txt", memory);
    end

    assign data = memory[addr];

endmodule