module butterfly_unit_tb();
	
	//////// intermediates //////////
	logic signed [31:0] real_A, imag_A, real_B, imag_B, twiddle_factor, real_A_out, 
						imag_A_out, real_B_out, imag_B_out, real_A_out_ex, imag_A_out_ex, 
						real_B_out_ex, imag_B_out_ex;
	logic clk;
	
	//////// DUT ///////////
	butterfly_unit iDUT(.*);
	
	/////// Functions & Tasks /////////
	
	task compare_outputs;
		input signed [31:0] realAOut, realAout_ex, realBOut, realBOut_ex, 
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
	
	assign real_A_out_ex = real_A + (real_B * twiddle_factor);
	assign imag_A_out_ex = imag_A + (imag_B * twiddle_factor);
	assign real_B_out_ex = real_A - (real_B * twiddle_factor);
	assign imag_B_out_ex = imag_A - (imag_B * twiddle_factor);
	
	initial begin
		// initial tests (easy test)
		clk = 0;
		real_A = 32'h00000001;
		imag_A = 32'h0;
		real_B = 32'h00000001;
		imag_B = 32'h0;
		twiddle_factor = 32'h00000002;
		
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