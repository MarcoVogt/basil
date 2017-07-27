/**
 * ------------------------------------------------------------
 * Copyright (c) All rights reserved
 * SiLab, Institute of Physics, University of Bonn
 * ------------------------------------------------------------
 */
`timescale 1ps / 1ps
`default_nettype none

module ddrvfifo
#(
    parameter   BASEADDR = 32'h0000,
    parameter   HIGHADDR = 32'h0000,
    parameter   ABUSWIDTH = 16,

    parameter   BASEADDR_DATA = 64'h0001000000000000,
    parameter   HIGHADDR_DATA = 64'h000f000000000000,

    parameter   DEPTH = 32'h8000
) (
    input wire                  BUS_CLK,
    input wire                  BUS_RST,
    input wire [ABUSWIDTH-1:0]  BUS_ADD,
    inout wire [7:0]            BUS_DATA,
    input wire                  BUS_RD,
    input wire                  BUS_WR,

    output wire 				EMPTY,
    output wire 				FULL,
    output wire [31:0]          DATA_OUT,
    input wire [31:0]           DATA_IN,
    input wire                  READ,
    input wire                  WRITE,
    input wire					TLAST,

    input wire                  VFIFO_RESET,
	input wire					DDR_CLK_P, DDR_CLK_N,
    input wire                  sys_clk_i,

    // VFIFO status lines
    input wire [1:0]  vfifo_mm2s_channel_full,
    output wire [1:0] vfifo_s2mm_channel_full,
    output wire [1:0] vfifo_mm2s_channel_empty,
    output wire [1:0] vfifo_idle,

     // Slave AXI stream ports
    input wire          s_axis_tvalid,      // input wire s_axis_tvalid
    output wire         s_axis_tready,      // output wire s_axis_tready
    input wire [31:0]   s_axis_tdata,       // input wire [31 : 0] s_axis_tdata
    input wire          s_axis_tlast,       // input wire s_axis_tlast
    input wire [0:0]    s_axis_tdest,

    // Master AXI stream ports
    output wire         m_axis_tvalid,      // output wire m_axis_tvalid
    input wire          m_axis_tready,      // input wire m_axis_tready
    output wire [31:0]  m_axis_tdata,       // output wire [31 : 0] m_axis_tdata
    output wire         m_axis_tlast,        // output wire m_axis_tlast
    output wire [0:0]   m_axis_tdest,

    output wire vfifo_mm2s_rresp_err_intr,      // output wire vfifo_mm2s_rresp_err_intr
    output wire vfifo_s2mm_bresp_err_intr,      // output wire vfifo_s2mm_bresp_err_intr
    output wire vfifo_s2mm_overrun_err_intr,   // output wire vfifo_s2mm_overrun_err_intr

    // DDR3 Memory Interface
    output wire [14:0] ddr3_addr,   // output [14:0]	ddr3_addr
    output wire [2:0] ddr3_ba,      // output [2:0]		ddr3_ba
    output wire ddr3_cas_n,         // output			ddr3_cas_n
    output wire [0:0] ddr3_ck_n,    // output [0:0]		ddr3_ck_n
    output wire [0:0] ddr3_ck_p,    // output [0:0]		ddr3_ck_p
    output wire [0:0] ddr3_cke,     // output [0:0]		ddr3_cke
    output wire ddr3_ras_n,         // output			ddr3_ras_n
    output wire ddr3_reset_n,       // output			ddr3_reset_n
    output wire ddr3_we_n,          // output			ddr3_we_n
    inout wire [7:0] ddr3_dq,       // inout [7:0]		ddr3_dq
    inout wire [0:0] ddr3_dqs_n,    // inout [0:0]		ddr3_dqs_n
    inout wire [0:0] ddr3_dqs_p,    // inout [0:0]		ddr3_dqs_p
	output wire [0:0] ddr3_cs_n,    // output [0:0]		ddr3_cs_n
    output wire [0:0] ddr3_dm,      // output [0:0]		ddr3_dm
    output wire [0:0] ddr3_odt,     // output [0:0]		ddr3_odt
    output wire init_calib_complete // output			init_calib_complete
);

/*
wire [1:0] mm2s_channel_full = 2'b00;
wire [1:0] mm2s_channel_empty;
wire [1:0] s2mm_channel_full;
wire [1:0] vfifo_idle;


//write to fifo
wire s_axis_tvalid = 1'b0;
wire s_axis_tready;
wire s_axis_tlast = TLAST;
wire [31:0] s_axis_tdata = 32'd0;

//read from fifo
wire m_axis_tvalid;
wire m_axis_tready = 1'b0;
wire m_axis_tlast;
wire [31:0] m_axis_tdata;
*/

wire IP_RD, IP_WR;
wire [ABUSWIDTH-1:0] IP_ADD;
wire [7:0] IP_DATA_IN;
wire [7:0] IP_DATA_OUT;

wire VALID;
wire INIT_DONE;
wire int_init_calib_complete;


//assign INIT_DONE = (int_init_calib_complete == 1'b1) ? 1'b1 : 1'b0;
//assign VALID = m_axis_tvalid;// && !EMPTY;


reg DBG_INIT_DONE = 1'b0;
always @(init_calib_complete)
    if (init_calib_complete == 1'b1) DBG_INIT_DONE = 1'b1;
    else DBG_INIT_DONE = 1'b0;
assign INIT_DONE = DBG_INIT_DONE;


reg DBG_VALID = 1'b0;
always @(m_axis_tvalid)
    if (m_axis_tvalid == 1'b1) DBG_VALID = 1'b1;
    else DBG_VALID = 1'b0;
assign VALID = DBG_VALID;



bus_to_ip #(
    .BASEADDR(BASEADDR),
    .HIGHADDR(HIGHADDR),
    .ABUSWIDTH(ABUSWIDTH))
i_bus_to_ip_vfifo
(
    .BUS_RD(BUS_RD),
    .BUS_WR(BUS_WR),
    .BUS_ADD(BUS_ADD),
    .BUS_DATA(BUS_DATA),

    .IP_RD(IP_RD),
    .IP_WR(IP_WR),
    .IP_ADD(IP_ADD),
    .IP_DATA_IN(IP_DATA_IN),
    .IP_DATA_OUT(IP_DATA_OUT)
);


/*
//DDRVFIFO interface
wire        VFIFO_EMPTY;
wire        VFIFO_FULL;
wire [31:0] VFIFO_DATA_OUT;
wire [31:0] VFIFO_DATA_IN;
wire        VFIFO_READ;
wire        VFIFO_WRITE;
*/

ddrvfifo_core
#(
    .DEPTH(DEPTH)
//    .FIFO_ALMOST_FULL_THRESHOLD(FIFO_ALMOST_FULL_THRESHOLD),
//    .FIFO_ALMOST_EMPTY_THRESHOLD(FIFO_ALMOST_EMPTY_THRESHOLD),
//    .ABUSWIDTH(ABUSWIDTH)
)
i_ddrvfifo_core
(
    .BUS_CLK(BUS_CLK),
    .BUS_RST(BUS_RST),
    .BUS_ADD(IP_ADD),
    .BUS_DATA_IN(IP_DATA_IN),
    .BUS_RD(IP_RD),
    .BUS_WR(IP_WR),
    .BUS_DATA_OUT(IP_DATA_OUT),

    .INIT_DONE(INIT_DONE),
    .VALID(VALID)
/*    ,

    .EMPTY(),//EMPTY
    .FULL(),//FULL
    .DATA_OUT(),//DATA_OUT
    .DATA_IN(DATA_IN),
    .READ(READ),
    .WRITE(WRITE)
*/
);


axi_ddrvfifo
#(
)
i_axi_ddrvfifo
(
    .aclk(BUS_CLK),           // sys_clk_i
    .aresetn(!VFIFO_RESET),
    .sys_clk_p(DDR_CLK_P),
    .sys_clk_n(DDR_CLK_N),

    .read(READ),
    .write(WRITE),
    .data_in(DATA_IN),
    .data_out(DATA_OUT),
    .empty(EMPTY),
    .full(FULL),

    .ext_vfifo_mm2s_channel_full(vfifo_mm2s_channel_full),
    .ext_vfifo_s2mm_channel_full(vfifo_s2mm_channel_full),
    .ext_vfifo_mm2s_channel_empty(vfifo_mm2s_channel_empty),
    .ext_vfifo_idle(vfifo_idle),

    .ext_s_axis_tvalid(s_axis_tvalid),
    .ext_s_axis_tready(s_axis_tready),
    .ext_s_axis_tdata(s_axis_tdata),
    .ext_s_axis_tlast(s_axis_tlast),
    .ext_s_axis_tdest(s_axis_tdest),

    .ext_m_axis_tvalid(m_axis_tvalid),
    .ext_m_axis_tready(1'b1),
    .ext_m_axis_tdata(m_axis_tdata),
    .ext_m_axis_tlast(m_axis_tlast),
    .ext_m_axis_tdest(m_axis_tdest),

    .vfifo_mm2s_rresp_err_intr(vfifo_mm2s_rresp_err_intr),
    .vfifo_s2mm_bresp_err_intr(vfifo_s2mm_bresp_err_intr),
    .vfifo_s2mm_overrun_err_intr(vfifo_s2mm_overrun_err_intr),

    // Memory interface ports
    .ddr3_addr(ddr3_addr),
    .ddr3_ba(ddr3_ba),
    .ddr3_cas_n(ddr3_cas_n),
    .ddr3_ck_n(ddr3_ck_n),
    .ddr3_ck_p(ddr3_ck_p),
    .ddr3_cke(ddr3_cke),
    .ddr3_ras_n(ddr3_ras_n),
    .ddr3_reset_n(ddr3_reset_n),
    .ddr3_we_n(ddr3_we_n),
    .ddr3_dq(ddr3_dq),
    .ddr3_dqs_n(ddr3_dqs_n),
    .ddr3_dqs_p(ddr3_dqs_p),
    .init_calib_complete(init_calib_complete),
	.ddr3_cs_n(ddr3_cs_n),
    .ddr3_dm(ddr3_dm),
    .ddr3_odt(ddr3_odt)
);

endmodule
