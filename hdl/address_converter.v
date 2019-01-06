module address_converter (

	input [1:0] romN,
	input [8:0] row,
	input [9:0] col,
	input [1:0] magSwitch,
	output wire [11:0] addr,
	output reg addrValid

);

	wire [2:0] mag;
	reg [14:0] tempAddr;
	
	assign mag = {1'b0, magSwitch} + 3'b001;
	
	always @(*) begin
		
		if ({1'b0, row} < 10'b0010000000 * mag && col < 10'b0010000000 * mag) begin // still need to figure out correct bit sizing to prevent calculation overflow
		
			tempAddr = ((row / mag) * 15'b000000010000000) + (col / mag) - ({13'b0000000000000, romN}) * 15'b001000000000000;
			addrValid = 1'b1;
			
		end
		
		else begin
		
			addrValid = 1'b0;
		
		end
		
	end	
		
	assign addr = tempAddr[11:0];
	
endmodule

