module z80_addr_decode (input [15:0] z80_a,
                        input z80_rd,
                        input z80_wr,
                        input z80_m1,
                        input z80_iorq,
                        input z80_mreq,
                        output reg test_led);

    initial test_led = 1'b1;

    localparam Z80_IO_ADDR = 16'd12345;

    wire myIoAddr = z80_iorq == 1'b0
                    && z80_mreq == 1'b1
                    && z80_m1 == 1'b1
                    && z80_a == Z80_IO_ADDR
                    && (z80_rd == 1'b0 || z80_wr == 1'b0);

    wire clk;
    SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

    always @ (negedge clk) begin
        if (z80_rd == 1'b0 && myIoAddr == 1'b1) begin
            test_led <= 1'b1;
        end else if (z80_wr == 1'b0 && myIoAddr == 1'b1) begin
            test_led <= 1'b0;
        end
    end

endmodule
