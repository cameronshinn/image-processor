module grayscale_add_round (

	input [9:0] rIn, gIn, bIn,
	output wire [3:0] lumaOut

);

	wire [9:0] lumaFloat;

	assign lumaFloat = (rIn + bIn + gIn + 10'b0000100000) / 10'b0001000000;
	assign lumaOut = lumaFloat[3:0];
	
endmodule
