module butterfly_unit
	(
	input signed [31:0] real_A, imag_A, real_B, imag_B, twiddle_factor,
	output signed [31:0] real_A_out, imag_A_out, real_B_out, imag_B_out
	);
	
	/////////////////////////
	////// Intermediates ////
	/////////////////////////
	
	wire [31:0] mult_B_real, mult_B_imag;
	
	/*********
	* modules
	**********/
	
	cla_32bit crA(.A(real_A), .B(mult_B_real), .Cin(1'b0), .Sum(real_A_out), .Cout(), .P(), .G());
	cla_32bit ciA(.A(imag_A), .B(mult_B_imag), .Cin(1'b0), .Sum(imag_A_out), .Cout(), .P(), .G());
	cla_32bit crB(.A(real_A), .B(~(mult_B_real)), .Cin(1'b1), .Sum(real_B_out), .Cout(), .P(), .G());
	cla_32bit ciB(.A(imag_A), .B(~(mult_B_imag)), .Cin(1'b1), .Sum(imag_B_out), .Cout(), .P(), .G());
	
	cla_multiplier mult_R(.A(twiddle_factor), .B(real_B), .en(1'b1), .product(mult_B_real));
	cla_multiplier mult_I(.A(twiddle_factor), .B(imag_B), .en(1'b1), .product(mult_B_imag));
	
endmodule