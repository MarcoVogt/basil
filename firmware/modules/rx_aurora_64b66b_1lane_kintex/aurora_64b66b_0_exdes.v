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
 //  EXAMPLE_DESIGN
 //
 //
 //
 //
 //  Description:  This module instantiates 1 lane Aurora Module.
 //                Used to exhibit functionality in hardware using the example design
 //                The User Interface is connected to Data Generator or Checker.
 //
 ///////////////////////////////////////////////////////////////////////////////
 // This is sample simplex exdes file
`timescale 1 ns / 10 ps

`default_nettype wire

/*
`include "aurora_64b66b_0_support.v"
`include "rx_aurora_64b66b_kintex/support/aurora_64b66b_0_clock_module.v"
`include "rx_aurora_64b66b_kintex/support/aurora_64b66b_0_gt_common_wrapper.v"
`include "rx_aurora_64b66b_kintex/support/aurora_64b66b_0_support_reset_logic.v"

`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_64b66b_descrambler.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_axi_to_ll.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_axi_to_drp.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_block_sync_sm.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_cbcc_gtx_6466.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_cdc_sync.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_cdc_sync_exdes.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_common_reset_cbcc.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_common_logic_cbcc.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_example_axi_to_ll.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_frame_check.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_ll_to_axi.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_reg_slice_0.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_reg_slice_2.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_reset_logic.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_global_logic_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_lane_init_sm_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_ll_datapath_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_ll_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_ll_user_k_datapath_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_aurora_lane_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_channel_err_detect_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_channel_init_sm_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_err_detect_simplex.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_rx_startup_fsm.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_sym_dec.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_width_conversion.v"

`include "rx_aurora_64b66b_kintex/axi/axis_infrastructure_v1_1_0_axis_infrastructure.vh"
`include "rx_aurora_64b66b_kintex/axi/axis_register_slice_v1_1_axis_register_slice.v"
`include "rx_aurora_64b66b_kintex/axi/axis_register_slice_v1_1_axisc_register_slice.v"
`include "rx_aurora_64b66b_kintex/axi/axis_infrastructure_v1_1_util_axis2vector.v"
`include "rx_aurora_64b66b_kintex/axi/axis_infrastructure_v1_1_util_vector2axis.v"


`include "rx_aurora_64b66b_kintex/gt/aurora_64b66b_0_gtx.v"
`include "rx_aurora_64b66b_kintex/gt/aurora_64b66b_0_multi_wrapper.v"
`include "rx_aurora_64b66b_kintex/gt/aurora_64b66b_0_wrapper.v"

`include "rx_aurora_64b66b_kintex/aurora_64b66b_0_core.v"
`include "rx_aurora_64b66b_kintex/aurora_64b66b_0.v"
*/


   (* core_generation_info = "aurora_64b66b_0,aurora_64b66b_v11_0_1,{c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTXQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=1.6,c_gt_type=gtx,c_qpll=false,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=80.0,c_simplex=true,c_simplex_mode=RX,c_stream=false,c_ufc=false,c_user_k=true,flow_mode=None,interface_mode=Framing,dataflow_config=RX-only_Simplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_0_exdes #
 (
     parameter   EXAMPLE_SIMULATION =	0
     ,
     parameter USE_CORE_TRAFFIC		=	0,
     parameter USR_CLK_PCOUNT     	=	20'hFFFFF,
     parameter USE_LABTOOLS       	=	0,
     parameter SIMPLEX_TIMER_VALUE 	= 	10
 )
 (
   // User IO
     RX_HARD_ERR,
     RX_SOFT_ERR,
     RX_LANE_UP,
     RX_CHANNEL_UP,
     INIT_CLK_P,
     INIT_CLK_N,
     PMA_INIT,
     //70MHz DRP clk for Virtex-6 GTH
     DRP_CLK_IN,
     GTXQ0_P,
     GTXQ0_N,

   //USER_K
     USER_K_ERR,
     USER_K_DATA,
     USER_K_VALID,

   // Frame check interface
     DATA_ERR_COUNT,

   // GTX I/O
     RXP,
     RXN,

     USER_CLK,
     RX_TDATA,
     RX_TVALID,
     RX_TKEEP,
     RX_TLAST,

     RESET
 );
 `define DLY #1


 //***********************************Port Declarations*******************************

     // User I/O
       input              RESET;

       output             RX_HARD_ERR;
       output             RX_SOFT_ERR;
       output  [0:7]      DATA_ERR_COUNT;
       output             RX_LANE_UP;
       output             RX_CHANNEL_UP;

       input              INIT_CLK_P;
       input              INIT_CLK_N;
       input              PMA_INIT;
       input              DRP_CLK_IN;
     // Clocks
       input              GTXQ0_P;
       input              GTXQ0_N;

     // USER_K
       output             USER_K_ERR;
       output [63:0]      USER_K_DATA;
       output			  USER_K_VALID;

     // GTX I/O
       input              RXP;
       input              RXN;

       output             USER_CLK;
       output   [0:63]    RX_TDATA;
       output             RX_TVALID;
       output   [0:7]     RX_TKEEP;
       output             RX_TLAST;


 //**************************External Register Declarations****************************

       reg                RX_HARD_ERR;
       reg                RX_SOFT_ERR;
(* KEEP = "TRUE" *)       reg     [0:7]      DATA_ERR_COUNT;
       reg                RX_LANE_UP;
       reg                RX_CHANNEL_UP;

       reg [63:0]		  USER_K_DATA;
       reg				  USER_K_VALID;
       reg                USER_K_ERR;

 //********************************Wire Declarations**********************************
     wire    [280:0]          tied_to_ground_vec_i;
     wire            INIT_CLK_IN;

     //AXI RX Interface
        wire      [0:63]      rx_tdata_i;
        wire                 rx_tvalid_i;
        wire      [0:7]       rx_tkeep_i;
        wire                 rx_tlast_i;
     // LocalLink RX Interface
       wire    [0:63]     rx_d_i;
       wire               rx_src_rdy_n_i;
       wire    [0:2]      rx_rem_i;
       wire               rx_sof_n_i;
       wire               rx_eof_n_i;



     // GTX Reference Clock Interface
 wire               INIT_CLK_i /* synthesis syn_keep = 1 */;

     // Error Detection Interface
        wire               rx_soft_err_i;
        wire               rx_hard_err_i;

     // Status
        wire               rx_channel_up_i;
        wire               rx_lane_up_i;


     // System Interface
       wire               user_clk_i;
       wire               sync_clk_i;
       wire               reset2fc_i;
       wire               reset_i;
       wire               gt_rxcdrovrden_i ;
       wire               system_reset_i;
       wire               power_down_i;
       wire    [2:0]      loopback_i ;
       wire               gt_pll_lock_i;
       wire               tx_out_clk_i;
       wire     [0:63]     rx_user_k_tdata_i;
       wire                rx_user_k_tvalid_i;
       wire     [0:55]     int_rx_user_k_data_i;
       wire    [0:63]     rx_user_k_data_i;
       wire               rx_user_k_src_rdy_n_i;
       wire    [0:3]      rx_user_k_blk_no_i;
     //Frame check signals
       (* KEEP = "TRUE" *) (* mark_debug = "true" *)    wire    [0:7]      data_err_count_o;
       wire                  data_err_init_clk_i;
       wire      [0:7]       user_k_err_count_o;
       wire               drp_clk_i = INIT_CLK_i;
       wire    [8:0] drpaddr_in_i;
       wire    [15:0]     drpdi_in_i;
       wire    [15:0]     drpdo_out_i;
       wire               drprdy_out_i;
       wire               drpen_in_i;
       wire               drpwe_in_i;
       wire               link_reset_i;
       wire               sysreset_from_vio_i;
       wire               gtreset_from_vio_i;
       wire               rx_cdrovrden_i;
       wire               gt_reset_i;
       wire               gt_reset_i_tmp;
       wire               gt_reset_i_tmp2;

       wire               sysreset_from_vio_r3;
       wire               sysreset_from_vio_r3_initclkdomain;
       wire               gtreset_from_vio_r3;
       wire               tied_to_ground_i;
       wire               tied_to_vcc_i;
       wire                          pll_not_locked_i;

reg pma_init_from_fsm = 0;
reg pma_init_from_fsm_r1 = 0;
reg lane_up_vio_usrclk_r1 = 0;
reg data_err_count_o_r1  = 0;

(* mark_debug = "TRUE" *)    reg rx_tvalid_r = 1'd0;

(* mark_debug = "TRUE" *) reg [19:0] usr_clk_counter = 0;
(* mark_debug = "TRUE" *) wire usr_clk_count_done;

    wire reset2FrameCheck;

 //*********************************Main Body of Code**********************************

    assign reset2FrameCheck = reset_i | !rx_channel_up_i;


     always @(posedge user_clk_i)
         if (reset2FrameCheck)
             rx_tvalid_r <=  `DLY 1'b0;
         else if (rx_tvalid_i)
            rx_tvalid_r <=  `DLY 1'b1;
         else
            rx_tvalid_r <=  `DLY rx_tvalid_r;


  always @(posedge user_clk_i)
      if (reset2FrameCheck)
          usr_clk_counter <=  `DLY 'd0;
      else if (usr_clk_counter >= USR_CLK_PCOUNT)
          usr_clk_counter <=  `DLY USR_CLK_PCOUNT;
      else
          usr_clk_counter <=  `DLY usr_clk_counter + 1'b1;


  assign usr_clk_count_done = (usr_clk_counter >= USR_CLK_PCOUNT)? 1'b1:1'b0;

  reg usr_clk_count_done_r;
    reg usr_clk_count_done_r2;

  always @(posedge user_clk_i)
      usr_clk_count_done_r <=  `DLY usr_clk_count_done;

  always @(posedge user_clk_i)
      usr_clk_count_done_r2 <=  `DLY usr_clk_count_done_r;




     //--- Instance of GT differential buffer ---------//


     //____________________________Register User I/O___________________________________

     // Register User Outputs from core.
     always @(posedge user_clk_i)
     begin
        RX_HARD_ERR     <=  rx_hard_err_i;
        RX_SOFT_ERR     <=  rx_soft_err_i;
        RX_LANE_UP      <=  rx_lane_up_i;
        RX_CHANNEL_UP   <=  rx_channel_up_i;
        DATA_ERR_COUNT  <=  data_err_count_o;
        USER_K_ERR      <=  user_k_err_count_o;
        USER_K_DATA     <=  rx_user_k_tdata_i;
        USER_K_VALID    <=  rx_user_k_tvalid_i;
     end

    assign USER_CLK = user_clk_i;
    assign RX_TDATA = rx_tdata_i;
    assign RX_TVALID = rx_tvalid_i;
    assign RX_TKEEP = rx_tkeep_i;
    assign RX_TLAST = rx_tlast_i;

   BUFG drpclk_bufg_i
   (
      .I  (DRP_CLK_IN),
      .O  (DRP_CLK_i)
   );


     // System Interface
     assign  power_down_i      		=   1'b0;
     assign tied_to_ground_i   		=   1'b0;
     assign tied_to_ground_vec_i 	= 281'd0;
     assign tied_to_vcc_i      		=   1'b1;

    // Native DRP Interface
     assign  drpaddr_in_i	=  'h0;
     assign  drpdi_in_i    	=  16'h0;
     assign  drpwe_in_i     =  1'b0;
     assign  drpen_in_i     =  1'b0;



    reg [127:0]	pma_init_stage = 128'h0;
   (* mark_debug = "TRUE" *) (* KEEP = "TRUE" *) reg [23:0]	pma_init_pulse_width_cnt;
    reg pma_init_assertion = 1'b0;
   reg pma_init_assertion_r;
    reg gt_reset_i_delayed_r1;
   (* mark_debug = "TRUE" *)  reg gt_reset_i_delayed_r2;
    wire gt_reset_i_delayed;

     generate
        always @(posedge INIT_CLK_i)
        begin
            pma_init_stage[127:0] <= {pma_init_stage[126:0], gt_reset_i_tmp};
        end

        assign gt_reset_i_delayed = pma_init_stage[127];

        always @(posedge INIT_CLK_i)
        begin
            gt_reset_i_delayed_r1     <=  gt_reset_i_delayed;
            gt_reset_i_delayed_r2     <=  gt_reset_i_delayed_r1;
            pma_init_assertion_r  <= pma_init_assertion;
            if(~gt_reset_i_delayed_r2 & gt_reset_i_delayed_r1 & ~pma_init_assertion & (pma_init_pulse_width_cnt != 24'hFFFFFF))
                pma_init_assertion <= 1'b1;
            else if (pma_init_assertion & pma_init_pulse_width_cnt == 24'hFFFFFF)
                pma_init_assertion <= 1'b0;

            if(pma_init_assertion)
                pma_init_pulse_width_cnt <= pma_init_pulse_width_cnt + 24'h1;
        end

    wire gt_reset_i_eff;


    if(EXAMPLE_SIMULATION)
    assign gt_reset_i_eff = gt_reset_i_delayed;
    else
    assign gt_reset_i_eff = pma_init_assertion ? 1'b1 : gt_reset_i_delayed;


     if(USE_LABTOOLS)
     begin:chip_reset
     assign  gt_reset_i_tmp = PMA_INIT | gtreset_from_vio_r3 | pma_init_from_fsm_r1;
     assign  reset_i  =  RESET | sysreset_from_vio_r3;
     assign  gt_reset_i = gt_reset_i_eff;
     assign  gt_rxcdrovrden_i  =  rx_cdrovrden_i;
     end
     else
     begin:no_chip_reset
     assign  gt_reset_i_tmp = PMA_INIT;
     assign  reset_i  =   RESET | gt_reset_i_tmp2;
     assign  gt_reset_i = gt_reset_i_eff;
     assign  gt_rxcdrovrden_i  =  1'b0;
     assign  loopback_i  =  3'b000;
     end

     if(!USE_LABTOOLS)
     begin
aurora_64b66b_0_rst_sync_exdes   u_rst_sync_gtrsttmpi
     (
       .prmry_in     (gt_reset_i_tmp),
       .scndry_aclk  (user_clk_i),
       .scndry_out   (gt_reset_i_tmp2)
      );
     end

     endgenerate

/*
     //___________________________Module Instantiations_________________________________
generate
 if (USE_CORE_TRAFFIC==1)
 begin : axi_to_ll_core_traffic

     //_____________________________ RX AXI SHIM _______________________________
aurora_64b66b_0_EXAMPLE_AXI_TO_LL #
     (
        .DATA_WIDTH(64),
        .STRB_WIDTH(8),
        .ISUFC(0),
        .REM_WIDTH (3)
     )
     frame_chk_axi_to_ll_data_i
     (
      // AXI4-S input signals
      .AXI4_S_IP_TX_TVALID(rx_tvalid_i),
      .AXI4_S_IP_TX_TREADY(),
      .AXI4_S_IP_TX_TDATA(rx_tdata_i),
      .AXI4_S_IP_TX_TKEEP(rx_tkeep_i),
      .AXI4_S_IP_TX_TLAST(rx_tlast_i),

      // LocalLink output Interface
      .LL_OP_DATA(rx_d_i),
      .LL_OP_SOF_N(rx_sof_n_i),
      .LL_OP_EOF_N(rx_eof_n_i) ,
      .LL_OP_REM(rx_rem_i) ,
      .LL_OP_SRC_RDY_N(rx_src_rdy_n_i),
      .LL_IP_DST_RDY_N(1'b0),

      // System Interface
      .USER_CLK(user_clk_i),
      .RESET(reset2FrameCheck),
      .CHANNEL_UP(rx_channel_up_i)
      );

aurora_64b66b_0_EXAMPLE_AXI_TO_LL #
    (
        .DATA_WIDTH(64),
        .STRB_WIDTH(8),
        .ISUFC(0),
        .REM_WIDTH (3)
    )

    frame_chk_axi_to_ll_user_k_i
    (
      // AXI4-S input signals
      .AXI4_S_IP_TX_TVALID(rx_user_k_tvalid_i),
      .AXI4_S_IP_TX_TREADY(),
      .AXI4_S_IP_TX_TDATA(rx_user_k_tdata_i),
      .AXI4_S_IP_TX_TKEEP(),
      .AXI4_S_IP_TX_TLAST(),

      // LocalLink output Interface
      .LL_OP_DATA(rx_user_k_data_i),
      .LL_OP_SOF_N(rx_user_k_sof_n_i),
      .LL_OP_EOF_N(rx_user_k_eof_n_i),
      .LL_OP_REM(),
      .LL_OP_SRC_RDY_N(rx_user_k_src_rdy_n_i),
      .LL_IP_DST_RDY_N(1'b0),

      // System Interface
      .USER_CLK(user_clk_i),
      .RESET(reset2FrameCheck),
      .CHANNEL_UP(rx_channel_up_i)
     );

    assign rx_user_k_blk_no_i = rx_user_k_data_i[4:7];
    assign int_rx_user_k_data_i = rx_user_k_data_i[8:63];


aurora_64b66b_0_FRAME_CHECK frame_check_i
     (
         // User Interface
         .RX_D(rx_d_i),
         .RX_REM(rx_rem_i),
         .RX_SOF_N(rx_sof_n_i),
         .RX_EOF_N(rx_eof_n_i),
         .RX_SRC_RDY_N(rx_src_rdy_n_i),
         .DATA_ERR_COUNT(data_err_count_o),


         // RX User K Interface
         .RX_USER_K_DATA(int_rx_user_k_data_i),
         .RX_USER_K_SRC_RDY_N(rx_user_k_src_rdy_n_i),
         .RX_USER_K_BLK_NO(rx_user_k_blk_no_i),
         .USER_K_ERR_COUNT(user_k_err_count_o),

         // System Interface
         .CHANNEL_UP(rx_channel_up_i),
         .USER_CLK(user_clk_i),
         .RESET4RX(reset2fc_i),
         .RESET(reset2FrameCheck)
     );

 end //end USE_CORE_TRAFFIC=1 block
 else
 begin: axi_to_ll_no_traffic
     //define traffic generation modules here
 end //end USE_CORE_TRAFFIC=0 block

endgenerate //End generate for USE_CORE_TRAFFIC

*/



    aurora_64b66b_0_support

aurora_64b66b_0_block_i
     (
        // RX AXI4-S Interface
         .m_axi_rx_tdata(rx_tdata_i),
         .m_axi_rx_tlast(rx_tlast_i),
         .m_axi_rx_tkeep(rx_tkeep_i),
         .m_axi_rx_tvalid(rx_tvalid_i),

         // RX User K Interface
         .m_axi_rx_user_k_tdata(rx_user_k_tdata_i),
         .m_axi_rx_user_k_tvalid(rx_user_k_tvalid_i),

         // GTX Serial I/O
         .rxp(RXP),
         .rxn(RXN),

        .gt_refclk1_p (GTXQ0_P),
        .gt_refclk1_n (GTXQ0_N),
        
         // Error Detection Interface
         .rx_hard_err(rx_hard_err_i),
         .rx_soft_err(rx_soft_err_i),

         // Status
         .rx_channel_up(rx_channel_up_i),
         .rx_lane_up(rx_lane_up_i),

         // System Interface
         .user_clk_out	(user_clk_i),
         .init_clk_out	(INIT_CLK_i),

         .reset2fc(reset2fc_i),

         .reset_pb(reset_i),
         .gt_rxcdrovrden_in(gt_rxcdrovrden_i),
         .power_down(power_down_i),
         .pma_init(gt_reset_i),
         .gt_pll_lock(gt_pll_lock_i),
   .drp_clk_in (DRP_CLK_i),// (drp_clk_i),
    //---------------------- GT DRP Ports ----------------------
         .drpaddr_in(drpaddr_in_i),
         .drpdi_in(drpdi_in_i),
         .drpdo_out(drpdo_out_i),
         .drprdy_out(drprdy_out_i),
         .drpen_in(drpen_in_i),
         .drpwe_in(drpwe_in_i),

         .init_clk_p			(INIT_CLK_P),
         .init_clk_n			(INIT_CLK_N),
         .link_reset_out		(link_reset_i),
         .mmcm_not_locked_out		(pll_not_locked_i),





        .sys_reset_out(system_reset_i),
        .tx_out_clk(tx_out_clk_i)
     );



 endmodule
//------------------------------------------------------------------------------
