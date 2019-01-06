module color_select (

	input [2:0] colorRemove,
	input [3:0] rIn,
	input [3:0] gIn,
	input [3:0] bIn,
	output reg [3:0] rOut,
	output reg [3:0] gOut,
	output reg [3:0] bOut

);

/*assign rOut = rIn * ~colorRemove[2];
assign gOut = gIn * ~colorRemove[1];
assign bOut = bIn * ~colorRemove[0];*/

always @(*) begin

	if (colorRemove[2] == 1'b1) begin
	
		rOut = 4'b0000;
	
	end
	
	else begin
	
		rOut = rIn;
		
	end
	
	if (colorRemove[1] == 1'b1) begin
	
		gOut = 4'b0000;
	
	end
	
	else begin
	
		gOut = gIn;
	
	end
	
	if (colorRemove[0] == 1'b1) begin
	
		bOut = 4'b0000;
	
	end
	
	else begin
	
		bOut = bIn;
	
	end

end

endmodule
