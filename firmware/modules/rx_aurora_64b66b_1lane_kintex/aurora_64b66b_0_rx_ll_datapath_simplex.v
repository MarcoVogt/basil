 ///////////////////////////////////////////////////////////////////////////////
 //
 // Project:  Aurora 64B/66B
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
 //  SIMPLEX RX LL DATAPATH
 //
 //
 
 //  Description: the RX_LL_DATAPATH module takes regular data in Aurora format
 //               and transforms it to LocalLink formatted data
 //
 //              
 ///////////////////////////////////////////////////////////////////////////////
 
 `timescale 1 ns / 10 ps
 
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_0_SIMPLEX_RX_LL_DATAPATH
 (
 
     //Aurora Lane Interface
     RX_PE_DATA,
     RX_PE_DATA_V,
 
     RX_SEP,
     RX_SEP7,
     RX_SEP_NB,
 
     RX_CC,           
     RX_CB,           
     RXDATAVALID_TO_LL,
     RX_IDLE,           
 
     RX_USER_K,
 
     // Global logic interface
     RX_CHANNEL_UP,
 
     //RX LocalLink Interface
     RX_D,
     RX_REM,
     RX_SRC_RDY_N,
     RX_SOF_N,
     RX_EOF_N,
     
     //System Interface
     USER_CLK,
     RESET
 );
 
 `define DLY #1
 
 //***********************************Port Declarations*******************************
     
    
     //Aurora Lane Interface
       input     [0:63]     RX_PE_DATA;  
       input                RX_PE_DATA_V; 
       input                RX_SEP; 
       input                RX_SEP7; 
       input     [0:2]      RX_SEP_NB;         
        
     //LocalLink Interface
       output    [0:63]     RX_D;               
       output               RX_SRC_RDY_N; 
       output    [0:2]      RX_REM;             
       output               RX_SOF_N; 
       output               RX_EOF_N; 
     
     
       input               RX_CC;           
       input               RX_CB;           
       input               RXDATAVALID_TO_LL; 
       input               RX_IDLE;           
 
       input               RX_USER_K;           
 
     //Global Interface
       input              RX_CHANNEL_UP; 
     
     //System Interface
       input              USER_CLK; 
       input              RESET; 
     
 //****************************Parameter Declarations**************************
 
     parameter REM_BITS  =  3;
 
 //****************************External Register Declarations**************************
 
       reg       [0:63]     RX_D;     
       reg                  RX_SRC_RDY_N; 
       reg       [0:2]      RX_REM;             
       reg                  RX_SOF_N; 
       reg                  RX_EOF_N;      
 
 //****************************Internal Register Declarations**************************
 
       reg                  gen_sof_r; 
       reg                  rx_src_rdy_n_r; 
       reg                  pipelined_cmd_valid_r; 
       reg                  execute_pipelined_cmd_r; 
       reg                  execute_current_cmd_r; 
       wire      [68:0]     raw_data_r;        
       wire      [68:0]     raw_data_r2;
 
 //*********************************Wire Declarations**********************************
 
       wire                 rx_pdu_ok_c; 
       wire                 ch_empty_c; 
       wire                 chl_full_c; 
       wire                 rx_sep_comb; 
       wire                 pipe1_rx_pdu_in_progress_c; 
 
       wire      [0:2]      rx_rem_c;             
       wire      [0:2]      rx_rem_c_1;             
       wire      [0:2]      pipe1_rx_sep_nb_r;         
       wire      [0:2]      pipe2_rx_sep_nb_r;        
    
     // Stage 1 pipeline 
       wire      [63:0]     pipe1_rx_pe_data_r;     
       wire                 rx_pe_data_v_c;     
       wire                 pipe1_rx_sep_r;      
       wire                 pipe1_rx_sep7_r;
     // Stage 2 pipeline 
       wire      [63:0]     pipe2_rx_pe_data_r;     
       wire                 pipe2_rx_pe_data_v_r;     
       wire                 pipe2_rx_sep_r;      
       wire                 pipe2_rx_sep7_r;      
       wire                 rx_userk_c;        
       wire                 rx_cc_c;        
       wire                 rx_sep_c; 
       wire                 rx_sep7_c; 
       wire                 rx_idle_c;        
 
       wire      [0:2]      rx_sep_nb_c; 
       wire      [68:0]     raw_data_c;        
       wire      [68:0]     raw_data_c2;    
 
 
     genvar    i;
 //*********************************Main Body of Code**********************************
 
 
     //Encode  RX_REM  based on RX_SEP_NB
 
     assign rx_pe_data_v_c = |RX_PE_DATA_V  & RX_CHANNEL_UP;
     assign rx_sep_c       = |RX_SEP & RX_CHANNEL_UP;
     assign rx_sep7_c      = |RX_SEP7 & RX_CHANNEL_UP;
     assign raw_data_c     = {RX_PE_DATA, rx_sep_nb_c, rx_sep_c, rx_sep7_c};
 
     generate for(i=0;i<69;i=i+1) begin:srlc32e0
     SRLC32E #(
             .INIT(32'h00000000)
     ) SRLC32E_inst (
             .Q(raw_data_r[i]),               // SRL data output
             .Q31(),                          // SRL cascade output pin
             .A(5'b0),                        // 5-bit shift depth select input
             .CE(pipe1_rx_pdu_in_progress_c), // Clock enable input
             .CLK(USER_CLK),                  // Clock input
             .D(raw_data_c[i])                // SRL data input
     );                                       // End of SRLC32E_inst instantiation
     end endgenerate
 
     // Stage 1 pipeline registers data & controls from the sym_dec module
     // If the received data beat is <8bytes then the pipe1 data & control
     // is passed on to the  RX_D   bus
     assign pipe1_rx_pe_data_r = raw_data_r[68:2+REM_BITS];
     assign pipe1_rx_sep_nb_r  = raw_data_r[2+REM_BITS-1:2];
     assign pipe1_rx_sep_r     = raw_data_r[1];
     assign pipe1_rx_sep7_r    = raw_data_r[0];
 
     assign   rx_userk_c       =  |RX_USER_K;
     assign   rx_cc_c          =  RX_CC;         
     assign   rx_idle_c        =  &RX_IDLE;
     assign   raw_data_c2      =  raw_data_r;
 
     generate for(i=0;i<69;i=i+1) begin:srlc32e1
     SRLC32E #(
             .INIT(32'h00000000)
     ) SRLC32E_inst (
             .Q(raw_data_r2[i]),              // SRL data output
             .Q31(),                          // SRL cascade output pin
             .A(5'b0),                        // 5-bit shift depth select input
             .CE(1'b1),                       // Clock enable input
             .CLK(USER_CLK),                  // Clock input
             .D(raw_data_c2[i])               // SRL data input
     );                                       // End of SRLC32E_inst instantiation
     end endgenerate
 
     // Stage 2 pipeline registers data & controls from the sym_dec module
     // If the received data beat is less than 8bytes then the pipe1 data & control
     // is passed on to the  RX_D  bus
     assign pipe2_rx_pe_data_r = raw_data_r2[68:2+REM_BITS];
     assign pipe2_rx_sep_nb_r  = raw_data_r2[2+REM_BITS-1:2];
     assign pipe2_rx_sep_r     = raw_data_r2[1];
     assign pipe2_rx_sep7_r    = raw_data_r2[0];
 
     assign rx_sep_nb_c      =     RX_SEP_NB;
 
     // rx_pdu_ok_c is set when received block is data block
     assign rx_pdu_ok_c =  (rx_pe_data_v_c  | ( (rx_sep_c  & rx_sep_nb_c != 3'h0) || rx_sep7_c)  );

 
     assign pipe1_rx_pdu_in_progress_c = ((rx_pe_data_v_c  | ( rx_sep_c | rx_sep7_c)  ) & ((!rx_cc_c) & (!rx_userk_c))); 
 
     // Channel is empty when SEP0 is received
     assign ch_empty_c = ((rx_sep_c & (rx_sep_nb_c == 3'h0)) & !rx_pe_data_v_c );
     // Channel is full received data is 8bytes long
     assign chl_full_c = (rx_pe_data_v_c &  !(rx_sep_c | rx_sep7_c) );
 
     // State machine executes only if the received block is a data block
     // Depends on rx_pdu_ok_c,ch_empty_c,pipelined_cmd_valid_r,chl_full_c
     // rx_src_rdy_n_r is set based on the type of datablock being received
     // pipelined_cmd_valid_r is set if a 8byte datablock is received
     // execute_pipelined_cmd_valid_r is set if the received block is 8byte 
     // and pipe2 data is passed on to the RX_D bus
     // execute_current_cmd_r is set if the received block is less than 8bytes wide
     // pipe1 data is passed on to the RX_D bus
     always @(posedge USER_CLK) 
     begin
         if(!RX_CHANNEL_UP)
         begin
                      rx_src_rdy_n_r          <= `DLY  1'b1;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      execute_pipelined_cmd_r <= `DLY  1'b0;
                      execute_current_cmd_r   <= `DLY  1'b0;
         end
 	else if(~((rx_userk_c) | (rx_cc_c) | (rx_idle_c & !(pipe1_rx_sep_r | pipe1_rx_sep7_r)) | (!RXDATAVALID_TO_LL) | RX_CB))
         begin
         casez({rx_pdu_ok_c,ch_empty_c,pipelined_cmd_valid_r,chl_full_c})
             4'b0000 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b1;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      end
 
             4'b0001 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b1;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      end
 
             4'b0010 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      execute_pipelined_cmd_r <= `DLY  1'b1;
                      end
 
             4'b0110 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      execute_pipelined_cmd_r <= `DLY  1'b1;
                      end
 
             4'b0011 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b1;
                      execute_pipelined_cmd_r <= `DLY  1'b1;
                      end
 
             4'b0100 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      execute_pipelined_cmd_r <= `DLY  1'b1;
                      end
 
             4'b0111 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b1;
                      execute_pipelined_cmd_r <= `DLY  1'b1;
                      end
 
             4'b1000 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      execute_current_cmd_r   <= `DLY  1'b1;
                      execute_pipelined_cmd_r <= `DLY  1'b0;
                      end
 
             4'b1001 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b1;
                      pipelined_cmd_valid_r   <= `DLY  1'b1;
                      execute_current_cmd_r   <= `DLY  1'b0;
                      end
 
             4'b1010 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b1;
                      execute_pipelined_cmd_r <= `DLY  1'b1;
                      execute_current_cmd_r   <= `DLY  1'b0;
                      end
 
             4'b1011 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b1;
                      execute_pipelined_cmd_r <= `DLY  1'b1;
                      execute_current_cmd_r   <= `DLY  1'b0;
                      end
 
             4'b1110 :begin
                      rx_src_rdy_n_r          <= `DLY  1'b0;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      end
 
             default :begin
                      rx_src_rdy_n_r          <= `DLY  1'b1;
                      pipelined_cmd_valid_r   <= `DLY  1'b0;
                      execute_pipelined_cmd_r <= `DLY  1'b0;
                      execute_current_cmd_r   <= `DLY  1'b0;
                      end
           endcase
         end
         else
                      rx_src_rdy_n_r          <= `DLY  1'b1;
     end
 
     always @(posedge USER_CLK)
     begin
         if ( execute_current_cmd_r)
             RX_D    <=  `DLY pipe1_rx_pe_data_r;
         else if(execute_pipelined_cmd_r)
             RX_D    <=  `DLY pipe2_rx_pe_data_r;
     end
 
     //Register the SRC_RDY_N signal
     always @(posedge USER_CLK)
     begin
         if(!RX_CHANNEL_UP)
                     RX_SRC_RDY_N   <=  `DLY 1'b1;
         else     
                     RX_SRC_RDY_N   <=  `DLY rx_src_rdy_n_r; 
     end
 
     always @(posedge USER_CLK)
     begin
       if( ( (pipe1_rx_sep_r & (pipe1_rx_sep_nb_r == 3'h0)) | ((pipe2_rx_sep_r & (pipe2_rx_sep_nb_r != 3'h0)) | pipe2_rx_sep7_r ) ) & !rx_src_rdy_n_r & execute_pipelined_cmd_r)
                   RX_EOF_N  <=  `DLY  1'b0;
       else if(  ( (pipe1_rx_sep_r & (pipe1_rx_sep_nb_r != 3'h0)) | pipe1_rx_sep7_r) & !rx_src_rdy_n_r & execute_current_cmd_r )
                   RX_EOF_N  <=  `DLY  1'b0;
       else if( (rx_pdu_ok_c & ch_empty_c & pipelined_cmd_valid_r) & !rx_src_rdy_n_r)
                   RX_EOF_N  <=  `DLY  1'b0;
       else
                   RX_EOF_N  <=  `DLY 1'b1;
     end
 
     assign rx_rem_c   = pipe1_rx_sep_nb_r;
 
     assign rx_rem_c_1 = pipe2_rx_sep_nb_r;
 
     //SEP_NB is assigned to RX_REM    
     always @(posedge USER_CLK)
     begin
         if ( execute_current_cmd_r)
            RX_REM  <=  `DLY    rx_rem_c;
         else if(execute_pipelined_cmd_r)
            RX_REM  <=  `DLY    rx_rem_c_1;
     end
  
     always @(posedge USER_CLK)
     begin
         if(!RX_CHANNEL_UP)
                   gen_sof_r <= `DLY  1'b1;
         else if(!RX_SOF_N & !RX_EOF_N)
                   gen_sof_r <= `DLY  1'b1;
         else if(!RX_SOF_N)
                   gen_sof_r <= `DLY  1'b0;
         else if(!RX_EOF_N)
                   gen_sof_r <= `DLY  1'b1;
     end
 
     always @(posedge USER_CLK)
     begin
        if (!RX_CHANNEL_UP)
                   RX_SOF_N  <= `DLY  1'b1;
        else if(!rx_src_rdy_n_r & !RX_SOF_N & RX_EOF_N)
                   RX_SOF_N  <= `DLY  1'b1;
        else if(!rx_src_rdy_n_r & gen_sof_r)
                   RX_SOF_N  <= `DLY  1'b0;
        else if(!rx_src_rdy_n_r & !RX_EOF_N)
                   RX_SOF_N  <= `DLY  1'b0;
        else
                   RX_SOF_N  <= `DLY  1'b1;
     end
 
 endmodule
 
 
