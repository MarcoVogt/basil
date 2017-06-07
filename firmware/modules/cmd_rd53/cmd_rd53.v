/**
 * ------------------------------------------------------------
 * Copyright (c) All rights reserved
 * SiLab, Institute of Physics, University of Bonn
 * ------------------------------------------------------------
 */
`timescale 1ps/1ps

module cmd_rd53
#(
    parameter BASEADDR = 32'h0000,
    parameter HIGHADDR = 32'h0000,
    parameter ABUSWIDTH = 16
) (
    input wire                  BUS_CLK,
    input wire                  BUS_RST,
    input wire  [ABUSWIDTH-1:0] BUS_ADD,
    inout wire  [7:0]           BUS_DATA,
    input wire                  BUS_RD,
    input wire                  BUS_WR,

    input wire					EXT_START_PIN,
    input wire 					EXT_TRIGGER,

    input wire                  CMD_CLK,
    output wire                 CMD_EN,
    output wire					CMD_SERIAL_OUT,
    output wire                 CMD_DATA_VAL
);

localparam VERSION = 1;

wire IP_RD, IP_WR;
wire [ABUSWIDTH-1:0] IP_ADD;
wire [7:0] IP_DATA_IN;
wire [7:0] IP_DATA_OUT;

bus_to_ip #( .BASEADDR(BASEADDR), .HIGHADDR(HIGHADDR), .ABUSWIDTH(ABUSWIDTH) ) i_bus_to_ip
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


cmd_rd53_core
#(
    .ABUSWIDTH(ABUSWIDTH)
) i_cmd_rd53_core
(
    .BUS_CLK(BUS_CLK),
    .BUS_RST(BUS_RST),
    .BUS_ADD(IP_ADD),
    .BUS_DATA_IN(IP_DATA_IN),
    .BUS_RD(IP_RD),
    .BUS_WR(IP_WR),
    .BUS_DATA_OUT(IP_DATA_OUT),

    .EXT_START_PIN(EXT_START_PIN),
    .EXT_TRIGGER(EXT_TRIGGER),

    .CMD_CLK(CMD_CLK),
    .CMD_EN(CMD_EN),
    .CMD_SERIAL_OUT(CMD_SERIAL_OUT),
    .CMD_DATA_VAL(CMD_DATA_VAL)
);

endmodule