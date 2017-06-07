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
 //  aurora_64b66b_0
 //
 //
 //
 //  Description: This is the top level module for Aurora 64B66B design
 //
 //
 ///////////////////////////////////////////////////////////////////////////////

 `timescale 1 ns / 10 ps

   (* core_generation_info = "aurora_64b66b_0,aurora_64b66b_v11_0_1,{c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTXQ0,c_gt_clock_2=None,c_gt_loc_1=1,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=X,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=1.6,c_gt_type=gtx,c_qpll=false,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=80.0,c_simplex=true,c_simplex_mode=RX,c_stream=false,c_ufc=false,c_user_k=true,flow_mode=None,interface_mode=Framing,dataflow_config=RX-only_Simplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
 module aurora_64b66b_0
 (
        // RX AXI4-S Interface
         m_axi_rx_tdata,
         m_axi_rx_tlast,
         m_axi_rx_tkeep,
         m_axi_rx_tvalid,



        // RX User K Interface
         m_axi_rx_user_k_tdata,
         m_axi_rx_user_k_tvalid,


        // GTX Serial I/O
         rxp,
         rxn,

        //GTX Reference Clock Interface
         refclk1_in,
        // Error Detection Interface
         rx_hard_err,
         rx_soft_err,
        // Status
         rx_channel_up,
         rx_lane_up,


        // System Interface
         mmcm_not_locked,
         user_clk,
       reset2fc, 
         reset_pb,
         gt_rxcdrovrden_in,
         power_down,
         pma_init,
         gt_pll_lock,
         drp_clk_in,
//---{
    //---- 7 series GT quad assignment
    gt_qpllclk_quad1_in,
    gt_qpllrefclk_quad1_in,











    //---- 7 series GT quad assignment ends


//---}
        //---------------------- GT DRP Ports ----------------------
         drpaddr_in,
         drpdi_in,
         drpdo_out,
         drprdy_out,
         drpen_in,
         drpwe_in,


         init_clk,
         link_reset_out,
         sys_reset_out,
         tx_out_clk
 );

 `define DLY #1
 // synthesis attribute X_CORE_INFO of aurora_64b66b_0 is "aurora_64b66b_v11_0_1, Coregen v14.3_ip3, Number of lanes = 1, Line rate is double1.6Gbps, Reference Clock is double80.0MHz, Interface is Framing, Flow Control is None, User K and is operating in DUPLEX configuration";

 //***********************************Port Declarations*******************************

     // RX AXI Interface
       output [0:63]     m_axi_rx_tdata; 
       output [0:7]      m_axi_rx_tkeep; 
       output            m_axi_rx_tlast;
       output            m_axi_rx_tvalid;


     // RX User K interface
       output   [0:63]     m_axi_rx_user_k_tdata; 
       output             m_axi_rx_user_k_tvalid;


     // GTX Serial I/O
       input    [0:0] rxp;
       input    [0:0] rxn;

     // GTX Reference Clock Interface
        input              refclk1_in;

     // Error Detection Interface
       output             rx_hard_err;
       output             rx_soft_err;

     // Status
       output             rx_channel_up;
       output      [0:0] rx_lane_up;
     // System Interface
       input              mmcm_not_locked;
       input              user_clk;
       output              reset2fc; 
       input              reset_pb;
       input              gt_rxcdrovrden_in;
       input              power_down;
       input              pma_init;
       input    drp_clk_in;


//---{
    //---- 7 series GT quad assignment
        input                     gt_qpllclk_quad1_in;
        input                     gt_qpllrefclk_quad1_in;
        //---- 7 series GT quad assignment ends


//---}

       output  [15:0]  drpdo_out;
       output          drprdy_out;

    //---------------------- GT DRP Ports ----------------------
       input   [8:0]   drpaddr_in;
       input   [15:0]  drpdi_in;
       input           drpen_in;
       input           drpwe_in;


       input               init_clk;
       output              link_reset_out;
       output              gt_pll_lock;
       output              sys_reset_out;
       output              tx_out_clk;


       wire    [0:63]    tied_to_ground_vec;
       wire              tied_to_ground;



 //*********************************Main Body of Code**********************************


      assign tied_to_ground_vec = 64'd0;
      assign tied_to_ground     = 1'd0;

aurora_64b66b_0_core inst
// this is core instance in the aurora_64b66b.v file
     (
        // RX AXI4-S Interface
         .m_axi_rx_tdata(m_axi_rx_tdata),
         .m_axi_rx_tlast(m_axi_rx_tlast),
         .m_axi_rx_tkeep(m_axi_rx_tkeep),
         .m_axi_rx_tvalid(m_axi_rx_tvalid),



         // RX User K Interface
         .m_axi_rx_user_k_tdata(m_axi_rx_user_k_tdata),
         .m_axi_rx_user_k_tvalid(m_axi_rx_user_k_tvalid),


         // GTX Serial I/O
       .rxp      (rxp[0]),
       .rxn      (rxn[0]),


         //GTX Reference Clock Interface
         .gt_refclk1(refclk1_in),
         .rx_hard_err(rx_hard_err),
         .rx_soft_err(rx_soft_err),


         // Status
         .rx_channel_up(rx_channel_up),
         .rx_lane_up(rx_lane_up[0]),


         // System Interface
         .mmcm_not_locked	(mmcm_not_locked),
         .user_clk		(user_clk),
         .sysreset_to_core      (reset_pb),
         .gt_rxcdrovrden_in     (gt_rxcdrovrden_in),
         .power_down            (power_down),
         .pma_init              (pma_init),
         .gt_pll_lock           (gt_pll_lock),
         .drp_clk_in            (drp_clk_in),
//---{

       .gt_qpllclk_quad1_in       (gt_qpllclk_quad1_in         ),
       .gt_qpllrefclk_quad1_in    (gt_qpllrefclk_quad1_in      ),

//---}
    //---------------------- GT DRP Ports ----------------------
         .drpaddr_in(drpaddr_in),
         .drpdi_in(drpdi_in),
         .drpdo_out(drpdo_out),
         .drprdy_out(drprdy_out),
         .drpen_in(drpen_in),
         .drpwe_in(drpwe_in),



         .init_clk       (init_clk),
         .link_reset_out (link_reset_out),
         .reset2fc(reset2fc),
         .sys_reset_out                            (sys_reset_out),
         .tx_out_clk                               (tx_out_clk)
     );

 endmodule
