module butterfly_unit_tb();
	
	//////// intermediates //////////
	logic [31:0] real_A, imag_A, real_B, imag_B, twiddle_real, twiddle_imag, real_A_out, 
						imag_A_out, real_B_out, imag_B_out, real_A_out_ex, imag_A_out_ex, real_B_out_ex, imag_B_out_ex;
	logic [63:0] real_A_out_ex_product_left, real_A_out_ex_product_right, imag_A_out_ex_product_left, imag_A_out_ex_product_right, 
						real_B_out_ex_product_left, real_B_out_ex_product_right, imag_B_out_ex_product_left, imag_B_out_ex_product_right;
	logic clk;
	
	//////// DUT ///////////
	butterfly_unit iDUT(.*);
	
	
	
	/////// Functions & Tasks /////////
	
	task compare_outputs;
		input [31:0] realAOut, realAout_ex, realBOut, realBOut_ex, 
							imagAOut, imagAOut_ex, imagBOut, imagBOut_ex;
		
		begin
			if(realAOut != realAout_ex) begin
				$display("ERROR: Real Out A: %h not equal to expected: %h", realAOut, realAout_ex);
				$stop();
			end
		
			if(imagAOut != imagAOut_ex) begin
				$display("ERROR: Imag Out A: %h not equal to expected: %h", imagAOut, imagAOut_ex);
				$stop();
			end
		
			if(realBOut != realBOut_ex) begin
				$display("ERROR: Real Out B: %h not equal to expected: %h", realBOut, realBOut_ex);
				$stop();
			end
			
			if(imagBOut != imagBOut_ex) begin
				$display("ERROR: Imag Out B: %h not equal to expected: %h", imagBOut, imagBOut_ex);
				$stop();
			end
		end
	endtask;
	
	/////// Tests //////////
	always #5 clk = ~clk; 

	assign real_A_out_ex_product_left = (real_B * twiddle_real);
	assign real_A_out_ex_product_right = (imag_B * twiddle_imag);
	assign imag_A_out_ex_product_left = (real_B * twiddle_imag);
	assign imag_A_out_ex_product_right = (imag_B * twiddle_real);
	assign real_B_out_ex_product_left = (real_B * twiddle_real);
	assign real_B_out_ex_product_right = (imag_B * twiddle_imag);
	assign imag_B_out_ex_product_left = (real_B * twiddle_imag);
	assign imag_B_out_ex_product_right = (imag_B * twiddle_real);
	
	assign real_A_out_ex = real_A + (real_A_out_ex_product_left[63:32] - real_A_out_ex_product_right[63:32]);
	assign imag_A_out_ex = imag_A + (imag_A_out_ex_product_left[63:32] + imag_A_out_ex_product_right[63:32]);
	assign real_B_out_ex = real_A - (real_B_out_ex_product_left[63:32] - real_B_out_ex_product_right[63:32]);
	assign imag_B_out_ex = imag_A - (imag_B_out_ex_product_left[63:32] + imag_B_out_ex_product_right[63:32]);
	
	initial begin
		
		//
		clk = 0;
		real_A = 32'h00000008;
		imag_A = 32'h00000008;
		real_B = 32'h00000008;
		imag_B = 32'h00000008;
		twiddle_real = 32'h00000007;
		twiddle_imag = 32'h00000007;
		
		@(posedge clk);
		
		compare_outputs(.realAOut(real_A_out), 
										.realAout_ex(real_A_out_ex),
										.realBOut(real_B_out),
										.realBOut_ex(real_B_out_ex),
										.imagAOut(imag_A_out),
										.imagAOut_ex(imag_A_out_ex),
										.imagBOut(imag_B_out),
										.imagBOut_ex(imag_B_out_ex));
		
		// negative test
		real_A = 32'h00000008;
		imag_A = 32'h00000008;
		real_B = -32'h00000008;
		imag_B = -32'h00000008;
		twiddle_real = 32'h00000007;
		twiddle_imag = 32'h00000007;
		
		@(posedge clk);
		
		compare_outputs(.realAOut(real_A_out), 
										.realAout_ex(real_A_out_ex),
										.realBOut(real_B_out),
										.realBOut_ex(real_B_out_ex),
										.imagAOut(imag_A_out),
										.imagAOut_ex(imag_A_out_ex),
										.imagBOut(imag_B_out),
										.imagBOut_ex(imag_B_out_ex));

		// negative test
		real_A = 32'h00020008;
		imag_A = 32'h00050008;
		real_B = 32'h00040008;
		imag_B = 32'h00010008;
		twiddle_real = 32'h00040007;
		twiddle_imag = 32'h00050007;
		
		@(posedge clk);
		
		compare_outputs(.realAOut(real_A_out), 
										.realAout_ex(real_A_out_ex),
										.realBOut(real_B_out),
										.realBOut_ex(real_B_out_ex),
										.imagAOut(imag_A_out),
										.imagAOut_ex(imag_A_out_ex),
										.imagBOut(imag_B_out),
										.imagBOut_ex(imag_B_out_ex));
		
		$display("YAHOOO!! All Tests Passed");
		$stop();
	end
	
endmodule