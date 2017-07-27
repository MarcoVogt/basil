
`timescale 1ps / 1ps
`default_nettype none

module tb (
    
    input wire FCLK_IN, 
    
    //full speed 
    inout wire [7:0] BUS_DATA,
    input wire [31:0] ADD,
    input wire RD_B,
    input wire WR_B,
    
    //high speed
    inout wire [7:0] FD,
    input wire FREAD,
    input wire FSTROBE,
    input wire FMODE
    );   
    
    wire [4:0] LED;
    wire SDA;
    wire SCL;
    
    dram_test dut(.FCLK_IN(FCLK_IN), 
                  .BUS_DATA(BUS_DATA), .ADD(ADD), .RD_B(RD_B), .WR_B(WR_B),
                  .FD(FD), .FREAD(FREAD), .FSTROBE(FSTROBE), .FMODE(FMODE),
                  .LED(LED), .SDA(SDA), .SCL(SCL) );
  
    defparam dut.i_out_fifo.DEPTH = 32'h8000;


    initial begin
        $dumpfile("dram_test.vcd");
        $dumpvars(0);
    end

endmodule
