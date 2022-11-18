`timescale 1ns/1ps

module tb_lcd();
	
	parameter integer AXI_DATA_WIDTH = 32;
	parameter integer AXI_ADDR_WIDTH = 6;
	parameter integer T_SYS_CLK = 5;


	parameter integer ADDR_DATA_STR_0_0 = 0;
	parameter integer ADDR_DATA_STR_0_1 = 4;
	parameter integer ADDR_DATA_STR_0_2 = 8;
	parameter integer ADDR_DATA_STR_0_3 = 12;
	parameter integer ADDR_DATA_STR_1_0 = 16;
	parameter integer ADDR_DATA_STR_1_1 = 20;
	parameter integer ADDR_DATA_STR_1_2 = 24;
	parameter integer ADDR_DATA_STR_1_3 = 28;
	parameter integer ADDR_VALID 		= 36;


	reg [AXI_ADDR_WIDTH - 1:0] 	axil_awaddr;
	reg 						axil_awvalid;
	wire 						axil_awready;
	
	reg [AXI_DATA_WIDTH - 1:0] 	axil_wdata;
	wire 						axil_wready;
	reg 	 					axil_wvalid;
	
	reg 	 					axil_bready;
	wire 						axil_bvalid;

	reg [AXI_ADDR_WIDTH - 1:0] 	axil_araddr;
	reg 						axil_arvalid;
	wire 						axil_arready;
	
	wire [AXI_DATA_WIDTH - 1:0] axil_rdata;
	reg 						axil_rready;
	wire 						axil_rvalid;

	reg [7:0] upper_line [15:0];
	reg [7:0] lower_line [15:0];

	reg sys_clk;
	reg sys_rst;

	initial 
		sys_clk = 1'b0;
	always 
		sys_clk = #(T_SYS_CLK/2) ~sys_clk;

	task delayT_t;
		input [31:0] T;
		input [31:0] N;
		begin
			repeat (N)
			#T;
		end
	endtask
	
	task AXI4_Lite_W;
		input [31:0] T;
		input [31:0] ADDR;
		input [31:0] DATA;
		begin
			delayT_t(T,2);
			axil_awaddr <= ADDR;
			axil_awvalid <= 1;
			axil_wdata <= DATA;
			axil_wvalid <= 1;
			axil_bready <= 0;
			wait (axil_awready || axil_wready);
			if (axil_awready && axil_wready) begin
				delayT_t(T,1);
				axil_awvalid <= 0;
				axil_wvalid <= 0;
			end else if (axil_awready) begin
				delayT_t(T,1);
				axil_awvalid <= 0;
				wait(axil_wready);
				delayT_t(T,1);
				axil_wvalid <= 0;
			end else if (axil_wready) begin
				delayT_t(T,1);
				axil_wvalid <= 0;
				wait(axil_awready);
				delayT_t(T,1);
				axil_awvalid <= 0;
			end
			axil_bready <= 1;
			wait(axil_bvalid);
			delayT_t(T,1);
			axil_bready <= 0;
		end
	endtask

	task AXI4_Lite_R;
		input [31:0] T;
		input [31:0] ADDR;
		output [31:0] DATA;
		begin
			delayT_t(T,2);
			axil_araddr <= ADDR;
			axil_arvalid <= 1;
			wait(axil_arready);
			delayT_t(T,1);
			axil_arvalid <= 0;
			axil_rready <= 1;
			wait(axil_rvalid);
			delayT_t(T,1);
			DATA <= axil_rdata;
			axil_rready <= 0;
		end
	endtask

	initial begin
		upper_line[0] = 8'h46; // F
		upper_line[1] = 8'h69; // i
		upper_line[2] = 8'h72; // r
		upper_line[3] = 8'h6d; // m
		upper_line[4] = 8'h77; // w
		upper_line[5] = 8'h61; // a
		upper_line[6] = 8'h72; // r
		upper_line[7] = 8'h65; // e
		upper_line[8] = 8'h20; // 
		upper_line[9] = 8'h6c; // l
		upper_line[10] = 8'h6f; // o
		upper_line[11] = 8'h61; // a
		upper_line[12] = 8'h64; // d
		upper_line[13] = 8'h65; // e
		upper_line[14] = 8'h64; // d
		upper_line[15] = 8'h21; // !
				
		lower_line[0] = 8'h30; // 0
		lower_line[1] = 8'h31; // 1
		lower_line[2] = 8'h32; // 2
		lower_line[3] = 8'h33; // 3
		lower_line[4] = 8'h34; // 4
		lower_line[5] = 8'h35; // 5
		lower_line[6] = 8'h36; // 6
		lower_line[7] = 8'h37; // 7
		lower_line[8] = 8'h38; // 8
		lower_line[9] = 8'h39; // 9
		lower_line[10] = 8'h61; // a
		lower_line[11] = 8'h62; // b
		lower_line[12] = 8'h63; // c
		lower_line[13] = 8'h64; // d
		lower_line[14] = 8'h65; // e
		lower_line[15] = 8'h66; // f
	end

	initial begin
		axil_awaddr = 32'b0;
		axil_awvalid = 32'b0;
		axil_wdata = 32'b0;
		axil_wvalid = 32'b0;
		axil_bready = 32'b0;
		sys_rst = 1'b1;
	    delayT_t(5, 4000);
	    sys_rst = 1'b0;
		delayT_t(5, 1000);

	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_0_0, {upper_line[0], upper_line[1], upper_line[2], upper_line[3]});
	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_0_1, {upper_line[4], upper_line[5], upper_line[6], upper_line[7]});
	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_0_2, {upper_line[8], upper_line[9], upper_line[10], upper_line[11]});
	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_0_3, {upper_line[12], upper_line[13], 	upper_line[14], upper_line[15]});

	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_1_0, {lower_line[0], lower_line[1], lower_line[2], lower_line[3]});
	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_1_1, {lower_line[4], lower_line[5], lower_line[6], lower_line[7]});
	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_1_2, {lower_line[8], lower_line[9], lower_line[10], lower_line[11]});
	    AXI4_Lite_W(T_SYS_CLK, ADDR_DATA_STR_1_3, {lower_line[12], lower_line[13], lower_line[14], lower_line[15]});

	    AXI4_Lite_W(T_SYS_CLK, ADDR_VALID, 32'h1);
	end

	top_lcd
	top_lcd_inst
	(
		.s00_axi_aclk(sys_clk),
		.s00_axi_aresetn(~sys_rst),

		.s00_axi_awaddr(axil_awaddr),
		.s00_axi_awprot(3'b0),
		.s00_axi_awvalid(axil_awvalid),
		.s00_axi_awready(axil_awready),

		.s00_axi_wdata(axil_wdata),
		.s00_axi_wstrb(4'b1111),
		.s00_axi_wvalid(axil_wvalid),
		.s00_axi_wready(axil_wready),

		.s00_axi_bresp(),
		.s00_axi_bvalid(axil_bvalid),
		.s00_axi_bready(axil_bready),

		.s00_axi_araddr(),
		.s00_axi_arprot(),
		.s00_axi_arvalid(),
		.s00_axi_arready(),

		.s00_axi_rdata(),
		.s00_axi_rresp(),
		.s00_axi_rvalid(),
		.s00_axi_rready(),

		.lcd_data(), 
		// LCD: E   (control bit)	
		.lcd_e(),	
		// LCD: RS  (setup or data)
		.lcd_rs(),	
		// LCD: R/W (read or write)
		.lcd_rw()	
	);

endmodule