module twiddle_ROM(
    input clk,
    input [8:0] twiddleIndex,
    output [31:0] twiddle_real, twiddle_imag
);

    reg [31:0] twiddle_mem [0:1023];
    
    assign twiddle_real = twiddle_mem[2*twiddleIndex];
    assign twiddle_imag = twiddle_mem[2*twiddleIndex + 1];

    initial begin
        $readmemh("twiddleHex.mem", twiddle_mem);
    end
    
endmodule