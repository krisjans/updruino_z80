module z80_addr_decode #(
                            parameter
                                IO_0 = 16'd12345,
                                IO_1 = 16'd12347,
                                IO_2 = 16'd12349,
                                IO_3 = 16'd12351,
                                IO_4 = 16'd12353,
                                IO_5 = 16'd12355,
                                IO_6 = 16'd12357,
                                IO_7 = 16'd12359
                        )
                       (input [15:0] z80_a,
                        inout [7:0] z80_d,
                        input z80_rd,
                        input z80_wr,
                        input z80_m1,
                        input z80_iorq,
                        input z80_mreq,
                        /* output reg z80_d_oe,*/
                        output reg ram_a13,
                        output reg ram_a14,
                        output reg ram_cs,
                        output z80_d_dir,
                        output reg z80_romcs,
                        input [8*8-1:0] spi_to_z80_flat,
                        output [8*8-1:0] z80_to_spi_flat,
                        input clk);

    wire [7:0] spi_to_z80[7:0];
    reg [7:0] z80_to_spi[7:0];

    assign {spi_to_z80[7], spi_to_z80[6], spi_to_z80[5], spi_to_z80[4],
            spi_to_z80[3], spi_to_z80[2], spi_to_z80[1], spi_to_z80[0]} = spi_to_z80_flat;
    assign z80_to_spi_flat = {z80_to_spi[7], z80_to_spi[6], z80_to_spi[5], z80_to_spi[4],
                              z80_to_spi[3], z80_to_spi[2], z80_to_spi[1], z80_to_spi[0]};

    wire [7:0] data_rom;
    wire [7:0] data_ram;
    reg w_en;
    initial w_en = 0;

    wire [7:0] rom_d_out;
    wire [13:0] ram_addr;
    assign ram_addr[9:0] = z80_a[9:0];
    assign ram_addr[13:10] = z80_a[13:10] - 1;
    reg [7:0] z80_d_f = 0;
    reg [7:0] z80_d_f2 = 0;
    reg z80_wr_f = 1;
    reg z80_wr_f2 = 1;
    reg z80_wr_f3 = 1;
    reg [16:0] z80_a_f = 0;
    reg [16:0] z80_a_f2 = 0;
    reg [13:0] ram_addr_f = 0;
    reg [13:0] ram_addr_f2 = 0;
    reg myRom_f = 0;
    reg myRom_f2 = 0;
    reg z80_romcs_f = 0;
    reg z80_romcs_f2 = 0;
    reg [13:0] ram_addr_fo = 0;
    reg [7:0] z80_d_fo = 0;
    block_ram my_ram(
        .din(z80_d_fo),
        .addr(ram_addr),
        .addr_w(ram_addr_fo),
        .write_en(w_en),
        .clk(clk),
        .dout(data_ram)
    );
    always @(posedge clk)
    begin
        z80_d_f <= z80_d;
        z80_d_f2 <= z80_d_f;
        z80_a_f <= z80_a;
        z80_a_f2 <= z80_a_f;
        ram_addr_f <= ram_addr;
        ram_addr_f2 <= ram_addr_f;
        z80_wr_f3 <= z80_wr_f2;
        z80_wr_f2 <= z80_wr_f;
        z80_wr_f <= z80_wr;
        myRom_f <= myRom;
        myRom_f2 <= myRom_f;
        z80_romcs_f <= z80_romcs;
        z80_romcs_f2 <= z80_romcs_f;

        if (z80_wr_f3 == 1 && z80_wr_f2 == 0 && myRom_f2 == 1'b1 && z80_romcs_f2 == ZX_ROM_DISABLE && z80_a_f2 > 16'h1fff) begin
            w_en <= 1;
            z80_d_fo <= z80_d_f2;
            ram_addr_fo <= ram_addr_f2;
        end else begin
            w_en <= 0;
        end
    end

    async_rom my_rom(
        .addr(z80_a[9:0]),
        .data(data_rom)
    );

    assign rom_d_out = (z80_a[15:10] == 6'b0) ? data_rom : data_ram;

    localparam Z80_ACTIVATE_SHADOW_ROM = 8'd85;

    localparam D_IN = 1'b1; // from Z80 to FPGA
    localparam D_OUT = 1'b0; // from FPGA to Z80

    localparam ZX_ROM_DISABLE = 1'b0;
    localparam ZX_ROM_ENABLE = 1'b1;

    initial begin
        /* z80_d_oe <= 1'b0; */
        ram_cs <= 1;
        ram_a13 <= 0;
        ram_a14 <= 0;
        z80_romcs <= ZX_ROM_DISABLE;
        z80_to_spi[0] <= 8'd11;
        z80_to_spi[1] <= 8'd22;
        z80_to_spi[2] <= 8'd33;
        z80_to_spi[3] <= 8'd44;
        z80_to_spi[4] <= 8'd55;
        z80_to_spi[5] <= 8'd66;
        z80_to_spi[6] <= 8'd77;
        z80_to_spi[7] <= 8'd88;
    end

    wire ioAddr = z80_iorq == 1'b0
                  && z80_m1 == 1'b1;
    wire myIoAddr0 = ioAddr && z80_a == IO_0;
    wire myIoAddr1 = ioAddr && z80_a == IO_1;
    wire myIoAddr2 = ioAddr && z80_a == IO_2;
    wire myIoAddr3 = ioAddr && z80_a == IO_3;
    wire myIoAddr4 = ioAddr && z80_a == IO_4;
    wire myIoAddr5 = ioAddr && z80_a == IO_5;
    wire myIoAddr6 = ioAddr && z80_a == IO_6;
    wire myIoAddr7 = ioAddr && z80_a == IO_7;

    wire [7:0] z80_d_out = myIoAddr0 == 1'b1 ? spi_to_z80[0]
                            : myIoAddr1 == 1'b1 ? spi_to_z80[1]
                            : myIoAddr2 == 1'b1 ? spi_to_z80[2]
                            : myIoAddr3 == 1'b1 ? spi_to_z80[3]
                            : myIoAddr4 == 1'b1 ? spi_to_z80[4]
                            : myIoAddr5 == 1'b1 ? spi_to_z80[5]
                            : myIoAddr6 == 1'b1 ? spi_to_z80[6]
                            : myIoAddr7 == 1'b1 ? spi_to_z80[7]
                            : 8'hff;

    wire myIoAddr = myIoAddr0 == 1'b1
                    || myIoAddr1 == 1'b1
                    || myIoAddr2 == 1'b1
                    || myIoAddr3 == 1'b1
                    || myIoAddr4 == 1'b1
                    || myIoAddr5 == 1'b1
                    || myIoAddr6 == 1'b1
                    || myIoAddr7 == 1'b1;

    wire myRom = z80_mreq == 1'b0
                  && (z80_a[15:14] == 2'b0);

    //assign z80_d_dir = (z80_rd == 1'b0 && z80_wr == 1'b1 && myIoAddr == 1'b1) ? D_OUT : D_IN;
    assign z80_d_dir = (z80_rd == 1'b0 && z80_wr == 1'b1 && ((myIoAddr == 1'b1) || ((myRom == 1'b1) && (z80_romcs == ZX_ROM_DISABLE)))) ? D_OUT : D_IN;

    //assign z80_d = (z80_rd == 1'b0 && z80_wr == 1'b1 && myIoAddr == 1'b1) ? z80_d_out : 8'bZ;
    assign z80_d = (z80_rd == 1'b0 && z80_wr == 1'b1 && ((myIoAddr == 1'b1) || ((myRom == 1'b1) && (z80_romcs == ZX_ROM_DISABLE)))) ? ((myRom == 1'b1) ? rom_d_out : z80_d_out): 8'bZ;

    always @(posedge clk)
    begin
        if (z80_m1 == 1'b0 && z80_rd == 1'b0 && z80_wr == 1'b1 && z80_a == 16'h0000 && z80_iorq == 1'b1 && z80_mreq == 1'b0) begin
            if (z80_to_spi[0] == Z80_ACTIVATE_SHADOW_ROM) begin
                z80_romcs <= ZX_ROM_DISABLE;
            end else begin
                z80_romcs <= ZX_ROM_ENABLE;
            end
        end
        if (z80_rd == 1'b1 && z80_wr == 1'b0) begin
            if (myIoAddr0) z80_to_spi[0] <= z80_d;
            if (myIoAddr1) z80_to_spi[1] <= z80_d;
            if (myIoAddr2) z80_to_spi[2] <= z80_d;
            if (myIoAddr3) z80_to_spi[3] <= z80_d;
            if (myIoAddr4) z80_to_spi[4] <= z80_d;
            if (myIoAddr5) z80_to_spi[5] <= z80_d;
            if (myIoAddr6) z80_to_spi[6] <= z80_d;
            if (myIoAddr7) z80_to_spi[7] <= z80_d;
        end
    end

endmodule
