

module bdaq53(
    input wire RESET_N,
    input wire clkin,

    input wire RX_CLK_P, RX_CLK_N,
    input wire RX_INIT_CLK_P, RX_INIT_CLK_N,
    
    // Ethernet
    output wire [3:0] rgmii_txd,
    output wire       rgmii_tx_ctl,
    output wire       rgmii_txc,
    input  wire [3:0] rgmii_rxd,
    input  wire       rgmii_rx_ctl,
    input  wire       rgmii_rxc,
    output wire       mdio_phy_mdc,
    inout  wire       mdio_phy_mdio,
    output wire       phy_rst_n,
    
/*
    // DDR3 Memory Interface
    output wire [14:0]ddr3_addr,
    output wire [2:0] ddr3_ba,
    output wire       ddr3_cas_n,
    output wire       ddr3_ras_n,
    output wire       ddr3_ck_n, ddr3_ck_p,
    output wire [0:0] ddr3_cke,
    output wire       ddr3_reset_n,
    inout  wire [7:0] ddr3_dq,
    inout  wire       ddr3_dqs_n, ddr3_dqs_p,
    output wire [0:0] ddr3_dm,
    output wire       ddr3_we_n,
    output wire [0:0] ddr3_cs_n,
    output wire [0:0] ddr3_odt,
*/
    // Aurora lanes
    input wire [3:0]  AURORA_RX_P, AURORA_RX_N,

    // CMD encoder
//    output wire CMD_CLK_P, CMD_CLK_N,
//    output wire CMD_DATA_P, CMD_DATA_N,
    output wire LEMO_TX0_CMD_CLK, LEMO_TX0_CMD_DATA,    //debug signal copy of CMD

    // Debug signals
    output wire [7:0] LED
);

wire RST;
wire BUS_CLK_PLL, CLK200PLL, CLK125PLLTX, CLK125PLLTX90, CLK125PLLRX, CLKCMDPLL;
wire PLL_FEEDBACK, LOCKED;

PLLE2_BASE #(
    .BANDWIDTH("OPTIMIZED"),    // OPTIMIZED, HIGH, LOW
    .CLKFBOUT_MULT(10),         // Multiply value for all CLKOUT, (2-64)
    .CLKFBOUT_PHASE(0.0),       // Phase offset in degrees of CLKFB, (-360.000-360.000).
    .CLKIN1_PERIOD(10.000),     // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).

    .CLKOUT0_DIVIDE(8),         // Divide amount for CLKOUT0 (1-128)
    .CLKOUT0_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0 (0.001-0.999).
    .CLKOUT0_PHASE(0.0),        // Phase offset for CLKOUT0 (-360.000-360.000).
/*
    .CLKOUT1_DIVIDE(5),         // Divide amount for CLKOUT0 (1-128)
    .CLKOUT1_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0 (0.001-0.999).
    .CLKOUT1_PHASE(0.0),        // Phase offset for CLKOUT0 (-360.000-360.000).
*/
    .CLKOUT2_DIVIDE(8),         // Divide amount for CLKOUT0 (1-128)
    .CLKOUT2_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0 (0.001-0.999).
    .CLKOUT2_PHASE(0.0),        // Phase offset for CLKOUT0 (-360.000-360.000).

    .CLKOUT3_DIVIDE(8),         // Divide amount for CLKOUT0 (1-128)
    .CLKOUT3_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0 (0.001-0.999).
    .CLKOUT3_PHASE(90.0),       // Phase offset for CLKOUT0 (-360.000-360.000).

    .CLKOUT4_DIVIDE(8),         // Divide amount for CLKOUT0 (1-128)
    .CLKOUT4_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0 (0.001-0.999).
    .CLKOUT4_PHASE(-5.6),       // Phase offset for CLKOUT0 (-360.000-360.000).
    //-65 -> 0?; - 45 -> 39;  -25 -> 100; -5 -> 0;

    .CLKOUT5_DIVIDE(100),       // Divide amount for CLKOUT0 (1-128)
    .CLKOUT5_DUTY_CYCLE(0.5),   // Duty cycle for CLKOUT0 (0.001-0.999).
    .CLKOUT5_PHASE(0.0),        // Phase offset for CLKOUT0 (-360.000-360.000).

    .DIVCLK_DIVIDE(1),          // Master division value, (1-56)
    .REF_JITTER1(0.0),          // Reference input jitter in UI, (0.000-0.999).
    .STARTUP_WAIT("FALSE")      // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
 )
 PLLE2_BASE_inst (              // VCO = 1 GHz                        
     .CLKOUT0(BUS_CLK_PLL),     // 125 MHz //142.86 MHz
     //.CLKOUT1(CLK200PLL),     // 200 MHz for MIG
     .CLKOUT2(CLK125PLLTX),     // 125 MHz
     .CLKOUT3(CLK125PLLTX90),
     .CLKOUT4(CLK125PLLRX),
     .CLKOUT5(CLKCMDPLL),       // CMD encoder clock

     .CLKFBOUT(PLL_FEEDBACK),

     .LOCKED(LOCKED),           // 1-bit output: LOCK

     // Input 100 MHz clock
     .CLKIN1(clkin),

     // Control Ports
     .PWRDWN(0),
     .RST(!RESET_N),

     // Feedback
     .CLKFBIN(PLL_FEEDBACK)
 );


wire BUS_CLK;
BUFG BUFG_inst_BUS_CKL (.O(BUS_CLK), .I(BUS_CLK_PLL) );

wire CLK125TX, CLK125TX90, CLK125RX, CLKCMD;
BUFG BUFG_inst_CLK125TX   ( .O(CLK125TX),   .I(CLK125PLLTX)   );
BUFG BUFG_inst_CLK125TX90 ( .O(CLK125TX90), .I(CLK125PLLTX90) );
BUFG BUFG_inst_CLK125RX   ( .O(CLK125RX),   .I(rgmii_rxc)     );
BUFG BUFG_inst_CLKCMDENC  ( .O(CLKCMD),     .I(CLKCMDPLL)     );

assign RST = !RESET_N | !LOCKED;

 wire   gmii_tx_clk;
 wire   gmii_tx_en;
 wire  [7:0] gmii_txd;
 wire   gmii_tx_er;
 wire   gmii_crs;
 wire   gmii_col;
 wire   gmii_rx_clk;
 wire   gmii_rx_dv;
 wire  [7:0] gmii_rxd;
 wire   gmii_rx_er;
 wire   mdio_gem_mdc;
 wire   mdio_gem_i;
 wire   mdio_gem_o;
 wire   mdio_gem_t;
 wire   link_status;
 wire  [1:0] clock_speed;
 wire   duplex_status;

rgmii_io rgmii
(
    .rgmii_txd(rgmii_txd),
    .rgmii_tx_ctl(rgmii_tx_ctl),
    .rgmii_txc(rgmii_txc),

    .rgmii_rxd(rgmii_rxd),
    .rgmii_rx_ctl(rgmii_rx_ctl),

    .gmii_txd_int(gmii_txd),      // Internal gmii_txd signal.
    .gmii_tx_en_int(gmii_tx_en),
    .gmii_tx_er_int(gmii_tx_er),
    .gmii_col_int(gmii_col),
    .gmii_crs_int(gmii_crs),
    .gmii_rxd_reg(gmii_rxd),   // RGMII double data rate data valid.
    .gmii_rx_dv_reg(gmii_rx_dv), // gmii_rx_dv_ibuf registered in IOBs.
    .gmii_rx_er_reg(gmii_rx_er), // gmii_rx_er_ibuf registered in IOBs.

    .eth_link_status(link_status),
    .eth_clock_speed(clock_speed),
    .eth_duplex_status(duplex_status),

                              // FOllowing are generated by DCMs
    .tx_rgmii_clk_int(CLK125TX),     // Internal RGMII transmitter clock.
    .tx_rgmii_clk90_int(CLK125TX90),   // Internal RGMII transmitter clock w/ 90 deg phase
    .rx_rgmii_clk_int(CLK125RX),     // Internal RGMII receiver clock

    .reset(!phy_rst_n)
);

// Instantiate tri-state buffer for MDIO
IOBUF i_iobuf_mdio(
    .O(mdio_gem_i),
    .IO(mdio_phy_mdio),
    .I(mdio_gem_o),
    .T(mdio_gem_t));

wire EEPROM_CS, EEPROM_SK, EEPROM_DI;
wire TCP_CLOSE_REQ;
wire TCP_OPEN_ACK;
wire RBCP_ACT, RBCP_WE, RBCP_RE;
wire [7:0] RBCP_WD, RBCP_RD;
wire [31:0] RBCP_ADDR;
wire TCP_RX_WR;
wire TCP_TX_WR;
wire [7:0] TCP_RX_DATA;
wire [7:0] TCP_TX_DATA;
wire TCP_TX_FULL;
wire RBCP_ACK;
wire SiTCP_RST;
reg [10:0] TCP_RX_WC_11B;


WRAP_SiTCP_GMII_XC7K_32K sitcp(
    .CLK(BUS_CLK)                    ,    // in    : System Clock >129MHz
    .RST(RST)                    ,    // in    : System reset
    // Configuration parameters
    .FORCE_DEFAULTn(1'b0)        ,    // in    : Load default parameters
    .EXT_IP_ADDR(32'hc0a80a10)            ,    // in    : IP address[31:0] //192.168.10.16
    .EXT_TCP_PORT(16'd24)        ,    // in    : TCP port #[15:0]
    .EXT_RBCP_PORT(16'd4660)        ,    // in    : RBCP port #[15:0]
    .PHY_ADDR(5'd3)            ,    // in    : PHY-device MIF address[4:0]
    // EEPROM
    .EEPROM_CS(EEPROM_CS)            ,    // out    : Chip select
    .EEPROM_SK(EEPROM_SK)            ,    // out    : Serial data clock
    .EEPROM_DI(EEPROM_DI)            ,    // out    : Serial write data
    .EEPROM_DO(1'b0)            ,    // in    : Serial read data
    // user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
    .USR_REG_X3C()            ,    // out    : Stored at 0xFFFF_FF3C
    .USR_REG_X3D()            ,    // out    : Stored at 0xFFFF_FF3D
    .USR_REG_X3E()            ,    // out    : Stored at 0xFFFF_FF3E
    .USR_REG_X3F()            ,    // out    : Stored at 0xFFFF_FF3F
    // MII interface
    .GMII_RSTn(phy_rst_n)            ,    // out    : PHY reset
    .GMII_1000M(1'b1)            ,    // in    : GMII mode (0:MII, 1:GMII)
    // TX
    .GMII_TX_CLK(CLK125TX)            ,    // in    : Tx clock
    .GMII_TX_EN(gmii_tx_en)            ,    // out    : Tx enable
    .GMII_TXD(gmii_txd)            ,    // out    : Tx data[7:0]
    .GMII_TX_ER(gmii_tx_er)            ,    // out    : TX error
    // RX
    .GMII_RX_CLK(CLK125RX)           ,    // in    : Rx clock
    .GMII_RX_DV(gmii_rx_dv)            ,    // in    : Rx data valid
    .GMII_RXD(gmii_rxd)            ,    // in    : Rx data[7:0]
    .GMII_RX_ER(gmii_rx_er)            ,    // in    : Rx error
    .GMII_CRS(gmii_crs)            ,    // in    : Carrier sense
    .GMII_COL(gmii_col)            ,    // in    : Collision detected
    // Management IF
    .GMII_MDC(mdio_phy_mdc)            ,    // out    : Clock for MDIO
    .GMII_MDIO_IN(mdio_gem_i)        ,    // in    : Data
    .GMII_MDIO_OUT(mdio_gem_o)        ,    // out    : Data
    .GMII_MDIO_OE(mdio_gem_t)        ,    // out    : MDIO output enable
    // User I/F
    .SiTCP_RST(SiTCP_RST)            ,    // out    : Reset for SiTCP and related circuits
    // TCP connection control
    .TCP_OPEN_REQ(1'b0)        ,    // in    : Reserved input, shoud be 0
    .TCP_OPEN_ACK(TCP_OPEN_ACK)        ,    // out    : Acknowledge for open (=Socket busy)
    .TCP_ERROR()            ,    // out    : TCP error, its active period is equal to MSL
    .TCP_CLOSE_REQ(TCP_CLOSE_REQ)        ,    // out    : Connection close request
    .TCP_CLOSE_ACK(TCP_CLOSE_REQ)        ,    // in    : Acknowledge for closing
    // FIFO I/F
    .TCP_RX_WC({5'b1,TCP_RX_WC_11B})            ,    // in    : Rx FIFO write count[15:0] (Unused bits should be set 1)
    .TCP_RX_WR(TCP_RX_WR)            ,    // out    : Write enable
    .TCP_RX_DATA(TCP_RX_DATA)            ,    // out    : Write data[7:0]
    .TCP_TX_FULL(TCP_TX_FULL)            ,    // out    : Almost full flag
    .TCP_TX_WR(TCP_TX_WR)            ,    // in    : Write enable
    .TCP_TX_DATA(TCP_TX_DATA)            ,    // in    : Write data[7:0]
    // RBCP
    .RBCP_ACT(RBCP_ACT)            ,    // out    : RBCP active
    .RBCP_ADDR(RBCP_ADDR)            ,    // out    : Address[31:0]
    .RBCP_WD(RBCP_WD)                ,    // out    : Data[7:0]
    .RBCP_WE(RBCP_WE)                ,    // out    : Write enable
    .RBCP_RE(RBCP_RE)                ,    // out    : Read enable
    .RBCP_ACK(RBCP_ACK)            ,    // in    : Access acknowledge
    .RBCP_RD(RBCP_RD)                    // in    : Read data[7:0]
);

// -------  BUS SIGNALING  ------- //
wire BUS_WR, BUS_RD, BUS_RST;
wire [31:0] BUS_ADD;
wire [7:0] BUS_DATA;
assign BUS_RST = SiTCP_RST;

rbcp_to_bus irbcp_to_bus(
    .BUS_RST(BUS_RST),
    .BUS_CLK(BUS_CLK),

    .RBCP_ACT(RBCP_ACT),
    .RBCP_ADDR(RBCP_ADDR),
    .RBCP_WD(RBCP_WD),
    .RBCP_WE(RBCP_WE),
    .RBCP_RE(RBCP_RE),
    .RBCP_ACK(RBCP_ACK),
    .RBCP_RD(RBCP_RD),

    .BUS_WR(BUS_WR),
    .BUS_RD(BUS_RD),
    .BUS_ADD(BUS_ADD),
    .BUS_DATA(BUS_DATA)
);


// -------  MODULE ADREESSES  ------- //
localparam GPIO_BASEADDR    = 32'h1000;
localparam GPIO_HIGHADDR    = 32'h101f;

localparam CMD53_BASEADDR   = 32'h2000;
localparam CMD53_HIGHADDR   = 32'h3000-1;

localparam AURORA_BASEADDR = 32'h3000;
localparam AURORA_HIGHADDR = 32'h4000-1;


// -------  USER MODULES  ------- //
wire [7:0] GPIO_IO;
gpio #(
    .BASEADDR(GPIO_BASEADDR),
    .HIGHADDR(GPIO_HIGHADDR),
    .ABUSWIDTH(32),
    .IO_WIDTH(8),
    .IO_DIRECTION(8'hff)
) i_gpio_rx (
    .BUS_CLK(BUS_CLK),
    .BUS_RST(BUS_RST),
    .BUS_ADD(BUS_ADD),
    .BUS_DATA(BUS_DATA),
    .BUS_RD(BUS_RD),
    .BUS_WR(BUS_WR),
    .IO(GPIO_IO)
);


// ----- Command encoder ----- //
wire EXT_START_PIN, EXT_TRIGGER;
wire CMD_EN;
wire CMD_DATA_VAL;
assign LEMO_TX0_CMD_CLK = CLKCMD && CMD_DATA_VAL;
assign LEMO_TX0_CMD_DATA = CMD_DATA;
/*
OBUFDS #(
    .IOSTANDARD("LVDS"),    // Specify the output I/O standard
    .SLEW("FAST")           // Specify the output slew rate
) i_OBUFDS_CMD_DATA (
    .O(CMD_DATA_P),         // Diff_p output (connect directly to top-level port)
    .OB(CMD_DATA_N),        // Diff_n output (connect directly to top-level port)
    .I(CMD_DATA)            // Buffer input 
);

OBUFDS #(
    .IOSTANDARD("LVDS"),    // Specify the output I/O standard
    .SLEW("FAST")           // Specify the output slew rate
) i_OBUFDS_CMD_CLK (
    .O(CMD_CLK_P),         // Diff_p output (connect directly to top-level port)
    .OB(CMD_CLK_N),        // Diff_n output (connect directly to top-level port)
    .I(CLKCMD)            // Buffer input 
);
*/
cmd_rd53 #(
    .BASEADDR(CMD53_BASEADDR),
    .HIGHADDR(CMD53_HIGHADDR),
    .ABUSWIDTH(32)
) i_cmd_rd53 (
    .BUS_CLK(BUS_CLK),
    .BUS_RST(BUS_RST),
    .BUS_ADD(BUS_ADD),
    .BUS_DATA(BUS_DATA),
    .BUS_RD(BUS_RD),
    .BUS_WR(BUS_WR),

    .EXT_START_PIN(EXT_START_PIN),
    .EXT_TRIGGER(EXT_TRIGGER),

    .CMD_CLK(CLKCMD),
    .CMD_EN(CMD_EN),
    .CMD_SERIAL_OUT(CMD_DATA),
    .CMD_DATA_VAL(CMD_DATA_VAL)
);


// ----- AURORA ----- //
wire AURORA_RX_FIFO_READ;
wire AURORA_RX_FIFO_EMPTY;
wire [31:0] AURORA_RX_FIFO_DATA;
wire AUR_RX_READY, AUR_LOST_ERR;

rx_aurora_64b66b #(
    .BASEADDR(AURORA_BASEADDR),
    .HIGHADDR(AURORA_HIGHADDR),
    .IDENTIFIER(0)
) i_aurora_rx (
    .RXP(AURORA_RX_P),
    .RXN(AURORA_RX_N),
    .RX_CLK_P(RX_CLK_P),
    .RX_CLK_N(RX_CLK_N),
    .RX_INIT_CLK_P(RX_INIT_CLK_P),
    .RX_INIT_CLK_N(RX_INIT_CLK_N),

    .RX_READY(AUR_RX_READY),
    .LOST_ERROR(AUR_LOST_ERR),

    .FIFO_READ(AURORA_RX_FIFO_READ),    //in
    .FIFO_EMPTY(AURORA_RX_FIFO_EMPTY),  //out
    .FIFO_DATA(AURORA_RX_FIFO_DATA),    //out

    .BUS_CLK(BUS_CLK),
    .BUS_RST(BUS_RST),
    .BUS_ADD(BUS_ADD),
    .BUS_DATA(BUS_DATA),
    .BUS_RD(BUS_RD),
    .BUS_WR(BUS_WR)
);


// ----- General FIFO ----- //
wire FIFO_EMPTY, FIFO_FULL;
wire FIFO_WRITE;
reg [31:0] FIFO_DATA_IN;

fifo_32_to_8 #(.DEPTH(128*1024)) i_data_fifo (
    .RST(BUS_RST),
    .CLK(BUS_CLK),
    
    .WRITE(FIFO_WRITE), //input
    .READ(TCP_TX_WR),       //input
    .DATA_IN(AURORA_RX_FIFO_DATA),
    
    .FULL(FIFO_FULL),
    .EMPTY(FIFO_EMPTY),
    .DATA_OUT(TCP_TX_DATA)
);


// filling the TCP-FIFO
assign FIFO_WRITE          = !AURORA_RX_FIFO_EMPTY && !FIFO_FULL;
assign AURORA_RX_FIFO_READ = !AURORA_RX_FIFO_EMPTY && !FIFO_FULL;
/*
always@ (posedge BUS_CLK) begin
    if (!FIFO_EMPTY_AURORA_RX && !FIFO_FULL)
        FIFO_WRITE <= 1'b1;
    else
        FIFO_WRITE <= 1'b0;
end
*/   

// draining the TCP-FIFO
assign TCP_TX_WR = !TCP_TX_FULL && !FIFO_EMPTY;




//reg ETH_START_SENDING, ETH_START_SENDING_temp, ETH_START_SENDING_LOCK;
//assign LED = ~{TCP_OPEN_ACK, TCP_CLOSE_REQ, TCP_RX_WR, TCP_TX_WR, FIFO_FULL, FIFO_EMPTY, fifo_write, TCP_TX_WR};    //GPIO_IO[3:0]};
assign LED = ~{TCP_OPEN_ACK, TCP_CLOSE_REQ, TCP_RX_WR, TCP_TX_WR, FIFO_FULL, FIFO_EMPTY, CMD_EN, CMD_EN};

/*
always@ (posedge BUS_CLK)
    begin
    
    // wait for start condition
//    ETH_START_SENDING <= GPIO_IO[0];    //TCP_OPEN_ACK;
    
    if(ETH_START_SENDING && !ETH_START_SENDING_temp)
        ETH_START_SENDING_LOCK <= 1;
    ETH_START_SENDING_temp <= ETH_START_SENDING;  
    
    // RX FIFO word counter
    if(TCP_RX_WR) begin
        TCP_RX_WC_11B <= TCP_RX_WC_11B + 1;
    end
    else begin
        TCP_RX_WC_11B <= 11'd0;
    end

    // FIFO handshake
    if(ETH_START_SENDING_LOCK) begin
        if(!FIFO_FULL) begin
            fifo_data_in <= datasource;
            datasource <= datasource + 1;
            fifo_write <= 1'b1;
            end
        else
            fifo_write <= 1'b0;
    end

    // stop, if connection is closed by host
    if(TCP_CLOSE_REQ || !GPIO_IO[0]) begin
        ETH_START_SENDING_LOCK <= 0;
        fifo_write <= 1'b0;
        datasource <= 32'd0;
    end
    
end

*/


endmodule
