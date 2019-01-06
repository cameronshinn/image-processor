module tb_comb_ckt_generator;

reg vga_clk;
reg [9:0] SW;
reg [9:0] col;
reg [8:0] row;
wire [3:0] red, green, blue;

reg v_sync;
reg [1:0] KEY;
wire [9:0]  LEDR;
wire [7:0]  HEX0;
wire [7:0]  HEX1;
wire [7:0]  HEX2;
wire [7:0]  HEX3;
wire [7:0]  HEX4;
wire [7:0]  HEX5;
 
	
comb_ckt_generator inst_1 (.vga_clk(vga_clk), .col(col), .row(row), .red(red), .green(green), .blue(blue), .v_sync(v_sync), .KEY(KEY), .SW(SW), .LEDR(LEDR), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));

initial begin

	vga_clk = 1'b0;

	col = 10'b0000001000;
	row = 9'b000001000;
	
	SW = 10'b0000000000;
	
	repeat (64) begin
	
		repeat (16) begin
		
			vga_clk = 1'b1;
			
			v_sync = 1'b1;
			
			#10;
			
			vga_clk = 1'b0;
			
			v_sync = 1'b0;
			
			#10;
		
		end
	
		SW = SW + 5'b10000;
	
	end
	
	col = 10'b0000010000;
	row = 9'b000010000;
	
	SW = 10'b0000000000;
	
	repeat (64) begin
	
		repeat (16) begin
		
			vga_clk = 1'b1;
			
			v_sync = 1'b1;
			
			#10;
			
			vga_clk = 1'b0;
			
			v_sync = 1'b0;
			
			#10;
		
		end
	
		SW = SW + 5'b10000;
	
	end
	
	col = 10'b0000100000;
	row = 9'b0000100000;
	
	SW = 10'b0000000000;
	
	repeat (64) begin
	
		repeat (16) begin
		
			vga_clk = 1'b1;
			
			v_sync = 1'b1;
			
			#10;
			
			vga_clk = 1'b0;
			
			v_sync = 1'b0;
			
			#10;
		
		end
	
		SW = SW + 5'b10000;
	
	end
	
	col = 10'b0001000000;
	row = 9'b0000100000;
	
	SW = 10'b0000000000;
	
	repeat (64) begin
	
		repeat (16) begin
		
			vga_clk = 1'b1;
			
			v_sync = 1'b1;
			
			#10;
			
			vga_clk = 1'b0;
			
			v_sync = 1'b0;
			
			#10;
		
		end
	
		SW = SW + 5'b10000;
	
	end

end

endmodule
	