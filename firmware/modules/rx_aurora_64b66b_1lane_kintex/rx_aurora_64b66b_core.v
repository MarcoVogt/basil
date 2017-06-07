/**
 * ------------------------------------------------------------
 * Copyright (c) All rights reserved
 * SiLab, Institute of Physics, University of Bonn
 * ------------------------------------------------------------
 */
`timescale 1ps/1ps
`default_nettype none

//`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_exdes.v"

module rx_aurora_64b66b_core
#(
    parameter ABUSWIDTH = 16,
    parameter IDENTIFIER = 0
)(
    input wire [3:0] RXP, RXN,
    input wire RX_CLK_P, RX_CLK_N,
    input wire RX_INIT_CLK_P, RX_INIT_CLK_N,

    input wire FIFO_READ,
    output wire FIFO_EMPTY,
    output wire [31:0] FIFO_DATA,

    input wire BUS_CLK,
    input wire [ABUSWIDTH-1:0] BUS_ADD,
    input wire [7:0] BUS_DATA_IN,
    output reg [7:0] BUS_DATA_OUT,
    input wire BUS_RST,
    input wire BUS_WR,
    input wire BUS_RD,

    output wire RX_READY,
    output wire LOST_ERROR,

    input wire AURORA_RESET
);

localparam VERSION = 1;

//output format #ID (as parameter IDENTIFIER + 1 frame start + 16 bit data)

wire SOFT_RST;
assign SOFT_RST = (BUS_ADD==0 && BUS_WR);

wire RST;
assign RST = BUS_RST | SOFT_RST;

reg CONF_EN;

always @(posedge BUS_CLK) begin
    if(RST) begin
        CONF_EN <= 0;
    end
    else if(BUS_WR) begin
        if(BUS_ADD == 2)
            CONF_EN <= BUS_DATA_IN[0];
    end
end

reg [7:0] LOST_DATA_CNT;

wire RX_HARD_ERROR, SOFT_ERROR, RX_LANE_UP, RX_CHANNEL_UP;

always @(posedge BUS_CLK) begin
    if(BUS_RD) begin
        if(BUS_ADD == 0)
            BUS_DATA_OUT <= VERSION;
        else if(BUS_ADD == 2)
            BUS_DATA_OUT <= {5'b0, RX_LANE_UP, RX_READY, CONF_EN};
        else if(BUS_ADD == 3)
            BUS_DATA_OUT <= LOST_DATA_CNT;
        else if(BUS_ADD == 4)
          BUS_DATA_OUT <= RX_LANE_UP;
      else
            BUS_DATA_OUT <= 8'b0;
    end
end

wire RST_SYNC;
wire RST_SOFT_SYNC;
reg    reset_rx;

cdc_reset_sync rst_pulse_sync (.clk_in(BUS_CLK), .pulse_in(RST), .clk_out(RX_CLK_P), .pulse_out(RST_SOFT_SYNC));
assign RST_SYNC = RST_SOFT_SYNC;

wire CONF_EN_SYNC;
assign CONF_EN_SYNC  = CONF_EN;

wire USER_CLK;

// ---- aurora core for simulation -----//
//parameter	CLOCKPERIOD_1 = 15640ps;//12.5;

reg     pma_init_r;
/*
reg		gsr_r;
reg     gts_r;
//reg    reset_rx;
reg     pma_init_r;
reg     gsr_done;            //Indicates the deassertion of GSR

assign	glbl.GSR = gsr_r;
assign  glbl.GTS = gts_r;

initial
    begin
     gts_r      = 1'b0;
     gsr_r      = 1'b1;
     gsr_done   = 1'b0;
     //reset_tx    = 1'b1;
     reset_rx   = 1'b1;
       #(130*CLOCKPERIOD_1);
     pma_init_r = 1'b1;
     gsr_r      = 1'b0;
     #(1600*CLOCKPERIOD_1);
     gsr_done   = 1'b1;
     pma_init_r = 1'b0;
     #(130*CLOCKPERIOD_1);
     reset_rx    = 1'b0;
     //#(10*TIME_UNIT) reset_tx   = 1'b0;
end

initial
    RX_CLK = 1'b0;

always
    #(CLOCKPERIOD_1 / 2) RX_CLK = !RX_CLK;

*/

wire RX_TLAST;
wire RX_TVALID;
wire [63:0] RX_TDATA;
wire [7:0] RX_TKEEP;

// ---- aurora core for simulation -----//

assign RX_READY = RX_CHANNEL_UP & RX_LANE_UP;

wire RST_USER_SYNC;
cdc_reset_sync rst_pulse_user_sync (.clk_in(BUS_CLK), .pulse_in(RST), .clk_out(USER_CLK), .pulse_out(RST_USER_SYNC));

reg RX_TFIRST;
always@(posedge USER_CLK)
    if(RST_USER_SYNC)
        RX_TFIRST <= 1;
    else if(RX_TVALID & RX_TLAST)
        RX_TFIRST <= 1;
    else if(RX_TVALID)
        RX_TFIRST <= 0;

wire byte4;
assign byte4 = (RX_TKEEP == 8'hff);
localparam DATA_SIZE_FIFO = 1+1+64;
wire [DATA_SIZE_FIFO-1:0] data_to_cdc;
assign data_to_cdc = {byte4, RX_TFIRST, RX_TDATA};

wire [DATA_SIZE_FIFO-1:0] cdc_data_out;
wire read_fifo_cdc, wfull, cdc_fifo_empty;
cdc_syncfifo #(.DSIZE(DATA_SIZE_FIFO), .ASIZE(4)) cdc_syncfifo_i
(
    .rdata(cdc_data_out),
    .wfull(wfull),
    .rempty(cdc_fifo_empty),
    .wdata(data_to_cdc),
    .winc(RX_TVALID), .wclk(USER_CLK), .wrst(RST_USER_SYNC),
    .rinc(read_fifo_cdc), .rclk(BUS_CLK), .rrst(RST)
    );

wire write_out_fifo;
reg [1:0] byte2_cnt, byte2_cnt_prev;
wire fifo_full;
assign write_out_fifo = (byte2_cnt != 0 || byte2_cnt_prev != 0);
assign read_fifo_cdc = (byte2_cnt_prev==0 & byte2_cnt!=0);


wire USER_K_ERR;
wire [63:0] USER_K_DATA;
wire USER_K_VALID;

aurora_64b66b_0_exdes  #( .SIMPLEX_TIMER_VALUE(10) ) aurora_frame (
    // Error signals from Aurora
    .RX_HARD_ERR(RX_HARD_ERROR),
    .RX_SOFT_ERR(SOFT_ERROR),
    .RX_LANE_UP(RX_LANE_UP),
    .RX_CHANNEL_UP(RX_CHANNEL_UP),

    .INIT_CLK_P(RX_INIT_CLK_P),  //RX_CLK_P
    .INIT_CLK_N(RX_INIT_CLK_N),  //RX_CLK_N

    .PMA_INIT(pma_init_r),

    .GTXQ0_P(RX_CLK_P),
    .GTXQ0_N(RX_CLK_N),

    .RXP(RXP[0]),
    .RXN(RXN[0]),

    // Error signals from the Local Link packet checker
    .DATA_ERR_COUNT(),

    //USER_K
    .USER_K_ERR(USER_K_ERR),
    .USER_K_DATA(USER_K_DATA),
    .USER_K_VALID(USER_K_VALID),

    // User IO
    .RESET(reset_rx), //RST_USER_SYNC

    .DRP_CLK_IN(BUS_CLK),
    .USER_CLK(USER_CLK),
    .RX_TDATA(RX_TDATA),
    .RX_TVALID(RX_TVALID),
    .RX_TKEEP(RX_TKEEP),
    .RX_TLAST(RX_TLAST)

);

always@(posedge BUS_CLK)
    byte2_cnt_prev <= byte2_cnt;

always@(posedge BUS_CLK)
    if(RST)
        byte2_cnt <= 0;
    else if(!cdc_fifo_empty && !fifo_full && byte2_cnt == 0 )
    begin
        if(cdc_data_out[DATA_SIZE_FIFO-1])
            byte2_cnt <= 3;
        else
            byte2_cnt <= 1;
    end
    else if (!fifo_full & byte2_cnt != 0)
        byte2_cnt <= byte2_cnt - 1;

reg [DATA_SIZE_FIFO-1:0] data_buf;
wire [16:0] data_out;
wire [16:0] fifo_data_out_byte [3:0];

wire byte4_sel;
assign byte4_sel = read_fifo_cdc ? cdc_data_out[DATA_SIZE_FIFO-1] : data_buf[DATA_SIZE_FIFO-1];

assign fifo_data_out_byte[0] = byte4_sel ? {1'b0, data_buf[23:16], data_buf[31:24]} : {1'b0, data_buf[55:48], data_buf[63:56]};
assign fifo_data_out_byte[1] = byte4_sel ? {1'b0, data_buf[7:0],data_buf[15:8]} : {cdc_data_out[DATA_SIZE_FIFO-2], cdc_data_out[39:32],cdc_data_out[47:40]};
assign fifo_data_out_byte[2] = {1'b0, data_buf[55:48], data_buf[63:56]} ;
assign fifo_data_out_byte[3] = {cdc_data_out[DATA_SIZE_FIFO-2], cdc_data_out[39:32],cdc_data_out[47:40]};


assign data_out = fifo_data_out_byte[byte2_cnt];

always@(posedge BUS_CLK)
    if(read_fifo_cdc)
        data_buf <= cdc_data_out;

wire [23:0] cdc_data;
assign cdc_data = {7'b0, data_out};

gerneric_fifo #(.DATA_SIZE(24), .DEPTH(1024))  fifo_i
(   .clk(BUS_CLK), .reset(RST),
    .write(write_out_fifo),
    .read(FIFO_READ),
    .data_in(cdc_data),
    .full(fifo_full),
    .empty(FIFO_EMPTY),
    .data_out(FIFO_DATA[23:0]), .size()
);


always@(posedge USER_CLK) begin
    if(RST_USER_SYNC)
        LOST_DATA_CNT <= 0;
    else if (wfull && RX_TVALID && LOST_DATA_CNT != -1)
        LOST_DATA_CNT <= LOST_DATA_CNT +1;
end


assign FIFO_DATA[31:24]  =  IDENTIFIER[7:0];

assign LOST_ERROR = LOST_DATA_CNT != 0;

endmodule
