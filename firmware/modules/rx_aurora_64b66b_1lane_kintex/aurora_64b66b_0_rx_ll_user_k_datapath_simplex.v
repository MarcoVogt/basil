 ///////////////////////////////////////////////////////////////////////////////
 //  
 // Project:  Aurora 64B66B
 // Company:  Xilinx
 //
 //
 //
 // (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
 //
 // This file contains confidential and proprietary information
 // of Xilinx, Inc. and is protected under U.S. and
 // international copyright and other intellectual property
 // laws.
 //
 // DISCLAIMER
 // This disclaimer is not a license and does not grant any
 // rights to the materials distributed herewith. Except as
 // otherwise provided in a valid license issued to you by
 // Xilinx, and to the maximum extent permitted by applicable
 // law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
 // WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
 // AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
 // BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
 // INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
 // (2) Xilinx shall not be liable (whether in contract or tort,
 // including negligence, or under any other theory of
 // liability) for any loss or damage of any kind or nature
 // related to, arising under or in connection with these
 // materials, including for any direct, or any indirect,
 // special, incidental, or consequential loss or damage
 // (including loss of data, profits, goodwill, or any type of
 // loss or damage suffered as a result of any action brought
 // by a third party) even if such damage or loss was
 // reasonably foreseeable or Xilinx had been advised of the
 // possibility of the same.
 //
 // CRITICAL APPLICATIONS
 // Xilinx products are not designed or intended to be fail-
 // safe, or for use in any application requiring fail-safe
 // performance, such as life-support or safety devices or
 // systems, Class III medical devices, nuclear facilities,
 // applications related to the deployment of airbags, or any
 // other applications that could lead to death, personal
 // injury, or severe property or environmental damage
 // (individually and collectively, "Critical
 // Applications"). Customer assumes the sole risk and
 // liability of any use of Xilinx products in Critical
 // Applications, subject only to applicable laws and
 // regulations governing limitations on product liability.
 //
 // THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
 // PART OF THIS FILE AT ALL TIMES.
 
 //  
 ///////////////////////////////////////////////////////////////////////////////
 //
 //  aurora_64b66b_0_SIMPLEX_RX_LL_USER_K_DATAPATH
 //
 //  
 //  Description: The aurora_64b66b_0_SIMPLEX_RX_LL_USER_K_DATAPATH module takes USER_K data in and sends it to LocalLink formatted data
 //  
 //
 //
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *) 
 module aurora_64b66b_0_SIMPLEX_RX_LL_USER_K_DATAPATH
 (
     //Aurora lane Interface
     RX_USER_K,
     RX_USER_K_BLK_NO,
     RX_PE_DATA,
 
     //LocalLink UFC Interface
     USER_K_RX_DATA,
     USER_K_RX_SRC_RDY_N,
     USER_K_RX_BLK_NO,
     RX_CHANNEL_UP,
     
    //System Interface
     USER_CLK,
     RESET
 );
 
 `define DLY #1
 
 //***********************************Port Declarations*******************************
 
     //Aurora Lane Interface
       input                    RX_USER_K; 
       input         [0:3]      RX_USER_K_BLK_NO; 
 
       input         [0:63]     RX_PE_DATA; 
 
     //LocalLink Interface
       output        [0:55]     USER_K_RX_DATA; 
       output                   USER_K_RX_SRC_RDY_N; 
       output        [0:3]      USER_K_RX_BLK_NO; 
       input                    RX_CHANNEL_UP; 
     //System Interface
       input                    USER_CLK; 
       input                    RESET; 
 
 //****************************External Register Declarations**************************
 
       reg           [0:55]     USER_K_RX_DATA; 
       reg                      USER_K_RX_SRC_RDY_N; 
       reg           [0:3]      USER_K_RX_BLK_NO; 
 
 //*********************************Wire Declarations**************************
 
       wire          [0:55]     user_k_rx_data_c; 
 
 //*********************************Main Body of Code**********************************
 
     assign user_k_rx_data_c = {RX_PE_DATA[0:55]};
 
     always@(posedge USER_CLK)
     begin
         if(RESET)
                  USER_K_RX_SRC_RDY_N   <=  `DLY  1'b1;
         else if(|RX_USER_K & RX_CHANNEL_UP)
                  USER_K_RX_SRC_RDY_N   <=  `DLY  1'b0;
         else
                  USER_K_RX_SRC_RDY_N   <=  `DLY  1'b1;
     end
                                                                                                                              
     always@(posedge USER_CLK)
     begin
         if(RESET)
         begin
                  USER_K_RX_DATA    <=  `DLY  56'b0;
                  USER_K_RX_BLK_NO  <=  `DLY  4'b0;
         end
         else if( |RX_USER_K )
         begin
                  USER_K_RX_DATA    <=   `DLY  user_k_rx_data_c ;
                  USER_K_RX_BLK_NO  <=   `DLY  RX_USER_K_BLK_NO;
         end
     end
 
 endmodule
 
