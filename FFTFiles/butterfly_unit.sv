module butterfly_unit
	(
	input signed [31:0] real_A, imag_A, real_B, imag_B, twiddle_real, twiddle_imag,
	output signed [31:0] real_A_out, imag_A_out, real_B_out, imag_B_out
	);
	
	/////////////////////////
	////// Intermediates ////
	/////////////////////////
	
	wire signed [31:0] mult_B_real, mult_B_imag, mult_B_real_left, mult_B_real_right, mult_B_imag_left, mult_B_imag_right;
	wire signed [63:0] mult_B_real_left_product, mult_B_real_right_product, mult_B_imag_left_product, mult_B_imag_right_product;
	
	/*********
	* modules
	**********/
	
	// The "Butterfly" //
	cla_32bit crA(.A(real_A), .B(mult_B_real), .Cin(1'b0), .Sum(real_A_out), .Cout(), .P(), .G());
	cla_32bit ciA(.A(imag_A), .B(mult_B_imag), .Cin(1'b0), .Sum(imag_A_out), .Cout(), .P(), .G());
	cla_32bit crB(.A(real_A), .B(~(mult_B_real)), .Cin(1'b1), .Sum(real_B_out), .Cout(), .P(), .G());
	cla_32bit ciB(.A(imag_A), .B(~(mult_B_imag)), .Cin(1'b1), .Sum(imag_B_out), .Cout(), .P(), .G());
	
	////// MULTIPLICATION ///////////////////
	// 	 B   *  twiddle  =       MULT B
	// (x+yi) * (u+vi)   = (xu-yv) + (xv+yu)i
	//cla_multiplier mult_R_1(.A(real_B), .B(twiddle_real), .en(1'b1), .product(mult_B_real_left));
	//cla_multiplier mult_R_2(.A(imag_B), .B(twiddle_imag), .en(1'b1), .product(mult_B_real_right));
	//cla_multiplier mult_I_1(.A(real_B), .B(twiddle_imag), .en(1'b1), .product(mult_B_imag_left));
	//cla_multiplier mult_I_2(.A(imag_B), .B(twiddle_real), .en(1'b1), .product(mult_B_imag_right));

	// intermediate product values
	assign mult_B_real_left_product = real_B * twiddle_real;
	assign mult_B_real_right_product = imag_B * twiddle_imag;
	assign mult_B_imag_left_product = real_B * twiddle_imag;
	assign mult_B_imag_right_product = imag_B * twiddle_real;

	// assign actual values
	assign mult_B_real_left = mult_B_real_left_product[63:32];
	assign mult_B_real_right = mult_B_real_right_product[63:32];
	assign mult_B_imag_left = mult_B_imag_left_product[63:32];
	assign mult_B_imag_right = mult_B_imag_right_product[63:32];

	cla_32bit mult_R(.A(mult_B_real_left), .B(~(mult_B_real_right)), .Cin(1'b1), .Sum(mult_B_real), .Cout(), .P(), .G());
	cla_32bit mult_I(.A(mult_B_imag_left), .B(mult_B_imag_right), .Cin(1'b0), .Sum(mult_B_imag), .Cout(), .P(), .G());
	
endmodule