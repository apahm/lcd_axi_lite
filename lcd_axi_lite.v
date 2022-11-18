`timescale 1 ns / 1 ps

module lcd_control_axi_lite #(
	parameter integer AXI_DATA_WIDTH	= 32,
	parameter integer AXI_ADDR_WIDTH	= 6
)
(
	input wire  S_AXI_ACLK,
	input wire  S_AXI_ARESETN,
	input wire [AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
	input wire [2 : 0] S_AXI_AWPROT,
	input wire  S_AXI_AWVALID,
	output wire  S_AXI_AWREADY,
	input wire [AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
	input wire [(AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input wire  S_AXI_WVALID,
	output wire  S_AXI_WREADY,
	output wire [1 : 0] S_AXI_BRESP,
	output wire  S_AXI_BVALID,
	input wire  S_AXI_BREADY,
	input wire [AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
	input wire [2 : 0] S_AXI_ARPROT,
	input wire  S_AXI_ARVALID,
	output wire  S_AXI_ARREADY,
	output wire [AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
	output wire [1 : 0] S_AXI_RRESP,
	output wire  S_AXI_RVALID,
	input wire  S_AXI_RREADY,

	input wire lcd_ready,
	output wire lcd_valid,
	output wire [31:0] lcd_data_str_0_0,
	output wire [31:0] lcd_data_str_0_1,
	output wire [31:0] lcd_data_str_0_2,
	output wire [31:0] lcd_data_str_0_3,
	output wire [31:0] lcd_data_str_1_0,
	output wire [31:0] lcd_data_str_1_1,
	output wire [31:0] lcd_data_str_1_2,
	output wire [31:0] lcd_data_str_1_3
);

	reg [AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	localparam integer ADDR_LSB = (AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 3;
	
	reg [AXI_DATA_WIDTH-1:0]	data_str_0_0;
	reg [AXI_DATA_WIDTH-1:0]	data_str_0_1;
	reg [AXI_DATA_WIDTH-1:0]	data_str_0_2;
	reg [AXI_DATA_WIDTH-1:0]	data_str_0_3;
	reg [AXI_DATA_WIDTH-1:0]	data_str_1_0;
	reg [AXI_DATA_WIDTH-1:0]	data_str_1_1;
	reg [AXI_DATA_WIDTH-1:0]	data_str_1_2;
	reg [AXI_DATA_WIDTH-1:0]	data_str_1_3;
	reg [AXI_DATA_WIDTH-1:0]	valid_lcd_control;
	wire	 						slv_reg_rden;
	wire	 						slv_reg_wren;
	reg [AXI_DATA_WIDTH-1:0]	reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	assign lcd_valid = valid_lcd_control[0];
	assign lcd_data_str_0_0 = data_str_0_0;
	assign lcd_data_str_0_1 = data_str_0_1;
	assign lcd_data_str_0_2 = data_str_0_2;
	assign lcd_data_str_0_3 = data_str_0_3;
	assign lcd_data_str_1_0 = data_str_1_0;
	assign lcd_data_str_1_1 = data_str_1_1;
	assign lcd_data_str_1_2 = data_str_1_2;
	assign lcd_data_str_1_3 = data_str_1_3;

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          axi_awready <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (S_AXI_BREADY && axi_bvalid)
	            begin
	              aw_en <= 1'b1;
	              axi_awready <= 1'b0;
	            end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
	        begin
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
	        begin
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	assign slv_reg_wren = axi_wready && S_AXI_WVALID 
						&& axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      data_str_0_0 <= 32'b0;
	      data_str_0_1 <= 32'b0;
	      data_str_0_2 <= 32'b0;
	      data_str_0_3 <= 32'b0;
	      data_str_1_0 <= 32'b0;
	      data_str_1_1 <= 32'b0;
	      data_str_1_2 <= 32'b0;
	      data_str_1_3 <= 32'b0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          4'h0:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_0_0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h1:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_0_1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h2:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_0_2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h3:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_0_3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h4:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_1_0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h5:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_1_1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h6:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_1_2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h7:
	            for ( byte_index = 0; 
	            	byte_index <= (AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                data_str_1_3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end   
	          default : begin
	                      data_str_0_0 <= data_str_0_0;
	                      data_str_0_1 <= data_str_0_1;
	                      data_str_0_2 <= data_str_0_2;
	                      data_str_0_3 <= data_str_0_3;
	                      data_str_1_0 <= data_str_1_0;
	                      data_str_1_1 <= data_str_1_1;
	                      data_str_1_2 <= data_str_1_2;
	                      data_str_1_3 <= data_str_1_3;
	                    end
	        endcase
	      end
	  end
	end    

	always @( posedge S_AXI_ACLK ) begin
		if( S_AXI_ARESETN == 1'b0 ) begin
			valid_lcd_control <= 32'b0;
		end else if(slv_reg_wren) begin
			if (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 4'h9) begin
				valid_lcd_control <= S_AXI_WDATA[0];
			end
		end else
			valid_lcd_control <= 32'b0;
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	        end                   
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          axi_arready <= 1'b1;
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; 
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

	always @(*)
	begin
	    case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	    	4'h0   : reg_data_out <= data_str_0_0;
	    	4'h1   : reg_data_out <= data_str_0_1;
	    	4'h2   : reg_data_out <= data_str_0_2;
	    	4'h3   : reg_data_out <= data_str_0_3;
	    	4'h4   : reg_data_out <= data_str_1_0;
	    	4'h5   : reg_data_out <= data_str_1_1;
	    	4'h6   : reg_data_out <= data_str_1_2;
	    	4'h7   : reg_data_out <= data_str_1_3;
	    	4'h8   : reg_data_out <= {31'b0, lcd_ready};
	    	4'h9   : reg_data_out <= valid_lcd_control;
	    	default : reg_data_out <= 0;
	    endcase
	end

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;    
	        end   
	    end
	end    

endmodule
