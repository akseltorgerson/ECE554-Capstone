module cla_multiplier
	#(MULT_WIDTH = 32)
	(
	input signed [31:0] A, B,
	input en,
	output signed [31:0] product
	);
	
	wire signed [MULT_WIDTH-1:0] mult_temp [MULT_WIDTH - 1:0];
	wire signed [MULT_WIDTH-1:0] product_temp [MULT_WIDTH - 1:0];
	wire [MULT_WIDTH-1:0] carry_temp ;
	
	genvar i, j;
	
	generate
		// init
		for(i = 0; i < MULT_WIDTH; i++) begin
			assign mult_temp[i] = A & {32{B[i]}};
		end
		
		assign product_temp[0] = mult_temp[0];
		assign carry_temp[0] = 1'b0;
		assign product[0] = product_temp[0][0];
		
		for(j=1; j < MULT_WIDTH; j++) begin
			cla_32bit cla0(.A(mult_temp[j]), .B({carry_temp[j-1], product_temp[j-1][31-:31]}), .Cin(1'b0), .Sum(product_temp[j]), .Cout(carry_temp[j]), .P(), .G());
			assign product[j] = product_temp[j][0];
		end
	endgenerate
	
	
endmodule