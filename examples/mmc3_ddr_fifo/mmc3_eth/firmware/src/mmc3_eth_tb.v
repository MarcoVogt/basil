/**
 * ------------------------------------------------------------
 * Copyright (c) SILAB , Physics Institute of Bonn University
 * ------------------------------------------------------------
 */

`timescale 1ps / 1ps



module mmc3_eth_tb (
    input wire CLK_IN, // 100MHz

    //full speed
    inout wire [7:0] BUS_DATA,
    input wire [15:0] ADD,
    input wire RD_B,
    input wire WR_B,

    //high speed
    inout wire [7:0] FDATA,
    input wire FREAD,
    input wire FSTROBE,
    input wire FMODE,


    //SRAM
    output wire [19:0] SRAM_A,
    inout wire [15:0] SRAM_IO,
    output wire SRAM_BHE_B,
    output wire SRAM_BLE_B,
    output wire SRAM_CE1_B,
    output wire SRAM_OE_B,
    output wire SRAM_WE_B,


    output wire DUT_RESET,
    output wire DUT_CLK_BX,

    input wire DUT_TRIGGER,

    input wire DUT_HIT_OR,

    output wire DUT_CLK_DATA,
    input wire DUT_OUT_DATA_P, DUT_OUT_DATA_N,

    output wire CMD_OUT,
    output wire CMD_CLK

);

    // MODULE ADREESSES //
    localparam GPIO_BASEADDR = 32'h0000;
    localparam GPIO_HIGHADDR = 32'h1000-1;

    localparam GPIO2_BASEADDR = 32'h1000;
    localparam GPIO2_HIGHADDR = 32'h2000-1;

    localparam FERX_BASEADDR = 32'h6000;
    localparam FERX_HIGHADDR = 32'h7000-1;

    localparam FIFO_BASEADDR = 32'h8000;
    localparam FIFO_HIGHADDR = 32'h9000-1;

    localparam CMD_RD53_BASEADDR = 32'h9000;
    localparam CMD_RD53_HIGHADDR = 32'ha000-1;

    localparam FIFO_BASEADDR_DATA = 32'h8000_0000;
    localparam FIFO_HIGHADDR_DATA = 32'h9000_0000;

    localparam ABUSWIDTH = 16;

    //BASIL BUS mapping
    wire [15:0] BUS_ADD;
    assign BUS_ADD = ADD - 16'h4000;
    wire BUS_RD, BUS_WR;
    assign BUS_RD = ~RD_B;
    assign BUS_WR = ~WR_B;

    //Clock
    wire BUS_CLK, BX_CLK, CONF_CLK, CLK_2X_RX, CLK_RX, CLK_RX_DATA;
    assign BUS_CLK = FCLK_IN;
    assign BX_CLK = FCLK_IN;
    clock_multiplier #( .MULTIPLIER(8) ) i_clock_multiplier(.CLK(BUS_CLK),.CLOCK(CLK_2X_RX));
    clock_divider #(.DIVISOR(4)) i_clock_divisor_rx (.CLK(CLK_2X_RX), .RESET(1'b0), .CE(), .CLOCK(CLK_RX));
    clock_divider #(.DIVISOR(10)) i_clock_divisor_rx_data (.CLK(CLK_RX), .RESET(1'b0), .CE(), .CLOCK(CLK_RX_DATA));
    clock_divider #(.DIVISOR(4)) i_clock_divisor_spi ( .CLK(BUS_CLK), .RESET(1'b0), .CE(), .CLOCK(CONF_CLK));
    clock_divider #(.DIVISOR(2)) i_clock_divisor_cmd (.CLK(CLK_2X_RX), .RESET(1'b0), .CE(), .CLOCK(CMD_CLK));

    wire BUS_RST;
    // ------- RESRT/CLOCK  ------- //
    reset_gen ireset_gen(.CLK(BUS_CLK), .RST(BUS_RST));

    // MODULES //
    wire [7:0] GPIO_OUT;
    gpio
    #(
        .BASEADDR(GPIO_BASEADDR),
        .HIGHADDR(GPIO_HIGHADDR),

        .IO_WIDTH(8),
        .IO_DIRECTION(8'hff)
    ) i_gpio
    (
        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA[7:0]),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),
        .IO(GPIO_OUT)
    );

    wire DISABLE_LD, DUT_PIX_D_CONF;
    assign #1000 DUT_RESET = GPIO_OUT[0];
    ODDR bx_clk_gate(.D1(GPIO_OUT[2]), .D2(1'b0), .C(BX_CLK), .CE(1'b1), .R(1'b0), .S(1'b0), .Q(DUT_CLK_BX) );
    //ODDR out_clk_gate(.D1(GPIO_OUT[2]), .D2(1'b0), .C(~CLK_RX), .CE(1'b1), .R(1'b0), .S(1'b0), .Q() );
    assign DUT_PIX_D_CONF = GPIO_OUT[3];
    wire GATE_EN_PIX_SR_CNFG;
    assign GATE_EN_PIX_SR_CNFG = GPIO_OUT[4];
    assign DISABLE_LD = GPIO_OUT[5];


    wire [15:0] GPIO_EXT_TRIGGER;
    gpio
    #(
        .BASEADDR(GPIO2_BASEADDR),
        .HIGHADDR(GPIO2_HIGHADDR),
        .IO_WIDTH(16),
        .IO_DIRECTION(16'hffff),
        .IO_TRI(16'hffff)
	) i_gpio2
    (
        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),
        .IO(GPIO_EXT_TRIGGER)
    );


	mmc3_eth
	#() i_mmc3_eth
	(
	    .RESET_N ,
	    .clkin,

	    .rgmii_txd,
	    .rgmii_tx_ctl,
	    .rgmii_txc,
	    .rgmii_rxd,
	    .rgmii_rx_ctl,
	    .rgmii_rxc,
	    .mdio_phy_mdc,
	    .mdio_phy_mdio,
	    .phy_rst_n,

	    .LED,

	    .TCP_TX_DATA,
	    .TCP_TX_WR,
	    .TCP_TX_FULL
	);


    wire FIFO_READ, FIFO_EMPTY;
    wire [31:0] FIFO_DATA;
    assign FIFO_DATA = FIFO_DATA_SPI_RX;
    assign FIFO_EMPTY = FIFO_EMPTY_SPI_RX;
    assign FIFO_READ_SPI_RX = FIFO_READ;

    // SRAM FIFO
    wire USB_READ;
    assign USB_READ = FREAD & FSTROBE;

    sram_fifo #(
        .BASEADDR(FIFO_BASEADDR),
        .HIGHADDR(FIFO_HIGHADDR)
    ) i_out_fifo (
        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),

        .SRAM_A(SRAM_A),
        .SRAM_IO(SRAM_IO),
        .SRAM_BHE_B(SRAM_BHE_B),
        .SRAM_BLE_B(SRAM_BLE_B),
        .SRAM_CE1_B(SRAM_CE1_B),
        .SRAM_OE_B(SRAM_OE_B),
        .SRAM_WE_B(SRAM_WE_B),

        .USB_READ(USB_READ),
        .USB_DATA(FDATA),

        .FIFO_READ_NEXT_OUT(FIFO_READ),
        .FIFO_EMPTY_IN(FIFO_EMPTY),
        .FIFO_DATA(FIFO_DATA),

        .FIFO_NOT_EMPTY(),
        .FIFO_FULL(),
        .FIFO_NEAR_FULL(),
        .FIFO_READ_ERROR()
    );

endmodule
