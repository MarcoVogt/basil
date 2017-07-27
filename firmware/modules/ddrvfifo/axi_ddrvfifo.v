
`timescale 1ps / 1ps
//`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/23/2017 05:24:01 PM
// Design Name:
// Module Name: top
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module axi_ddrvfifo(
    input wire aclk,
    input wire aresetn,

    //DDR3 controller clocks
//    input wire sys_clk_p,
//    input wire sys_clk_n,
    input wire sys_clk_i,

    //Generic FIFO style interface
    input  wire read,
    input  wire write,
    input  wire [31:0] data_in,
    output wire [31:0] data_out,
    output wire empty,
    output wire full,

    //VFIFO status lines
    input wire [1:0]  ext_vfifo_mm2s_channel_full,
    output wire [1:0] ext_vfifo_s2mm_channel_full,
    output wire [1:0] ext_vfifo_mm2s_channel_empty,
    output wire [1:0] ext_vfifo_idle,
    output wire vfifo_mm2s_rresp_err_intr,         // output wire vfifo_mm2s_rresp_err_intr
    output wire vfifo_s2mm_bresp_err_intr,         // output wire vfifo_s2mm_bresp_err_intr
    output wire vfifo_s2mm_overrun_err_intr,       // output wire vfifo_s2mm_overrun_err_intr

     //Slave AXI stream ports
    input wire          ext_s_axis_tvalid,      // input wire s_axis_tvalid
    output wire         ext_s_axis_tready,      // output wire s_axis_tready
    input wire [31:0]   ext_s_axis_tdata,       // input wire [31 : 0] s_axis_tdata
    input wire          ext_s_axis_tlast,       // input wire s_axis_tlast
    input wire [0:0]    ext_s_axis_tdest,

    //Master AXI stream ports
    output wire         ext_m_axis_tvalid,      // output wire m_axis_tvalid
    input wire          ext_m_axis_tready,      // input wire m_axis_tready
    output wire [31:0]  ext_m_axis_tdata,       // output wire [31 : 0] m_axis_tdata
    output wire         ext_m_axis_tlast,        // output wire m_axis_tlast
    output wire [0:0]   ext_m_axis_tdest,

    // Memory interface ports
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


    wire ui_clk;            // output			ui_clk
    wire ui_clk_sync_rst;   // output			ui_clk_sync_rst
    wire mmcm_locked;       // output			mmcm_locked
    wire app_sr_req;        // input			app_sr_req
    wire app_ref_req;       // input			app_ref_req
    wire app_zq_req;        // input			app_zq_req
    wire app_sr_active;     // output			app_sr_active
    wire app_ref_ack;       // output			app_ref_ack
    wire app_zq_ack;        // output			app_zq_ack


    //Signals to connect the MIG to the Virtual FIFO Controller
    wire [0:0]  axi_awid;       // output wire [1 : 0] m_axi_awid
    wire [31:0] axi_awaddr;     // output wire [31 : 0] m_axi_awaddr
    wire [7:0]  axi_awlen;      // output wire [7 : 0] m_axi_awlen
    wire [2:0]  axi_awsize;     // output wire [2 : 0] m_axi_awsize
    wire [1:0]  axi_awburst;    // output wire [1 : 0] m_axi_awburst
//    wire [0:0]  axi_awlock;     // output wire [0 : 0] m_axi_awlock
//    wire [3:0]  axi_awcache;    // output wire [3 : 0] m_axi_awcache
//    wire [2:0]  axi_awprot;     // output wire [2 : 0] m_axi_awprot
//    wire [3:0]  axi_awqos;      // output wire [3 : 0] m_axi_awqos
//    wire [3:0]  axi_awregion;   // output wire [3 : 0] m_axi_awregion
//    wire [0:0]  axi_awuser;     // output wire [0 : 0] m_axi_awuser
    wire        axi_awvalid;    // output wire m_axi_awvalid
    wire        axi_awready;    // input wire m_axi_awready
    wire [31:0] axi_wdata;      // output wire [31 : 0] m_axi_wdata
    wire [3:0]  axi_wstrb;      // output wire [3 : 0] m_axi_wstrb
    wire        axi_wlast;      // output wire m_axi_wlast
//    wire [0:0]  axi_wuser;      // output wire [0 : 0] m_axi_wuser
    wire        axi_wvalid;     // output wire m_axi_wvalid
    wire        axi_wready;     // input wire m_axi_wready
    wire [0:0]  axi_bid;        // input wire [0 : 0] m_axi_bid
    wire [1:0]  axi_bresp;      // input wire [1 : 0] m_axi_bresp
    wire [0:0]  axi_buser;      // input wire [0 : 0] m_axi_buser
    wire        axi_bvalid;     // input wire m_axi_bvalid
    wire        axi_bready;     // output wire m_axi_bready
    wire [0:0]  axi_arid;       // output wire [1 : 0] m_axi_arid
    wire [31:0] axi_araddr;     // output wire [31 : 0] m_axi_araddr
    wire [7:0]  axi_arlen;      // output wire [7 : 0] m_axi_arlen
    wire [2:0]  axi_arsize;     // output wire [2 : 0] m_axi_arsize
    wire [1:0]  axi_arburst;    // output wire [1 : 0] m_axi_arburst
//    wire [0:0]  axi_arlock;     // output wire [0 : 0] m_axi_arlock
//    wire [3:0]  axi_arcache;    // output wire [3 : 0] m_axi_arcache
//    wire [2:0]  axi_arprot;     // output wire [2 : 0] m_axi_arprot
//    wire [3:0]  axi_arqos;      // output wire [3 : 0] m_axi_arqos
//    wire [3:0]  axi_arregion;   // output wire [3 : 0] m_axi_arregion
//    wire [0:0]  axi_aruser;     // output wire [0 : 0] m_axi_aruser
    wire        axi_arvalid;    // output wire m_axi_arvalid
    wire        axi_arready;    // input wire m_axi_arready
    wire [0:0]  axi_rid;        // input wire [0 : 0] m_axi_rid
    wire [31:0] axi_rdata;      // input wire [31 : 0] m_axi_rdata
    wire [1:0]  axi_rresp;      // input wire [1 : 0] m_axi_rresp
    wire        axi_rlast;      // input wire m_axi_rlast
    wire [0:0]  axi_ruser;      // input wire [0 : 0] m_axi_ruser
    wire        axi_rvalid;     // input wire m_axi_rvalid
    wire        axi_rready;     // output wire m_axi_rready


    //VFIFO status lines
    wire [1:0]  vfifo_mm2s_channel_full;
    wire [1:0]  vfifo_s2mm_channel_full;
    wire [1:0]  vfifo_mm2s_channel_empty;
    wire [1:0]  vfifo_idle;

     //Slave AXI stream ports
    wire        s_axis_tvalid;              // input wire s_axis_tvalid
    wire        s_axis_tready;              // output wire s_axis_tready
    wire [31:0] s_axis_tdata;               // input wire [31 : 0] s_axis_tdata
    wire [3:0]  s_axis_tstrb;               // input wire [3 : 0] s_axis_tstrb
    wire [3:0]  s_axis_tkeep;               // input wire [3 : 0] s_axis_tkeep
    wire        s_axis_tlast;               // input wire s_axis_tlast
    wire [0:0]  s_axis_tid;                 // input wire [1 : 0] s_axis_tid
    wire [0:0]  s_axis_tdest;               // input wire [1 : 0] s_axis_tdest

    //Master AXI stream ports
    wire        m_axis_tvalid;              // output wire m_axis_tvalid
    wire        m_axis_tready;              // input wire m_axis_tready
    wire [31:0] m_axis_tdata;               // output wire [31 : 0] m_axis_tdata
    wire [3:0]  m_axis_tstrb;               // output wire [3 : 0] m_axis_tstrb
    wire [3:0]  m_axis_tkeep;               // output wire [3 : 0] m_axis_tkeep
    wire        m_axis_tlast;               // output wire m_axis_tlast
    wire [0:0]  m_axis_tid;                 // output wire [1 : 0] m_axis_tid
    wire [0:0]  m_axis_tdest;               // output wire [1 : 0] m_axis_tdest


    assign s_axis_tdest = ext_s_axis_tdest;
    assign s_axis_tid = 1'b0;
    assign s_axis_tkeep = 4'hf;
//    assign s_axis_tstrb = 4'hf;
//    assign vfifo_mm2s_channel_full = 4'd0;

    //General FIFO style interface
    assign empty = (vfifo_mm2s_channel_empty==2'd0 && s_axis_tready);
    assign full = vfifo_s2mm_channel_full;
    assign data_out = m_axis_tvalid ? m_axis_tdata : 32'd0;

     //Slave AXI stream ports
    assign s_axis_tvalid     = ext_s_axis_tvalid;       // input wire s_axis_tvalid
    assign ext_s_axis_tready = s_axis_tready;           // output wire s_axis_tready
    assign s_axis_tdata      = ext_s_axis_tdata;        // input wire [31 : 0] s_axis_tdata
    assign s_axis_tlast      = ext_s_axis_tlast;        // input wire s_axis_tlast
    assign s_axis_tdest      = ext_s_axis_tdest;

    //Master AXI stream ports
    assign ext_m_axis_tvalid = m_axis_tvalid;           // output wire m_axis_tvalid
    assign m_axis_tready     = ext_m_axis_tready;       // input wire m_axis_tready
    assign ext_m_axis_tdata  = m_axis_tdata;            // output wire [31 : 0] m_axis_tdata
    assign ext_m_axis_tlast  = m_axis_tlast;            // output wire m_axis_tlast
    assign ext_m_axis_tdest  = m_axis_tdest;

    assign vfifo_mm2s_channel_full      = ext_vfifo_mm2s_channel_full;
    assign ext_vfifo_s2mm_channel_full  = vfifo_s2mm_channel_full;
    assign ext_vfifo_mm2s_channel_empty = vfifo_mm2s_channel_empty;
    assign ext_vfifo_idle               = vfifo_idle;

    wire sys_rst; //DDR controller
    assign sys_rst = aresetn;


    //*****************************************************************************
    //   ____  ____
    //  /   /\/   /
    // /___/  \  /   Vendor             : Xilinx
    // \   \   \/    Version            :
    //  \   \        Application        : VFIFO
    //  /   /        Filename           : axi_vfifo_ctrl_0.veo
    // /___/   /\    Date Last Modified :
    // \   \  /  \   Date Created       :
    //  \___\/\___\
    //
    // Device           : 7 Series
    // Design Name      : Virtual FIFO
    // Purpose          : Template file containing code that can be used as a model
    //                    for instantiating a CORE Generator module in a HDL design.
    // Revision History :
    //*****************************************************************************
    axi_vfifo_ctrl_0 virtual_fifo_inst (
        .aclk(aclk),                                          // input wire aclk
        .aresetn(aresetn),                                    // input wire aresetn

        //Slave AXI stream ports
        .s_axis_tvalid(s_axis_tvalid),                        // input wire s_axis_tvalid
        .s_axis_tready(s_axis_tready),                        // output wire s_axis_tready
        .s_axis_tdata(s_axis_tdata),                          // input wire [31 : 0] s_axis_tdata
        .s_axis_tstrb(4'b0),                          // input wire [3 : 0] s_axis_tstrb           <----------------------------- NOT USED
        .s_axis_tkeep(s_axis_tkeep),                          // input wire [3 : 0] s_axis_tkeep
        .s_axis_tlast(s_axis_tlast),                          // input wire s_axis_tlast
        .s_axis_tid(s_axis_tid),                              // input wire [0 : 0] s_axis_tid
        .s_axis_tdest(s_axis_tdest),                          // input wire [0 : 0] s_axis_tdest

        //Master AXI stream ports
        .m_axis_tvalid(m_axis_tvalid),                        // output wire m_axis_tvalid
        .m_axis_tready(m_axis_tready),                        // input wire m_axis_tready
        .m_axis_tdata(m_axis_tdata),                          // output wire [31 : 0] m_axis_tdata
        .m_axis_tstrb(),                          // output wire [3 : 0] m_axis_tstrb           <----------------------------- NOT USED
        .m_axis_tkeep(m_axis_tkeep),                          // output wire [3 : 0] m_axis_tkeep
        .m_axis_tlast(m_axis_tlast),                          // output wire m_axis_tlast
        .m_axis_tid(m_axis_tid),                              // output wire [0 : 0] m_axis_tid
        .m_axis_tdest(m_axis_tdest),                          // output wire [0 : 0] m_axis_tdest

        //AXI Memory Mapped ports
        .m_axi_awid(axi_awid),                              // output wire [0 : 0] m_axi_awid
        .m_axi_awaddr(axi_awaddr),                          // output wire [31 : 0] m_axi_awaddr
        .m_axi_awlen(axi_awlen),                            // output wire [7 : 0] m_axi_awlen
        .m_axi_awsize(axi_awsize),                          // output wire [2 : 0] m_axi_awsize
        .m_axi_awburst(axi_awburst),                        // output wire [1 : 0] m_axi_awburst
        .m_axi_awlock(),                          // output wire [0 : 0] m_axi_awlock
        .m_axi_awcache(),                        // output wire [3 : 0] m_axi_awcache
        .m_axi_awprot(),                          // output wire [2 : 0] m_axi_awprot
        .m_axi_awqos(),                            // output wire [3 : 0] m_axi_awqos
        .m_axi_awregion(),                      // output wire [3 : 0] m_axi_awregion
        .m_axi_awuser(),                          // output wire [0 : 0] m_axi_awuser
        .m_axi_awvalid(axi_awvalid),                        // output wire m_axi_awvalid
        .m_axi_awready(axi_awready),                        // input wire m_axi_awready
        .m_axi_wdata(axi_wdata),                            // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb(axi_wstrb),                            // output wire [3 : 0] m_axi_wstrb
        .m_axi_wlast(axi_wlast),                            // output wire m_axi_wlast
        .m_axi_wuser(),                            // output wire [0 : 0] m_axi_wuser
        .m_axi_wvalid(axi_wvalid),                          // output wire m_axi_wvalid
        .m_axi_wready(axi_wready),                          // input wire m_axi_wready
        .m_axi_bid(1'b0),                                // input wire [0 : 0] m_axi_bid
        .m_axi_bresp(axi_bresp),                            // input wire [1 : 0] m_axi_bresp
        .m_axi_buser(1'b0),                            // input wire [0 : 0] m_axi_buser
        .m_axi_bvalid(axi_bvalid),                          // input wire m_axi_bvalid
        .m_axi_bready(axi_bready),                          // output wire m_axi_bready
        .m_axi_arid(axi_arid),                              // output wire [0 : 0] m_axi_arid
        .m_axi_araddr(axi_araddr),                          // output wire [31 : 0] m_axi_araddr
        .m_axi_arlen(axi_arlen),                            // output wire [7 : 0] m_axi_arlen
        .m_axi_arsize(axi_arsize),                          // output wire [2 : 0] m_axi_arsize
        .m_axi_arburst(axi_arburst),                        // output wire [1 : 0] m_axi_arburst
        .m_axi_arlock(),                          // output wire [0 : 0] m_axi_arlock
        .m_axi_arcache(),                        // output wire [3 : 0] m_axi_arcache
        .m_axi_arprot(),                          // output wire [2 : 0] m_axi_arprot
        .m_axi_arqos(),                            // output wire [3 : 0] m_axi_arqos
        .m_axi_arregion(),                      // output wire [3 : 0] m_axi_arregion
        .m_axi_aruser(),                          // output wire [0 : 0] m_axi_aruser
        .m_axi_arvalid(axi_arvalid),                        // output wire m_axi_arvalid
        .m_axi_arready(axi_arready),                        // input wire m_axi_arready
        .m_axi_rid(1'b0),                                // input wire [0 : 0] m_axi_rid                    <----------------------------- NOT USED
        .m_axi_rdata(32'd1234),                            // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp(axi_rresp),                            // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast(axi_rlast),                            // input wire m_axi_rlast
        .m_axi_ruser(1'b0),                            // input wire [0 : 0] m_axi_ruser                    <----------------------------- NOT USED
        .m_axi_rvalid(axi_rvalid),                          // input wire m_axi_rvalid
        .m_axi_rready(axi_rready),                          // output wire m_axi_rready

        .vfifo_mm2s_channel_full(vfifo_mm2s_channel_full),    // input wire [1 : 0] vfifo_mm2s_channel_full
        .vfifo_s2mm_channel_full(vfifo_s2mm_channel_full),    // output wire [1 : 0] vfifo_s2mm_channel_full
        .vfifo_mm2s_channel_empty(vfifo_mm2s_channel_empty),  // output wire [1 : 0] vfifo_mm2s_channel_empty
        .vfifo_idle(vfifo_idle),                              // output wire [1 : 0] vfifo_idle

        .vfifo_mm2s_rresp_err_intr(vfifo_mm2s_rresp_err_intr),      // output wire vfifo_mm2s_rresp_err_intr
        .vfifo_s2mm_bresp_err_intr(vfifo_s2mm_bresp_err_intr),      // output wire vfifo_s2mm_bresp_err_intr
        .vfifo_s2mm_overrun_err_intr(vfifo_s2mm_overrun_err_intr)   // output wire vfifo_s2mm_overrun_err_intr
    );



    //*****************************************************************************
    //   ____  ____
    //  /   /\/   /
    // /___/  \  /   Vendor             : Xilinx
    // \   \   \/    Version            : 2.4
    //  \   \        Application        : MIG
    //  /   /        Filename           : mig_7series_0.veo
    // /___/   /\    Date Last Modified : $Date: 2011/06/02 08:34:47 $
    // \   \  /  \   Date Created       : Tue Sept 21 2010
    //  \___\/\___\
    //
    // Device           : 7 Series
    // Design Name      : DDR3 SDRAM
    // Purpose          : Template file containing code that can be used as a model
    //                    for instantiating a CORE Generator module in a HDL design.
    // Revision History :
    //*****************************************************************************
    mig_7series_0 u_mig_7series_0 (
        // Memory interface ports
        .ddr3_addr                      (ddr3_addr),  // output [14:0]		ddr3_addr
        .ddr3_ba                        (ddr3_ba),  // output [2:0]		ddr3_ba
        .ddr3_cas_n                     (ddr3_cas_n),  // output			ddr3_cas_n
        .ddr3_ck_n                      (ddr3_ck_n),  // output [0:0]		ddr3_ck_n
        .ddr3_ck_p                      (ddr3_ck_p),  // output [0:0]		ddr3_ck_p
        .ddr3_cke                       (ddr3_cke),  // output [0:0]		ddr3_cke
        .ddr3_ras_n                     (ddr3_ras_n),  // output			ddr3_ras_n
        .ddr3_reset_n                   (ddr3_reset_n),  // output			ddr3_reset_n
        .ddr3_we_n                      (ddr3_we_n),  // output			ddr3_we_n
        .ddr3_dq                        (ddr3_dq),  // inout [7:0]		ddr3_dq
        .ddr3_dqs_n                     (ddr3_dqs_n),  // inout [0:0]		ddr3_dqs_n
        .ddr3_dqs_p                     (ddr3_dqs_p),  // inout [0:0]		ddr3_dqs_p
        .init_calib_complete            (init_calib_complete),  // output			init_calib_complete
        .ddr3_cs_n                      (ddr3_cs_n),  // output [0:0]		ddr3_cs_n
        .ddr3_dm                        (ddr3_dm),  // output [0:0]		ddr3_dm
        .ddr3_odt                       (ddr3_odt),  // output [0:0]		ddr3_odt
        // Application interface ports
        .ui_clk                         (ui_clk),  // output			ui_clk
        .ui_clk_sync_rst                (ui_clk_sync_rst),  // output			ui_clk_sync_rst
        .mmcm_locked                    (mmcm_locked),  // output			mmcm_locked
        .aresetn                        (aresetn),  // input			aresetn
        .app_sr_req                     (1'b0),  // input			app_sr_req                  <-----------------------------
        .app_ref_req                    (1'b0),  // input			app_ref_req                 <-----------------------------
        .app_zq_req                     (1'b0),  // input			app_zq_req                  <-----------------------------
        .app_sr_active                  (app_sr_active),  // output			app_sr_active
        .app_ref_ack                    (app_ref_ack),  // output			app_ref_ack
        .app_zq_ack                     (app_zq_ack),  // output			app_zq_ack
        // Slave Interface Write Address Ports
        .s_axi_awid                     (axi_awid),  // input [0:0]			s_axi_awid
        .s_axi_awaddr                   (axi_awaddr[27:0]),  // input [27:0]			s_axi_awaddr
        .s_axi_awlen                    (axi_awlen),  // input [7:0]			s_axi_awlen
        .s_axi_awsize                   (axi_awsize),  // input [2:0]			s_axi_awsize
        .s_axi_awburst                  (axi_awburst),  // input [1:0]			s_axi_awburst
        .s_axi_awlock                   (1'b0),  // input [0:0]			s_axi_awlock           <----------------------------- NOT USED
        .s_axi_awcache                  (1'b0),  // input [3:0]			s_axi_awcache           <----------------------------- NOT USED
        .s_axi_awprot                   (1'b0),  // input [2:0]			s_axi_awprot           <----------------------------- NOT USED
        .s_axi_awqos                    (1'b0),  // input [3:0]			s_axi_awqos           <----------------------------- NOT USED
        .s_axi_awvalid                  (axi_awvalid),  // input			s_axi_awvalid
        .s_axi_awready                  (axi_awready),  // output			s_axi_awready
        // Slave Interface Write Data Ports
        .s_axi_wdata                    (axi_wdata),  // input [31:0]			s_axi_wdata
        .s_axi_wstrb                    (axi_wstrb),  // input [3:0]			s_axi_wstrb
        .s_axi_wlast                    (axi_wlast),  // input			s_axi_wlast
        .s_axi_wvalid                   (axi_wvalid),  // input			s_axi_wvalid
        .s_axi_wready                   (axi_wready),  // output			s_axi_wready
        // Slave Interface Write Response Ports
        .s_axi_bid                      (axi_bid),  // output [0:0]			s_axi_bid
        .s_axi_bresp                    (axi_bresp),  // output [1:0]			s_axi_bresp
        .s_axi_bvalid                   (axi_bvalid),  // output			s_axi_bvalid
        .s_axi_bready                   (axi_bready),  // input			s_axi_bready
        // Slave Interface Read Address Ports
        .s_axi_arid                     (1'b0),  // input [0:0]			s_axi_arid
        .s_axi_araddr                   (axi_araddr[27:0]),  // input [27:0]			s_axi_araddr
        .s_axi_arlen                    (axi_arlen),  // input [7:0]			s_axi_arlen
        .s_axi_arsize                   (axi_arsize),  // input [2:0]			s_axi_arsize
        .s_axi_arburst                  (axi_arburst),  // input [1:0]			s_axi_arburst
        .s_axi_arlock                   (1'b0),  // input [0:0]			s_axi_arlock           <----------------------------- NOT USED
        .s_axi_arcache                  (1'b0),  // input [3:0]			s_axi_arcache           <----------------------------- NOT USED
        .s_axi_arprot                   (1'b0),  // input [2:0]			s_axi_arprot           <----------------------------- NOT USED
        .s_axi_arqos                    (1'b0),  // input [3:0]			s_axi_arqos           <----------------------------- NOT USED
        .s_axi_arvalid                  (axi_arvalid),  // input			s_axi_arvalid
        .s_axi_arready                  (axi_arready),  // output			s_axi_arready
        // Slave Interface Read Data Ports
        .s_axi_rid                      (axi_rid),  // output [0:0]			s_axi_rid
        .s_axi_rdata                    (axi_rdata),  // output [31:0]			s_axi_rdata
        .s_axi_rresp                    (axi_rresp),  // output [1:0]			s_axi_rresp
        .s_axi_rlast                    (axi_rlast),  // output			s_axi_rlast
        .s_axi_rvalid                   (axi_rvalid),  // output			s_axi_rvalid
        .s_axi_rready                   (axi_rready),  // input			s_axi_rready
        // System Clock Ports
//        .sys_clk_p                      (sys_clk_p),  // input				sys_clk_p
//        .sys_clk_n                      (sys_clk_n),  // input				sys_clk_n
        .sys_clk_i                      (sys_clk_i),  // input				sys_clk_i
        .sys_rst                        (sys_rst) // input sys_rst
    );

endmodule