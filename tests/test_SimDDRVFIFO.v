/**
 * ------------------------------------------------------------
 * Copyright (c) All rights reserved
 * SiLab, Institute of Physics, University of Bonn
 * ------------------------------------------------------------
 */

`timescale 1ps / 1ps

//`include "utils/bus_to_ip.v"
//`include "gpio/gpio.v"
//`include "utils/DCM_sim.v"
`include "utils/clock_multiplier.v"
//`include "utils/clock_divider.v"


module tb (
    //input wire          start_veto,
    input wire          BUS_CLK,
    input wire          BUS_RST,
    input wire  [15:0]  BUS_ADD,
    inout wire  [7:0]   BUS_DATA,
    input wire          BUS_RD,
    input wire          BUS_WR
);

    localparam GPIO_BASEADDR = 16'h0000;
    localparam GPIO_HIGHADDR = 16'h000f;

    localparam DDRVFIFO_BASEADDR = 16'h0020;
    localparam DDRVFIFO_HIGHADDR = 16'h002f;

    localparam WAIT_FOR_INIT     = 1;
    localparam NOVETO            = 1;

    localparam NR_OF_RUNS        = 2;
    localparam STOP_AFTER_RUNS   = 1;
    localparam CONF_WAITCYCLES   = 0;
    localparam CONF_SWAPCHANNELS = 0;
    localparam CHUNKSIZE         = 0;

    localparam CONF_BURSTLENGTH_IN_BYTES = 512;
    localparam CONF_BUSWIDTH_IN_BYTES    = 4;

    localparam BURSTLENGTH          = CONF_BURSTLENGTH_IN_BYTES/CONF_BUSWIDTH_IN_BYTES;

    localparam WRITEDEPTH           = 1*(BURSTLENGTH);
    localparam READDEPTH            = 1*(BURSTLENGTH);
    localparam MEMDEPTH_IN_BYTES    = 32*1024*1024;
    localparam CONF_READ_TIMEOUT    = READDEPTH *4;

    localparam DEBUG_SUPPRESS_TLAST = 1;



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

    wire [1:0] ext_vfifo_mm2s_channel_full = 2'b00;
    wire [1:0] ext_vfifo_s2mm_channel_full;
    wire [1:0] ext_vfifo_mm2s_channel_empty;
    wire [1:0] ext_vfifo_idle;
    wire vfifo_mm2s_rresp_err_intr;
    wire vfifo_s2mm_bresp_err_intr;
    wire vfifo_s2mm_overrun_err_intr;

    assign vfifo_data_out_valid = ext_m_axis_tvalid;
    assign vfifo_data_out = ext_s_axis_tdata;

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

    wire vfifo_empty, vfifo_full;
    assign vfifo_empty = (ext_vfifo_mm2s_channel_empty == 2'b11) ? 1'b1 : 1'b0;
    assign vfifo_full  = (ext_vfifo_s2mm_channel_full  != 2'b00) ? 1'b1 : 1'b0;


    // DEBUGGING
    wire [31:0] data_ch0;
    wire [31:0] data_ch1;
    assign data_ch0 = (ext_m_axis_tdest == 1'b0) ? ext_m_axis_tdata : 32'hzzzzzzzz;
    assign data_ch1 = (ext_m_axis_tdest == 1'b1) ? ext_m_axis_tdata : 32'hzzzzzzzz;


	//DDR3 Interface
    wire [14:0] ddr3_addr;   // output [14:0]	ddr3_addr
    wire [2:0] ddr3_ba;      // output [2:0]	ddr3_ba
    wire ddr3_cas_n;         // output			ddr3_cas_n
    wire [0:0] ddr3_ck_n;    // output [0:0]	ddr3_ck_n
    wire [0:0] ddr3_ck_p;    // output [0:0]	ddr3_ck_p
    wire [0:0] ddr3_cke;     // output [0:0]	ddr3_cke
    wire ddr3_ras_n;         // output			ddr3_ras_n
    wire ddr3_reset_n;       // output			ddr3_reset_n
    wire ddr3_we_n;          // output			ddr3_we_n
    wire [7:0] ddr3_dq;      // inout [7:0]		ddr3_dq
    wire [0:0] ddr3_dqs_n;   // inout [0:0]		ddr3_dqs_n
    wire [0:0] ddr3_dqs_p;   // inout [0:0]		ddr3_dqs_p
	wire [0:0] ddr3_cs_n;    // output [0:0]	ddr3_cs_n
    wire [0:0] ddr3_dm;      // output [0:0]	ddr3_dm
    wire [0:0] ddr3_odt;     // output [0:0]	ddr3_odt
    wire init_calib_complete;// output			init_calib_complete


    //VFIFO interface
    wire        VFIFO_EMPTY;
    wire        VFIFO_FULL;
    wire [31:0] VFIFO_DATA_OUT;
    wire [31:0] VFIFO_DATA_IN;
    wire        VFIFO_READ;
    wire        VFIFO_WRITE;
	wire 		VFIFO_TLAST;

    wire [23:0] IO;
	assign IO[23]		= 1'b0;
	assign IO[22]		= 1'b0;
    assign IO[21]       = VFIFO_EMPTY;
    assign IO[20]       = VFIFO_FULL;


	//assign ... 		= IO[19];
	assign VFIFO_TLAST	= IO[18];
    assign VFIFO_WRITE  = IO[17];
    assign VFIFO_READ   = IO[16];

    assign IO[15:8]    	= VFIFO_DATA_OUT[7:0];
    assign VFIFO_DATA_IN= {IO[7:0], IO[7:0], IO[7:0], IO[7:0]};


	// DDR CLOCK
	wire DDR_CLK_P, DDR_CLK_N;
    reg sys_clk_i;


    //RESET period
    reg VFIFO_RESET = 1'b1;
    parameter RESET_PERIOD = 5e6;


	clock_multiplier #( .MULTIPLIER(2) ) i_clock_multiplier_two(.CLK(BUS_CLK),.CLOCK(sys_clk_i));
    assign DDR_CLK_P = sys_clk_i;
    assign DDR_CLK_N = ~sys_clk_i;



   //Main FSM
    localparam state_idle = 0, state_wr = 1, state_wr_wait = 2, state_rd = 3, state_rd_wait = 4;
    reg [2:0] state = state_idle;

    always @(posedge BUS_CLK)
        if (VFIFO_RESET)
            state <= state_idle;
        else begin
            int_s_axis_tlast <= 1'b0;
            int_m_axis_tlast_delay <= ext_m_axis_tlast;
            int_s_axis_tlast_delay <= int_s_axis_tlast;
            int_s_axis_tvalid_delay <= int_s_axis_tvalid;
            int_burst_strobe <= ( wr_word_cnt_temp[6:0] == BURSTLENGTH-3 );

            case (state)
                state_idle: begin
                    if (init_calib_complete) //((!WAIT_FOR_INIT || init_calib_complete) && (!start_veto || NOVETO))      //wait for ddr3 init complete
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


    gpio
    #(
        .BASEADDR(GPIO_BASEADDR),
        .HIGHADDR(GPIO_HIGHADDR),
        .IO_WIDTH(24),
        .IO_DIRECTION(24'h0f00ff),
        .IO_TRI(24'h000000)
    ) i_gpio
    (
        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),
        .IO(IO)
    );


    ddrvfifo
    #(
        .BASEADDR(DDRVFIFO_BASEADDR),
        .HIGHADDR(DDRVFIFO_HIGHADDR)
    ) i_ddrvfifo
    (
		.DDR_CLK_P(DDR_CLK_P),
		.DDR_CLK_N(DDR_CLK_N),
        .sys_clk_i(sys_clk_i),

        .BUS_CLK(BUS_CLK),
        .BUS_RST(BUS_RST),
        .BUS_ADD(BUS_ADD),
        .BUS_DATA(BUS_DATA),
        .BUS_RD(BUS_RD),
        .BUS_WR(BUS_WR),

        .EMPTY(VFIFO_EMPTY),
        .FULL(VFIFO_FULL),
        .DATA_OUT(VFIFO_DATA_OUT),
        .DATA_IN(VFIFO_DATA_IN),
        .READ(VFIFO_READ),
        .WRITE(VFIFO_WRITE),
        .TLAST(VFIFO_TLAST),

        .VFIFO_RESET(VFIFO_RESET),

        .vfifo_mm2s_channel_full(ext_vfifo_mm2s_channel_full),
        .vfifo_s2mm_channel_full(ext_vfifo_s2mm_channel_full),
        .vfifo_mm2s_channel_empty(ext_vfifo_mm2s_channel_empty),
        .vfifo_idle(ext_vfifo_idle),

        .s_axis_tvalid(ext_s_axis_tvalid),
        .s_axis_tready(ext_s_axis_tready),
        .s_axis_tdata(ext_s_axis_tdata),
        .s_axis_tlast(ext_s_axis_tlast),
        .s_axis_tdest(ext_s_axis_tdest),

        .m_axis_tvalid(ext_m_axis_tvalid),
        .m_axis_tready(ext_m_axis_tready),
        .m_axis_tdata(ext_m_axis_tdata),
        .m_axis_tlast(ext_m_axis_tlast),
        .m_axis_tdest(ext_m_axis_tdest),

        .vfifo_mm2s_rresp_err_intr(vfifo_mm2s_rresp_err_intr),
        .vfifo_s2mm_bresp_err_intr(vfifo_s2mm_bresp_err_intr),
        .vfifo_s2mm_overrun_err_intr(vfifo_s2mm_overrun_err_intr),

		// Memory interface ports
		.ddr3_addr(ddr3_addr),
		.ddr3_ba(ddr3_ba),
		.ddr3_cas_n(ddr3_cas_n),
		.ddr3_ck_n(ddr3_ck_n),
		.ddr3_ck_p(ddr3_ck_p),
		.ddr3_cke(ddr3_cke),
		.ddr3_ras_n(ddr3_ras_n),
		.ddr3_reset_n(ddr3_reset_n),
		.ddr3_we_n(ddr3_we_n),
		.ddr3_dq(ddr3_dq),
		.ddr3_dqs_n(ddr3_dqs_n),
		.ddr3_dqs_p(ddr3_dqs_p),
		.init_calib_complete(init_calib_complete),
		.ddr3_cs_n(ddr3_cs_n),
		.ddr3_dm(ddr3_dm),
		.ddr3_odt(ddr3_odt)
    );



	/* Version:  1.72
	*  Model:  BUS Functional
	*  Dependencies:  ddr3_model_parameters.vh
	*  Description:  Micron SDRAM DDR3 (Double Data Rate 3)
	*/
	ddr3_model
	#(
	) i_ddr3_model
	(
		.rst_n	(ddr3_reset_n),
		.ck		(ddr3_ck_p),
		.ck_n	(ddr3_ck_n),
		.cke	(ddr3_cke),
		.cs_n	(ddr3_cs_n),
		.ras_n	(ddr3_ras_n),
		.cas_n	(ddr3_cas_n),
		.we_n	(ddr3_we_n),
		.dm_tdqs(ddr3_dm),
		.ba		(ddr3_ba),
		.addr	(ddr3_addr),
		.dq		(ddr3_dq),
		.dqs	(ddr3_dqs_p),
		.dqs_n	(ddr3_dqs_n),
		.tdqs_n(),
		.odt	(ddr3_odt)
	);

/*    //End-condition of the test
    always begin
        //wait (STOP_AFTER_RUNS && runs == NR_OF_RUNS)
        #10e9   //stop after 20 ms
        $display("Test Done");
        $finish;
    end
*/
    initial  begin
        $display("\t\ttime,\ts_tvalid,\ts_tdata,\ts_tlast,\ts_tdest");
        $monitor("%d,\t%b,\t%h,\t%b,\t%d",$time, ext_s_axis_tvalid,ext_s_axis_tdata,ext_s_axis_tlast,ext_s_axis_tdest);
    end

    initial begin
        //$dumpfile("/tmp/ddrvfifo.vcd.gz");
        //$dumpvars(0);

        $display("Reset");
        //#100e3;    // 100 ns
        VFIFO_RESET = 1'b1;
        #(RESET_PERIOD);
        VFIFO_RESET = 1'b0;
        $display("Reset Done");
        #1000e6   //stop after 2 ms
        $display("Test Done");
        $finish;
    end

endmodule
