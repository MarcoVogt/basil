`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2017 03:09:24 PM
// Design Name: 
// Module Name: tb
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


module tb(
);

    wire UART_TEST;
    reg RESET;
    reg CLK, CLK_UART;
    
    parameter CLK_PERIOD        = 20.0;
    parameter CLK_UART_PERIOD   = 217 * 4 * CLK_PERIOD;     // 57600 Hz
  
        

    uartlib uartlib_i
    (
        .UART_CLK(CLK_UART),
        .UART_TX(UART_TEST)    
    );    
    
    te0725 te0725_i
    (
        .USER_RESET(RESET),
        .SYS_CLK(CLK),
        
        .UART_RX(UART_TEST),
        .UART_TX(),
        
        .LED(),
        .GPIO_LED(),
        .GPIO_DIP(),
        
        //HyperRAM
        .H1_D(),
        .H1_RWDS(),
        .H1_CLK_P(),
        .H1_CLK_N(),
        .H1_RESET_N(),
        .H1_CS()
    );
  

    
    initial
        begin
            CLK = 1'b0;
            CLK_UART = 1'b0;
            RESET = 1'b0;
            RESET = 1'b1;
            #(100*CLK_PERIOD);
            RESET = 1'b0;  
            uartlib_i.read(  32'h00000000, 8 ); 
            //uartlib_i.write( 2, 1 );    
    end
     
    //____________________________Clocks____________________________
    always  
        #(CLK_PERIOD / 2) CLK = !CLK;
    always  
        #(CLK_UART_PERIOD / 2) CLK_UART = !CLK_UART;
        

    
endmodule
