module fft_noControl_tb();

    // global signals
    logic clk, rst;
    logic signed [31:0] butterfly_real_A_out, butterfly_real_B_out, butterfly_imag_A_out, butterfly_imag_B_out, 
                        butterfly_real_A_in, butterfly_real_B_in, butterfly_imag_A_in, butterfly_imag_B_in;

    // twiddle rom
    reg [31:0] twiddle_mem [0:1023];

    ////////////////////////
    ////// modules /////////
    ////////////////////////
    butterfly_unit iBUnit(.real_A, .imag_A, .real_B, .imag_B, .twiddle_real, .twiddle_imag,
                          .real_A_out, .imag_A_out, .real_B_out, .imag_B_out);

    address_generator iAgen(.stageCount, .cycleCount, .indexA, .indexB, .twiddleIndex);

    fft_ram iRam(.clk(clk), .rst(clk), .load(), .indexA, .indexB, .A_real_i, .A_imag_i, .B_real_i, .B_imag_o,
                 .A_real_o, .A_imag_o, .B_real_o, .B_imag_o);
    

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        $readmemh("twiddleHex.mem", twiddle_mem);
    end

    
endmodule