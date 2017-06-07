/**
 * ------------------------------------------------------------
 * Copyright (c) SILAB , Physics Institute of Bonn University 
 * ------------------------------------------------------------
 */

module te0725 (
    input wire  USER_RESET,
    input wire  SYS_CLK,
    
    input wire  UART_RX,
    output wire UART_TX,
    
    output wire LED,
    output wire [3:0] GPIO_LED,
    input wire  [3:0] GPIO_DIP,
    
    //HyperRAM
    inout wire  [7:0] H1_D,
    input wire  H1_RWDS,
    output wire H1_CLK_P,
    output wire H1_CLK_N,
    output wire H1_RESET_N,
    output wire H1_CS
    
/*    
    // trigger
    input wire [2:0] LEMO_RX,
    output wire [2:0] LEMO_TX,
    input wire RJ45_RESET,
    input wire RJ45_TRIGGER
*/
);   
    wire CLKFBOUT, CLKOUT0, CLKOUT1, CLKOUT2, CLKOUT3, CLKOUT4, CLKOUT5, CLKFBIN, LOCKED;
//    wire CLKFBOUT_TDC, CLKOUT_160_TDC, CLKOUT_320_TDC, CLKFBIN_TDC, LOCKED_TDC;
    
    wire RST, BUS_CLK, BUS_RST, SPI_CLK;
    
    assign BUS_RST = USER_RESET;
    
   PLL_BASE #(
      .BANDWIDTH("OPTIMIZED"),             // "HIGH", "LOW" or "OPTIMIZED" 
      .CLKFBOUT_MULT(8),                   // Multiply value for all CLKOUT clock outputs (1-64)
      .CLKFBOUT_PHASE(0.0),                // Phase offset in degrees of the clock feedback output (0.0-360.0).
      .CLKIN_PERIOD(10.0),                  // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
      .CLKOUT0_DIVIDE(16),   // 50 MHz
      .CLKOUT1_DIVIDE(16),   // 50 MHz
      .CLKOUT2_DIVIDE(80),  // 10 MHz
      .CLKOUT3_DIVIDE(), 
      .CLKOUT4_DIVIDE(), 
      .CLKOUT5_DIVIDE(),
      // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLK_FEEDBACK("CLKFBOUT"),           // Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
      .COMPENSATION("SYSTEM_SYNCHRONOUS"), // "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL" 
      .DIVCLK_DIVIDE(1),                   // Division value for all output clocks (1-52)
      .REF_JITTER(0.1),                    // Reference Clock Jitter in UI (0.000-0.999).
      .RESET_ON_LOSS_OF_LOCK("FALSE")      // Must be set to FALSE
   )
   PLL_BASE_inst (
      .CLKFBOUT(CLKFBOUT), // 1-bit output: PLL_BASE feedback output
      // CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
      .CLKOUT0(CLKOUT0),
      .CLKOUT1(CLKOUT1),
      .CLKOUT2(CLKOUT2),
      .CLKOUT3(),
      .CLKOUT4(),
      .CLKOUT5(),
      .LOCKED(LOCKED),     // 1-bit output: PLL_BASE lock status output
      .CLKFBIN(CLKFBIN),   // 1-bit input: Feedback clock input
      .CLKIN(SYS_CLK),       // 1-bit input: Clock input
      .RST(USER_RESET)            // 1-bit input: Reset input
   );
   
    wire RX_CLK, TX_CLK, UART_CLK;
    assign RST = USER_RESET | !LOCKED;
    assign CLKFBIN = CLKFBOUT;//BUFG BUFG_FB (  .O(CLKFBIN),  .I(CLKFBOUT) );
//    assign CLKFBIN_TDC = CLKFBOUT_TDC;//BUFG BUFG_FB (  .O(CLKFBIN),  .I(CLKFBOUT) );
    BUFG BUFG_BUS(  .O(BUS_CLK),  .I(CLKOUT0) );
    BUFG BUFG_UART( .O(UART_CLK), .I(CLKOUT1) );
    BUFG BUFG_SPI(  .O(SPI_CLK),  .I(CLKOUT2) );
    
    wire TCP_TX_FULL;
    wire TCP_TX_WR;
    wire [7:0] TCP_TX_DATA;

    wire BUS_WR, BUS_RD;
    wire [31:0] BUS_ADD;
    wire [7:0] BUS_DATA;

    
    uart_master i_uart_master(
        .UART_CLK_X4(UART_CLK),
        .UART_RST(BUS_RST),
        .UART_RX(UART_RX),
        .UART_TX(UART_TX),
        
        .BUS_DATA(BUS_DATA),
        .BUS_ADD(BUS_ADD),
        .BUS_WR(BUS_WR),
        .BUS_RD(BUS_RD)
    );


    //MODULE ADREESSES
    localparam GPIO_BASEADDR = 32'h0000_0000;
    localparam GPIO_HIGHADDR = 32'h0000_000f;
    
    localparam FIFO_BASEADDR = 32'h0020;                    // 0x0020
    localparam FIFO_HIGHADDR = FIFO_BASEADDR + 15;          // 0x002f
    
    localparam FAST_SR_AQ_BASEADDR = 32'h0100;                    
    localparam FAST_SR_AQ_HIGHADDR = FAST_SR_AQ_BASEADDR + 15;
    
//    localparam TDC_BASEADDR = 32'h0200;                    
//    localparam TDC_HIGHADDR = TDC_BASEADDR + 15; 

    localparam SEQ_GEN_BASEADDR = 32'h1000;                      //0x1000
    localparam SEQ_GEN_HIGHADDR = SEQ_GEN_BASEADDR + 16 + 32'h1fff;   //0x300f
    
     
    // MODULES //
    gpio 
    #( 
        .BASEADDR(GPIO_BASEADDR), 
        .HIGHADDR(GPIO_HIGHADDR),
        .ABUSWIDTH(32),
        .IO_WIDTH(8),
        .IO_DIRECTION(8'h0f)
    ) i_gpio
    (
        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),
        .IO({GPIO_DIP, GPIO_LED})
    );
     
    wire [7:0] SEQ_OUT;
    seq_gen 
    #( 
        .BASEADDR(SEQ_GEN_BASEADDR), 
        .HIGHADDR(SEQ_GEN_HIGHADDR),
        .ABUSWIDTH(32),
        .MEM_BYTES(8*1024), 
        .OUT_BITS(8) 
    ) i_seq_gen
    (
        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),
    
        .SEQ_CLK(SPI_CLK),
        .SEQ_OUT(SEQ_OUT)
    );
    wire SR_IN, GLOBAL_SR_EN, GLOBAL_CTR_LD, GLOBAL_DAC_LD, PIXEL_SR_EN, INJECT;
    wire GLOBAL_SR_CLK, PIXEL_SR_CLK;
    assign SR_IN                = SEQ_OUT[0];
    assign GLOBAL_SR_EN         = SEQ_OUT[1];   
    assign GLOBAL_CTR_LD        = SEQ_OUT[2];   
    assign GLOBAL_DAC_LD        = SEQ_OUT[3];     
    assign PIXEL_SR_EN          = SEQ_OUT[4];
    assign INJECT               = SEQ_OUT[5];
 
    ODDR GLOBAL_SR_GC (
        .CE(GLOBAL_SR_EN), 
        .C(SPI_CLK),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0),
        .Q(GLOBAL_SR_CLK)
    );

    ODDR PIXEL_SR_GC (
        .CE(PIXEL_SR_EN), 
        .C(SPI_CLK),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0),
        .Q(PIXEL_SR_CLK)
    );
 
    wire [31:0] FIFO_DATA_SPI_RX;
    wire FIFO_EMPTY_SPI_RX;
    wire FIFO_READ_SPI_RX;
    wire PIXEL_SR_OUT;
    assign PIXEL_SR_OUT = SR_IN;
    
    fast_spi_rx 
    #(         
        .BASEADDR(FAST_SR_AQ_BASEADDR), 
        .HIGHADDR(FAST_SR_AQ_HIGHADDR)
    ) i_pixel_sr_fast_rx
    (
        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),
        
        .SCLK(~SPI_CLK),
        .SDI(PIXEL_SR_OUT),
        .SEN(PIXEL_SR_EN),
    
        .FIFO_READ(FIFO_READ_SPI_RX),
        .FIFO_EMPTY(FIFO_EMPTY_SPI_RX),
        .FIFO_DATA(FIFO_DATA_SPI_RX)
    ); 

    
    wire TDC_FIFO_READ;
    wire TDC_FIFO_EMPTY;
    wire [31:0] TDC_FIFO_DATA;
    assign TDC_FIFO_EMPTY = 1'b1;
    //TODO: TDC
/*    tdc_s3 #(
        .BASEADDR(TDC_BASEADDR),
        .HIGHADDR(TDC_HIGHADDR),
        .CLKDV(2),
        .DATA_IDENTIFIER(4'b0100), 
        .FAST_TDC(1),
        .FAST_TRIGGER(0)
    ) i_tdc (
        .CLK320(CLKOUT_320_TDC),
        .CLK160(CLKOUT_160_TDC),
        .DV_CLK(TDC_WCLK),
        .TDC_IN(HIT_OR),
        .TDC_OUT(),
        .TRIG_IN(LEMO_RX[1]),
        .TRIG_OUT(),

        .FIFO_READ(TDC_FIFO_READ),
        .FIFO_EMPTY(TDC_FIFO_EMPTY),
        .FIFO_DATA(TDC_FIFO_DATA),

        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),

        .ARM_TDC(1'b0), // arm TDC by sending commands
        .EXT_EN(1'b0),
        
        .TIMESTAMP(16'b0)
    );
*/

    wire ARB_READY_OUT, ARB_WRITE_OUT;
    wire [31:0] ARB_DATA_OUT;
     
    rrp_arbiter 
    #( 
        .WIDTH(2)
    ) i_rrp_arbiter
    (
        .RST(BUS_RST),
        .CLK(BUS_CLK),
    
        .WRITE_REQ({~FIFO_EMPTY_SPI_RX, ~TDC_FIFO_EMPTY}),
        .HOLD_REQ({2'b0}),
        .DATA_IN({FIFO_DATA_SPI_RX, TDC_FIFO_DATA}),
        .READ_GRANT({FIFO_READ_SPI_RX, TDC_FIFO_READ}),

        .READY_OUT(ARB_READY_OUT),
        .WRITE_OUT(ARB_WRITE_OUT),
        .DATA_OUT(ARB_DATA_OUT)
    );
    
    wire FIFO_EMPTY, FIFO_FULL;
    fifo_32_to_8 #(.DEPTH(4*1024)) i_data_fifo (
        .RST(BUS_RST),
        .CLK(BUS_CLK),
        
        .WRITE(ARB_WRITE_OUT),
        .READ(TCP_TX_WR),
        .DATA_IN(ARB_DATA_OUT),
        .FULL(FIFO_FULL),
        .EMPTY(FIFO_EMPTY),
        .DATA_OUT(TCP_TX_DATA)
    );
    assign ARB_READY_OUT = !FIFO_FULL;
    assign TCP_TX_WR = !TCP_TX_FULL && !FIFO_EMPTY;
    
    reg [23:0] heartbeat_cnt = 24'd0;
    assign LED = heartbeat_cnt[23];
    always@(posedge BUS_CLK) begin
        if(BUS_RST)
            heartbeat_cnt <= 24'd0;
        else
            heartbeat_cnt <= heartbeat_cnt + 1;
    end    
    
endmodule
