module z80_addr_decode (input [15:0] z80_a,
                        inout [7:0] z80_d,
                        input z80_rd,
                        input z80_wr,
                        input z80_m1,
                        input z80_iorq,
                        input z80_mreq,
                        output reg z80_d_oe,
                        output reg z80_d_dir,
                        output reg test_led);

    localparam Z80_IO_ADDR = 16'd12345;
    localparam D_IN = 1'b1;
    localparam D_OUT = 1'b0;

    reg [7:0] z80_io_data;

    initial begin
        z80_d_dir <= D_IN;
        z80_d_oe <= 1'b0;
        z80_io_data <= 8'd0;
        test_led <= 1'b1;
    end

    assign z80_d = z80_d_dir == D_OUT ? z80_io_data : 8'bZ;

    wire myIoAddr = z80_iorq == 1'b0
                    && z80_mreq == 1'b1
                    && z80_m1 == 1'b1
                    && z80_a == Z80_IO_ADDR
                    && (z80_rd == 1'b0 || z80_wr == 1'b0);

    wire clk;
    SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

    always @ (negedge clk) begin
        if (z80_rd == 1'b0 && myIoAddr == 1'b1) begin
            z80_d_dir <= D_OUT;
            test_led <= 1'b1;
        end else if (z80_wr == 1'b0 && myIoAddr == 1'b1) begin
            z80_d_dir <= D_IN;
            z80_io_data <= z80_d;
            test_led <= 1'b0;
        end else begin
            z80_d_dir <= D_IN;
        end
    end

endmodule
