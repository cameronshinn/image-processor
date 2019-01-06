module grayscale_mult (

	input [3:0] rIn, gIn, bIn,
	output wire [9:0] rOut, gOut, bOut
	
);

	assign rOut = rIn * {4'b0000, 6'b001101}; // wait after add to divide
	assign gOut = gIn * {4'b0000, 6'b101101};
	assign bOut = bIn * {4'b0000, 6'b000100};

endmodule
