
=====================================
**cmd_rd53** - cmd generator (RD53)
=====================================

Command generator for RD53(A)


Instantiation template:

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

    .EXT_START_PIN(),
    .EXT_TRIGGER(),

    .CMD_CLK(),
    .CMD_EN(),
    .CMD_SERIAL_OUT()   
);
