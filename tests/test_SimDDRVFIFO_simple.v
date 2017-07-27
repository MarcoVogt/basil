`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/06/2017 02:04:16 PM
// Design Name:
// Module Name: top_tb
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


module simplified_tb(
    input wire start_veto,
    output wire ddr_init_done,
    output wire vfifo_data_out_valid,
    output wire vfifo_empty,
    output wire vfifo_full,
    output wire [31:0] vfifo_data_out
    );

    localparam WAIT_FOR_INIT     = 1;
    localparam NOVETO = 1;

    localparam NR_OF_RUNS        = 2;
    localparam STOP_AFTER_RUNS   = 1;
    localparam CONF_WAITCYCLES   = 0;
    localparam CONF_SWAPCHANNELS = 0;
    localparam CHUNKSIZE         = 0;

    localparam CONF_BURSTLENGTH_IN_BYTES = 512;
    localparam CONF_BUSWIDTH_IN_BYTES    = 4;

    localparam BURSTLENGTH          = CONF_BURSTLENGTH_IN_BYTES/CONF_BUSWIDTH_IN_BYTES;

    localparam WRITEDEPTH           = 32*(BURSTLENGTH);
    localparam READDEPTH            = 32*(BURSTLENGTH);
    localparam MEMDEPTH             = 32*1024*1024;
    localparam CONF_READ_TIMEOUT    = READDEPTH;

    localparam DEBUG_SUPPRESS_TLAST = 1;


    //general clock 200 MHz
    parameter PERIOD = 5.0;

    //DDR controller clock 200 MHz
    parameter PERIOD_DDR = 5.0;

    //RESET period
    parameter RESET_PERIOD = 5000.0;

    reg sys_clk_i, clk, clk_tb, reset;
    wire aresetn;

    assign aresetn = ~reset;
    assign aclk = clk;
    assign sys_clk_p = sys_clk_i;
    assign sys_clk_n = ~sys_clk_i;


    //external signals
    wire ext_s_axis_tvalid;
    wire ext_s_axis_tready;
    wire ext_s_axis_tlast;
    wire [31:0] ext_s_axis_tdata;
    wire ext_s_axis_tdest;

    wire ext_m_axis_tvalid;
    wire ext_m_axis_tready;
    wire ext_m_axis_tlast;
    wire [31:0] ext_m_axis_tdata;
    wire ext_m_axis_tdest;

    wire [1:0] ext_vfifo_mm2s_channel_full;
    wire [1:0] ext_vfifo_s2mm_channel_full;
    wire [1:0] ext_vfifo_mm2s_channel_empty;
    wire [1:0] ext_vfifo_idle;
    wire vfifo_mm2s_rresp_err_intr;
    wire vfifo_s2mm_bresp_err_intr;
    wire vfifo_s2mm_overrun_err_intr;

    assign vfifo_data_out_valid = ext_m_axis_tvalid;
    assign vfifo_data_out = ext_s_axis_tdata;


    //DDR3 SIGNALS
    wire [14:0] ddr3_addr_sdram;    // output [14:0]    ddr3_addr
    wire [2:0]  ddr3_ba_sdram;      // output [2:0]        ddr3_ba
    wire        ddr3_cas_n_sdram;   // output            ddr3_cas_n
    wire [0:0]  ddr3_ck_n_sdram;    // output [0:0]        ddr3_ck_n
    wire [0:0]  ddr3_ck_p_sdram;    // output [0:0]        ddr3_ck_p
    wire [0:0]  ddr3_cke_sdram;     // output [0:0]        ddr3_cke
    wire        ddr3_ras_n_sdram;   // output            ddr3_ras_n
    wire        ddr3_reset_n;       // output            ddr3_reset_n
    wire        ddr3_we_n_sdram;    // output            ddr3_we_n
    wire [7:0]  ddr3_dq_sdram;      // inout [7:0]        ddr3_dq
    wire [0:0]  ddr3_dqs_n_sdram;   // inout [0:0]        ddr3_dqs_n
    wire [0:0]  ddr3_dqs_p_sdram;   // inout [0:0]        ddr3_dqs_p
    wire [0:0]  ddr3_cs_n_sdram;    // output [0:0]        ddr3_cs_n
    wire [0:0]  ddr3_dm_sdram;      // output [0:0]        ddr3_dm
    wire [0:0]  ddr3_odt_sdram;     // output [0:0]        ddr3_odt


     //Generic FIFO style interface
    wire read;
    wire write;
    wire [31:0] data_in;
    wire [31:0] data_out;
    wire empty;
    wire full;


    //internal signals
    reg [31:0] data_from_fifo = 32'hzzzzzzzz;
    reg [31:0] data_to_fifo = 32'hzzzzzzzz;
    reg [31:0] int_data_to_fifo = 32'd0;

    reg [31:0] wr_word_cnt = 32'd0;
    reg [11:0] wr_word_cnt_temp = 12'd0;
    reg [7:0]  wr_wait_cnt = 8'd0;
    reg [31:0] wr_timeout = 32'd0;

    reg [31:0] rd_word_cnt = 32'd0;
    reg [7:0]  rd_wait_cnt_temp  = 8'd0;
    reg [7:0]  rd_wait_cnt  = 8'd0;
    reg [31:0] rd_timeout = 32'd0;

    reg int_m_axis_tlast_delay = 1'b0;
    reg int_s_axis_tdest = 1'b0;

    wire init_calib_complete;
    assign ddr_init_done = init_calib_complete;
    reg [7:0] runs = 8'd0;


    //assignment to internal signals
    assign ext_s_axis_tdest = CONF_SWAPCHANNELS ? int_s_axis_tdest : 1'b0;
    assign ext_s_axis_tdata = ext_s_axis_tvalid ? data_to_fifo : 32'hzzzzzzzz;

    reg int_m_axis_tready = 1'b0;
    assign ext_m_axis_tready = int_m_axis_tready;

    reg int_s_axis_tvalid = 1'b0;
    reg int_s_axis_tvalid_delay = 1'b0;
    assign ext_s_axis_tvalid = int_s_axis_tvalid;

    reg int_s_axis_tlast = 1'b0;
    reg int_s_axis_tlast_delay = 1'b0;
    assign ext_s_axis_tlast = int_s_axis_tlast;

    reg int_burst_strobe = 1'b0;
//    assign int_burst_strobe = ( wr_word_cnt_temp[6:0] == BURSTLENGTH-1 ) ? 1'b1 : 1'b0;

//    wire vfifo_empty, vfifo_full;
    assign vfifo_empty = (ext_vfifo_mm2s_channel_empty == 2'b11) ? 1'b1 : 1'b0;
    assign vfifo_full  = (ext_vfifo_s2mm_channel_full  != 2'b00) ? 1'b1 : 1'b0;


// DEBUGGING
    wire [31:0] data_ch0;
    wire [31:0] data_ch1;
    assign data_ch0 = (ext_m_axis_tdest == 1'b0) ? ext_m_axis_tdata : 32'hzzzzzzzz;
    assign data_ch1 = (ext_m_axis_tdest == 1'b1) ? ext_m_axis_tdata : 32'hzzzzzzzz;

    //STARTUP
    initial
    begin
        clk = 1'b0;
        clk_tb = 1'b0;
        sys_clk_i = 1'b1;

        if (WRITEDEPTH > BURSTLENGTH || READDEPTH > BURSTLENGTH) begin
            $display("Check parameters");
            $finish;
        end

        $display("Reset");
        reset = 1'b1;
        #(RESET_PERIOD);
        reset = 1'b0;
        $display("Reset Done");

        if(WAIT_FOR_INIT)
            wait (init_calib_complete);
        $display("Calibration Done");
    end


    //GENERATE CLOCKS
    always
        clk = #(PERIOD/2) ~clk;
    always
        clk_tb = #(PERIOD/2) ~clk_tb;
    always
        sys_clk_i = #(PERIOD_DDR/2) ~sys_clk_i;

    initial  begin
        $display("\t\ttime,\ts_tvalid,\ts_tdata,\ts_tlast,\ts_tdest");
        $monitor("%d,\t%b,\t%h,\t%b,\t%d",$time, ext_s_axis_tvalid,ext_s_axis_tdata,ext_s_axis_tlast,ext_s_axis_tdest);
    end

    //End-condition of the test
    always begin
        wait (STOP_AFTER_RUNS && runs == NR_OF_RUNS)
        $display("Test Done");
        $finish;
    end



    //Main FSM
    localparam state_idle = 0, state_wr = 1, state_wr_wait = 2, state_rd = 3, state_rd_wait = 4;
    reg [2:0] state = state_idle;

    always @(posedge clk_tb)
        if (!aresetn)
            state <= state_idle;
        else begin
            int_s_axis_tlast <= 1'b0;
            int_m_axis_tlast_delay <= ext_m_axis_tlast;
            int_s_axis_tlast_delay <= int_s_axis_tlast;
            int_s_axis_tvalid_delay <= int_s_axis_tvalid;
            int_burst_strobe <= ( wr_word_cnt_temp[6:0] == BURSTLENGTH-3 );

            case (state)
                state_idle: begin
                    if ( (!WAIT_FOR_INIT || init_calib_complete) && (!start_veto || NOVETO) )      //wait for ddr3 init complete
                        state <= state_wr;
                end

                // WRITE (WRITEDEPTH) WORDS INTO FIFO
                state_wr: begin
                    if (wr_word_cnt >= WRITEDEPTH) begin
                        wr_word_cnt <= 32'd0;
                        wr_word_cnt_temp <= 12'd0;
                        wr_timeout <= 32'd0;
                        int_s_axis_tvalid <= 1'b0;
                        data_to_fifo <= 32'hzzzzzzzz;
                        state <= state_rd;
                    end
                    else begin
                        int_s_axis_tvalid <= 1'b1;                   //tell fifo, we have valid data
//maybe put the chunksize stuff in comb part and use strobe signal, just like burst_strobe
                        if (wr_word_cnt >= WRITEDEPTH-1 || (int_burst_strobe || (CHUNKSIZE && wr_word_cnt_temp == CHUNKSIZE-2)) && !DEBUG_SUPPRESS_TLAST )
                            int_s_axis_tlast <= 1'b1;

                        //insert wait cycles
                        if (CONF_WAITCYCLES && wr_wait_cnt==8'd0 && (int_s_axis_tlast || wr_word_cnt_temp >= BURSTLENGTH-1 || (CHUNKSIZE && wr_word_cnt_temp == CHUNKSIZE-1)) ) begin
                            int_s_axis_tvalid <= 1'b0;
                            wr_word_cnt_temp <= 12'd0;
                            state <= state_wr_wait;
                        end
                        else begin
                            wr_wait_cnt <= 8'd0;

                            if (ext_s_axis_tready) begin           //wait for fifo to get ready             && int_s_axis_tvalid
                                int_data_to_fifo <= int_data_to_fifo + 1;
                                wr_word_cnt <= wr_word_cnt + 1;
                                data_to_fifo <= int_data_to_fifo;
                                if (int_s_axis_tvalid )
                                    wr_word_cnt_temp <= wr_word_cnt_temp + 1;
                            end
                            else
                                wr_timeout <= wr_timeout + 1;
                        end

                        //swap channel, if we wrote a full packet
                        if (CONF_SWAPCHANNELS && (int_s_axis_tlast || wr_word_cnt_temp >= BURSTLENGTH || (CHUNKSIZE && wr_word_cnt_temp == CHUNKSIZE-1)) )  begin   //wait a few clock cycles, ater a block has been sent
                            wr_word_cnt_temp <= 12'd0;
                            int_s_axis_tdest <= ~int_s_axis_tdest;
                        end

//                        data_from_fifo <= 32'hzzzzzzzz;
                    end
                end


                state_wr_wait: begin
                    data_to_fifo <= 32'hzzzzzzzz;
                    if (wr_wait_cnt < CONF_WAITCYCLES-1)
                        wr_wait_cnt <= wr_wait_cnt + 1;
                    else begin
                        state <= state_wr;
                    end
                end


                // READ (READDEPTH) WORDS FROM FIFO
                state_rd: begin
                    data_to_fifo <= 32'hzzzzzzzz;
                    if (ext_m_axis_tvalid && int_m_axis_tready)            //wait until fifo has data
                            data_from_fifo <= ext_m_axis_tdata;

                    if (rd_word_cnt >= READDEPTH || rd_timeout >= (CONF_READ_TIMEOUT-1)  ) begin   //vfifo_empty || || ext_m_axis_tlast
                        rd_word_cnt <= 32'd0;
                        rd_timeout <= 32'd0;
                        int_m_axis_tready <= 1'b0;
                        runs <= runs + 1;                   //increment run counter
                        data_from_fifo <= 32'hzzzzzzzz;
//try one last time to get data from other channels
//                        if (!vfifo_empty)
//                        else
                        state <= state_wr;
                    end
                    else begin
                        int_m_axis_tready <= 1'b1;              //accept data from fifo
                        if (ext_m_axis_tvalid && int_m_axis_tready) begin            //wait until fifo has data
                            rd_wait_cnt <= 2'd0;
                            rd_word_cnt <= rd_word_cnt + 1;
                            data_from_fifo <= ext_m_axis_tdata;
                        end
                        else
                            rd_timeout <= rd_timeout + 1;
                    end
                end


                state_rd_wait: begin
                    data_from_fifo <= 32'hzzzzzzzz;
                    if (rd_wait_cnt < CONF_WAITCYCLES-1)
                        rd_wait_cnt <= rd_wait_cnt + 1;
                    else begin
                        state <= state_rd;
                    end
                end

            endcase
        end



    axi_ddrvfifo vfifo_inst0 (
        .aclk(aclk),
        .aresetn(aresetn),

        .sys_clk_p(sys_clk_p),
        .sys_clk_n(sys_clk_n),

        //Generic FIFO style interface
        .read(read),
        .write(write),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full),

        //VFIFO status lines
        .ext_vfifo_mm2s_channel_full(ext_vfifo_mm2s_channel_full),
        .ext_vfifo_s2mm_channel_full(ext_vfifo_s2mm_channel_full),
        .ext_vfifo_mm2s_channel_empty(ext_vfifo_mm2s_channel_empty),
        .ext_vfifo_idle(ext_vfifo_idle),
        .vfifo_mm2s_rresp_err_intr(vfifo_mm2s_rresp_err_intr),      // output wire vfifo_mm2s_rresp_err_intr
        .vfifo_s2mm_bresp_err_intr(vfifo_s2mm_bresp_err_intr),      // output wire vfifo_s2mm_bresp_err_intr
        .vfifo_s2mm_overrun_err_intr(vfifo_s2mm_overrun_err_intr),  // output wire vfifo_s2mm_overrun_err_intr

         //Slave AXI stream ports
        .ext_s_axis_tvalid(ext_s_axis_tvalid),      // input wire s_axis_tvalid
        .ext_s_axis_tready(ext_s_axis_tready),      // output wire s_axis_tready
        .ext_s_axis_tdata(ext_s_axis_tdata),        // input wire [31 : 0] s_axis_tdata
        .ext_s_axis_tlast(ext_s_axis_tlast),        // input wire s_axis_tlast
        .ext_s_axis_tdest(ext_s_axis_tdest),

        //Master AXI stream ports
        .ext_m_axis_tvalid(ext_m_axis_tvalid),      // output wire m_axis_tvalid
        .ext_m_axis_tready(ext_m_axis_tready),      // input wire m_axis_tready
        .ext_m_axis_tdata(ext_m_axis_tdata),        // output wire [31 : 0] m_axis_tdata
        .ext_m_axis_tlast(ext_m_axis_tlast),         // output wire m_axis_tlast
        .ext_m_axis_tdest(ext_m_axis_tdest),

        // Memory interface ports
        .ddr3_addr(ddr3_addr_sdram),    // output [14:0]    ddr3_addr
        .ddr3_ba(ddr3_ba_sdram),        // output [2:0]		ddr3_ba
        .ddr3_cas_n(ddr3_cas_n_sdram),  // output			ddr3_cas_n
        .ddr3_ck_n(ddr3_ck_n_sdram),    // output [0:0]		ddr3_ck_n
        .ddr3_ck_p(ddr3_ck_p_sdram),    // output [0:0]		ddr3_ck_p
        .ddr3_cke(ddr3_cke_sdram),      // output [0:0]		ddr3_cke
        .ddr3_ras_n(ddr3_ras_n_sdram),  // output			ddr3_ras_n
        .ddr3_reset_n(ddr3_reset_n),    // output			ddr3_reset_n
        .ddr3_we_n(ddr3_we_n_sdram),    // output			ddr3_we_n
        .ddr3_dq(ddr3_dq_sdram),        // inout [7:0]		ddr3_dq
        .ddr3_dqs_n(ddr3_dqs_n_sdram),  // inout [0:0]		ddr3_dqs_n
        .ddr3_dqs_p(ddr3_dqs_p_sdram),  // inout [0:0]		ddr3_dqs_p
        .ddr3_cs_n(ddr3_cs_n_sdram),    // output [0:0]		ddr3_cs_n
        .ddr3_dm(ddr3_dm_sdram),        // output [0:0]		ddr3_dm
        .ddr3_odt(ddr3_odt_sdram),      // output [0:0]		ddr3_odt
        .init_calib_complete(init_calib_complete)
    );


    ddr3_model u_comp_ddr3
    (
        .rst_n   (ddr3_reset_n),
        .ck      (ddr3_ck_p_sdram),
        .ck_n    (ddr3_ck_n_sdram),
        .cke     (ddr3_cke_sdram),
        .cs_n    (ddr3_cs_n_sdram),
        .ras_n   (ddr3_ras_n_sdram),
        .cas_n   (ddr3_cas_n_sdram),
        .we_n    (ddr3_we_n_sdram),
        .dm_tdqs (ddr3_dm_sdram),
        .ba      (ddr3_ba_sdram),
        .addr    (ddr3_addr_sdram),
        .dq      (ddr3_dq_sdram),
        .dqs     (ddr3_dqs_p_sdram),
        .dqs_n   (ddr3_dqs_n_sdram),
        .tdqs_n  (),
        .odt     (ddr3_odt_sdram)
    );

endmodule
