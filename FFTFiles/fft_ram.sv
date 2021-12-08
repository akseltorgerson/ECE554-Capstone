module fft_ram(
    input clk, rst, load,
    input [9:0] indexA, indexB,
    input  signed [31:0] A_real_i, A_imag_i, B_real_i, B_imag_o,
    output signed [31:0] A_real_o, A_imag_o, B_real_o, B_imag_o
);

    genvar i;

    generate
        for (i = 0; i < 1024; i++) begin
            fft_register reg_r(.clk(clk), 
                               .rst(rst), 
                               .d(indexA === i ? A_real_i :
                                  indexB === i ? B_real_i :
                                  '0), 
                               .q(indexA === i ? A_real_o :
                                  indexB === i ? B_real_o :
                                  '0),
                               .en(load && (indexA === i || indexB === i));
            fft_register reg_i(.clk(clk), 
                               .rst(rst), 
                               .d(indexA === i ? A_imag_i :
                                  indexB === i ? B_imag_i :
                                  '0), 
                               .q(indexA === i ? A_imag_o :
                                  indexB === i ? B_imag_o :
                                  '0), 
                               .en(load && (indexA === i || indexB === i));
        end
    endgenerate

endmodule