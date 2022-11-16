`timescale 1ns/1ps

module tb_lcd();
	
	task delayT_t;
		input [31:0] T;
		input [31:0] N;
		begin
			repeat (N)
			#T;
		end
	endtask
	
	task AXILite_W;
		input [31:0] T;
		input [31:0] ADDR;
		input [31:0] DATA;
		output [31:0] t_axil_awaddr;
		output [31:0] t_axil_awvalid;
		output [31:0] t_axil_wdata;
		output [31:0] t_axil_wvalid;
		output [31:0] t_axil_bready;
		input [31:0] s_axil_awready;
		input [31:0] s_axil_wready;
		input [31:0] s_axil_bvalid;
		begin
			delayT_t(T,2);
			t_axil_awaddr <= ADDR;
			t_axil_awvalid <= 1;
			t_axil_wdata <= DATA;
			t_axil_wvalid <= 1;
			t_axil_bready <= 0;
			wait (s_axil_awready || s_axil_wready);
			if (s_axil_awready && s_axil_wready) begin
				delayT_t(T,1);
				t_axil_awvalid <= 0;
				t_axil_wvalid <= 0;
			end else if (s_axil_awready) begin
				delayT_t(T,1);
				t_axil_awvalid <= 0;
				wait(s_axil_wready);
				delayT_t(T,1);
				t_axil_wvalid <= 0;
			end else if (s_axil_wready) begin
				delayT_t(T,1);
				t_axil_wvalid <= 0;
				wait(s_axil_awready);
				delayT_t(T,1);
				t_axil_awvalid <= 0;
			end
			t_axil_bready <= 1;
			wait(s_axil_bvalid);
			delayT_t(T,1);
			t_axil_bready <= 0;
		end
	endtask

	task AXILite_R;
		input [31:0] T;
		input [31:0] ADDR;
		output [31:0] DATA;
		output [31:0] t_axil_araddr;
		output [31:0] t_axil_arvalid;
		input [31:0] s_axil_arready;
		output [31:0] t_axil_rready;
		input [31:0] s_axil_rvalid;
		input [31:0] s_axil_rdata;
		begin
			delayT_t(T,2);
			t_axil_araddr <= ADDR;
			t_axil_arvalid <= 1;
			wait(s_axil_arready);
			delayT_t(T,1);
			t_axil_arvalid <= 0;
			t_axil_rready <= 1;
			wait(s_axil_rvalid);
			delayT_t(T,1);
			DATA <= s_axil_rdata;
			t_axil_rready <= 0;
		end
	endtask

	reg sys_clk;
	reg sys_rst;

	initial 
		sys_clk = 1'b0;
	always 
		sys_clk = #(2.5) ~sys_clk;

	initial begin
		sys_rst = 1'b1;
	    #20000
	    sys_rst = 1'b0;
	end

	top_lcd
	top_lcd_inst
	(
		.s00_axi_aclk(sys_clk),
		.s00_axi_aresetn(~sys_rst),

		.s00_axi_awaddr(),
		.s00_axi_awprot(),
		.s00_axi_awvalid(),
		.s00_axi_awready(),

		.s00_axi_wdata(),
		.s00_axi_wstrb(),
		.s00_axi_wvalid(),
		.s00_axi_wready(),

		.s00_axi_bresp(),
		.s00_axi_bvalid(),
		.s00_axi_bready(),

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