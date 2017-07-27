/**
 * ------------------------------------------------------------
 * Copyright (c) All rights reserved
 * SiLab, Institute of Physics, University of Bonn
 * ------------------------------------------------------------
 */
`timescale 1ps / 1ps
`default_nettype none

module ddrvfifo_core
#(
    parameter                   DEPTH = 32'h8000,
    parameter                   FIFO_ALMOST_FULL_THRESHOLD = 95, // in percent
    parameter                   FIFO_ALMOST_EMPTY_THRESHOLD = 5, // in percent
    parameter                   ABUSWIDTH = 16
)
(
    input wire                  BUS_CLK,
    input wire                  BUS_RST,
    input wire [ABUSWIDTH-1:0]  BUS_ADD,
    input wire [7:0]            BUS_DATA_IN,
    input wire                  BUS_RD,
    input wire                  BUS_WR,
    output reg [7:0]            BUS_DATA_OUT,

    input wire                  INIT_DONE,
    input wire					VALID

   /*,

    output wire 				EMPTY,
    output wire 				FULL,
    output wire [31:0]          DATA_OUT,
    input wire [31:0]           DATA_IN,
    input wire                  READ,
    input wire                  WRITE
*/
);

localparam VERSION = 1;

/*
//for testing
assign DATA_OUT = DATA_IN;
assign FULL = 1'b0;
assign EMPTY = 1'b1;
*/


wire SOFT_RST; //0
assign SOFT_RST = (BUS_ADD==0 && BUS_WR);

wire RST;
assign RST = BUS_RST | SOFT_RST;

reg [7:0] status_regs[7:0];

// reg 0 for SOFT_RST
wire [7:0] FIFO_ALMOST_FULL_VALUE;
assign FIFO_ALMOST_FULL_VALUE = status_regs[1];
wire [7:0] FIFO_ALMOST_EMPTY_VALUE;
assign FIFO_ALMOST_EMPTY_VALUE = status_regs[2];


always @(posedge BUS_CLK)
begin
    if(RST)
    begin
        status_regs[0] <= 8'b0;
        status_regs[1] <= 255*FIFO_ALMOST_FULL_THRESHOLD/100;
        status_regs[2] <= 255*FIFO_ALMOST_EMPTY_THRESHOLD/100;
        status_regs[3] <= 8'b0;
        status_regs[4] <= 8'b0;
        status_regs[5] <= 8'b0;
        status_regs[6] <= 8'b0;
        status_regs[7] <= 8'b0;
    end
    else if(BUS_WR && BUS_ADD < 8)
    begin
        status_regs[BUS_ADD[2:0]] <= BUS_DATA_IN;
    end
//    else if(BUS_WR && (BUS_ADD >= 8 && BUS_ADD <  ))
//    begin
//    end
end


// read reg
wire [31:0] CONF_SIZE_BYTE; // write data count, 1 - 2 - 3, in units of byte
reg [31:0] CONF_SIZE_BYTE_BUF;
reg [7:0] CONF_READ_ERROR; // read error count (read attempts when FIFO is empty), 4
wire [31:0] CONF_SIZE; // in units of int
assign CONF_SIZE_BYTE = CONF_SIZE * 4;

always @ (posedge BUS_CLK) begin
    if(BUS_RD) begin
        if(BUS_ADD == 0)
            BUS_DATA_OUT <= VERSION;
        else if(BUS_ADD == 1)
            BUS_DATA_OUT <= FIFO_ALMOST_FULL_VALUE;
        else if(BUS_ADD == 2)
            BUS_DATA_OUT <= FIFO_ALMOST_EMPTY_VALUE;
        else if(BUS_ADD == 3)
            BUS_DATA_OUT <= {6'd0, INIT_DONE, VALID};//CONF_READ_ERROR;
        else if(BUS_ADD == 4)
            BUS_DATA_OUT <= CONF_SIZE_BYTE[7:0]; // in units of bytes
        else if(BUS_ADD == 5)
            BUS_DATA_OUT <= CONF_SIZE_BYTE_BUF[15:8];
        else if(BUS_ADD == 6)
            BUS_DATA_OUT <= CONF_SIZE_BYTE_BUF[23:16];
        else if(BUS_ADD == 7)
            BUS_DATA_OUT <= CONF_SIZE_BYTE_BUF[31:24];
        else
            BUS_DATA_OUT <= 8'b0;
    end
end

always @ (posedge BUS_CLK)
begin
    if (BUS_ADD == 4 && BUS_RD)
        CONF_SIZE_BYTE_BUF <= CONF_SIZE_BYTE;
end


`include "../includes/log2func.v"
localparam POINTER_SIZE = `CLOG2(DEPTH);
/*
gerneric_fifo
#(  .DATA_SIZE(32),
    .DEPTH(DEPTH))
i_buf_fifo
(   .clk(BUS_CLK),
    .reset(RST),
    .write(!FIFO_EMPTY_IN || BUS_WR_DATA),
    .read(USB_READ&&(usb_byte_cnt==2'b11) || BUS_RD_DATA),
    .data_in(BUS_WR_DATA ? BUS_DATA_IN_DATA : FIFO_DATA),
    .full(FULL_BUF),
    .empty(FIFO_EMPTY_IN_BUF),
    .data_out(FIFO_DATA_BUF),
    .size(CONF_SIZE[POINTER_SIZE-1:0])
);
*/
assign CONF_SIZE[31:POINTER_SIZE] = 0;

/*
reg [1:0] usb_byte_cnt = 2'b00;
reg [7:0] USB_DATA_MUX = 8'd0;
always@(posedge BUS_CLK) begin
    BUS_DATA_OUT_DATA <= FIFO_DATA_BUF;
	if(USB_READ) begin
		usb_byte_cnt <= usb_byte_cnt + 1;
	end
end

*/

/*
assign USB_DATA =
	(usb_byte_cnt == 2'b11 ) ? FIFO_DATA_BUF[31:24] :
	(usb_byte_cnt == 2'b10 ) ? FIFO_DATA_BUF[23:16] :
  	(usb_byte_cnt == 2'b01 ) ? FIFO_DATA_BUF[15:8] :
  	(usb_byte_cnt == 2'b00 ) ? FIFO_DATA_BUF[7:0] :
 	8'h00;
*/

//assign FIFO_NOT_EMPTY = !FIFO_EMPTY_IN_BUF;
//assign FIFO_FULL = FULL_BUF;
//assign FIFO_READ_ERROR = (CONF_READ_ERROR != 0);

/*
always@(posedge BUS_CLK) begin
    if(RST)
        CONF_READ_ERROR <= 0;
    else if(FIFO_EMPTY_IN_BUF && BUS_RD_DATA && CONF_READ_ERROR != 8'hff)
        CONF_READ_ERROR <= CONF_READ_ERROR +1;
end
*/

/*
always @(posedge BUS_CLK) begin
    if(RST)
        FIFO_NEAR_FULL <= 1'b0;
    else if (((((FIFO_ALMOST_FULL_VALUE+1)*DEPTH)>>8) <= CONF_SIZE) || (FIFO_ALMOST_FULL_VALUE == 8'b0 && CONF_SIZE >= 0))
        FIFO_NEAR_FULL <= 1'b1;
    else if (((((FIFO_ALMOST_EMPTY_VALUE+1)*DEPTH)>>8) >= CONF_SIZE && FIFO_ALMOST_EMPTY_VALUE != 8'b0) || CONF_SIZE == 0)
        FIFO_NEAR_FULL <= 1'b0;
end
*/

endmodule
