module z80_addr_decode (input [15:0] z80_a,
                        inout [7:0] z80_d,
                        input z80_rd,
                        input z80_wr,
                        input z80_m1,
                        input z80_iorq,
                        input z80_mreq,
                        output reg z80_d_oe,
                        output z80_d_dir,
                        output reg test_led,
                        input spi_sck,
                        input spi_ss,
                        input spi_si,
                        output spi_so);

    wire clk;
    SB_HFOSC inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
    defparam inthosc.CLKHF_DIV = "0b01";

    localparam Z80_IO_ADDR = 16'd12345;
    localparam D_IN = 1'b1; // from Z80 to FPGA
    localparam D_OUT = 1'b0; // from FPGA to Z80

    reg [7:0] spi_to_z80[7:0];
    reg [7:0] z80_to_spi[7:0];

    initial begin
        z80_d_oe <= 1'b0;
        spi_to_z80[0] <= 8'd111;
        spi_to_z80[1] <= 8'd122;
        spi_to_z80[2] <= 8'd133;
        spi_to_z80[3] <= 8'd144;
        spi_to_z80[4] <= 8'd155;
        spi_to_z80[5] <= 8'd166;
        spi_to_z80[6] <= 8'd177;
        spi_to_z80[7] <= 8'd188;
        test_led <= 1'b1;
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
                  && z80_mreq == 1'b1
                  && z80_m1 == 1'b1;
    wire myIoAddr0 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd0);
    wire myIoAddr1 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd2);
    wire myIoAddr2 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd4);
    wire myIoAddr3 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd6);
    wire myIoAddr4 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd8);
    wire myIoAddr5 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd10);
    wire myIoAddr6 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd12);
    wire myIoAddr7 = ioAddr && z80_a == (Z80_IO_ADDR + 16'd14);

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

    assign z80_d_dir = (z80_rd == 1'b0 && z80_wr == 1'b1 && myIoAddr == 1'b1) ? D_OUT : D_IN;

    assign z80_d = (z80_rd == 1'b0 && z80_wr == 1'b1 && myIoAddr == 1'b1) ? (z80_d_out) : 8'bZ;

    always @(posedge clk)
    begin
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

// ------------------------------------------------------------------------
// SPI stuff --------------------------------------------------------------
// ------------------------------------------------------------------------

    localparam SPICR0  = 'h08,
               SPICR1  = 'h09,
               SPICR2  = 'h0a,
               SPIBR   = 'h0b,
               SPISR   = 'h0c,
               SPISR_TIP  = 7,
               SPISR_BUSY = 6,
               SPISR_TRDY = 4,
               SPISR_RRDY = 3,
               SPITXDR = 'h0d,
               SPIRXDR = 'h0e,
               SPICSR  = 'h0f;

    localparam SB_WR = 1'b1, SB_RD = 1'b0;

    localparam SM_SET_SPICR0 = 0,
               SM_SET_SPICR1 = SM_SET_SPICR0 + 1,
               SM_SET_SPICR2 = SM_SET_SPICR1 + 1,
               SM_SET_SPIBR  = SM_SET_SPICR2 + 1,
               SM_SET_SPICSR = SM_SET_SPIBR + 1,
               SM_RD_STS = SM_SET_SPICSR + 1,
               SM_TRANSMIT = SM_RD_STS + 1,
               SM_RECEIVE = SM_TRANSMIT + 1;
    reg [7:0] spi_sm_state;

    reg sbrw;
    reg [7:0] sbadr;
    reg [7:0] sbdati;
    wire [7:0] sbdato;
    reg sbstb;
    wire sback;

    SB_SPI SB_SPI_inst(
        .SBCLKI(clk),
        .SBRWI(sbrw),
        .SBSTBI(sbstb),
        .SBADRI0(sbadr[0]),
        .SBADRI1(sbadr[1]),
        .SBADRI2(sbadr[2]),
        .SBADRI3(sbadr[3]),
        .SBADRI4(sbadr[4]),
        .SBADRI5(sbadr[5]),
        .SBADRI6(sbadr[6]),
        .SBADRI7(sbadr[7]),
        .SBDATI0(sbdati[0]),
        .SBDATI1(sbdati[1]),
        .SBDATI2(sbdati[2]),
        .SBDATI3(sbdati[3]),
        .SBDATI4(sbdati[4]),
        .SBDATI5(sbdati[5]),
        .SBDATI6(sbdati[6]),
        .SBDATI7(sbdati[7]),
        .SBDATO0(sbdato[0]),
        .SBDATO1(sbdato[1]),
        .SBDATO2(sbdato[2]),
        .SBDATO3(sbdato[3]),
        .SBDATO4(sbdato[4]),
        .SBDATO5(sbdato[5]),
        .SBDATO6(sbdato[6]),
        .SBDATO7(sbdato[7]),
        .SBACKO(sback),
        .SO(spi_so),
        .SI(spi_si),
        .SCKI(spi_sck),
      .SCSNI(spi_ss)
    );
    defparam SB_SPI_inst.BUS_ADDR74 = "0b0000"; // should not be necessary, but "apio build" fails without it

    reg [2:0] spi_tx_index;
    reg [2:0] spi_rx_index;

    reg spi_old_ss;

    initial begin
        sbstb = 0;
        sbrw = 0;
        sbadr = 0;
        sbdati = 0;
        spi_tx_index = 0;
        spi_rx_index = 0;
        spi_old_ss = 0;
        spi_sm_state = SM_SET_SPICR0;
    end

    always @(posedge clk)
    begin
        if (sbstb == 1'b0) begin
            case (spi_sm_state)
            SM_SET_SPICR0 : begin
                sbadr <= SPICR0;
                sbdati <= 8'h00;
                sbrw <= SB_WR;
            end
            SM_SET_SPICR1 : begin
                sbadr <= SPICR1;
                sbdati <= 8'h80;
                sbrw <= SB_WR;
            end
            SM_SET_SPICR2 : begin
                sbadr <= SPICR2;
                sbdati <= 8'h01;
                sbrw <= SB_WR;
            end
            SM_SET_SPIBR : begin
                sbadr <= SPIBR;
                sbdati <= 8'h00;
                sbrw <= SB_WR;
            end
            SM_SET_SPICSR : begin
                sbadr <= SPICSR;
                sbdati <= 8'h00;
                sbrw <= SB_WR;
            end
            SM_RD_STS: begin
                sbadr <= SPISR;
                sbrw <= SB_RD;
            end
            SM_TRANSMIT: begin
                sbadr <= SPITXDR;
                sbdati <= z80_to_spi[spi_tx_index];
                spi_tx_index <= spi_tx_index + 1;
                sbrw <= SB_WR;
            end
            SM_RECEIVE: begin
                sbadr <= SPIRXDR;
                sbrw <= SB_RD;
            end
            endcase
            sbstb <= 1;

        end else begin
            if (sback == 1'b1) begin
                case (spi_sm_state)
                SM_SET_SPICR0,
                SM_SET_SPICR1,
                SM_SET_SPICR2,
                SM_SET_SPIBR,
                SM_SET_SPICSR : begin
                    spi_sm_state <= spi_sm_state + 1;
                end
                SM_RD_STS: begin
                    if (spi_ss == 0) begin
                        if (spi_old_ss == 1) begin
                            spi_old_ss <= 0;
                            spi_rx_index <= 0;
                            spi_tx_index <= 0;
                            spi_sm_state <= SM_TRANSMIT;
                        end
                        if (sbdato[SPISR_TRDY] == 1) begin
                            test_led <= 1'b0;
                            spi_sm_state <= SM_TRANSMIT;
                        end else if (sbdato[SPISR_RRDY] == 1) begin
                            test_led <= 1'b0;
                            spi_sm_state <= SM_RECEIVE;
                        end
                    end else begin
                        if (spi_old_ss == 0) begin
                            spi_old_ss <= 1;
                            test_led <= 1'b1;
                            spi_tx_index <= 0;
                            spi_sm_state <= SM_TRANSMIT;
                        end
                    end
                end
                SM_TRANSMIT: begin
                    spi_sm_state <= SM_RD_STS;
                end
                SM_RECEIVE: begin
                    spi_to_z80[spi_rx_index] <= sbdato;
                    spi_rx_index <= spi_rx_index + 1;
                    spi_sm_state <= SM_RD_STS;
                end
                endcase
                sbstb <= 0;
            end
        end
    end
endmodule
