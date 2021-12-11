module twiddle_ROM(
    input clk,
    input [8:0] twiddleIndex,
    output reg [31:0] twiddle_real, twiddle_imag
);

    reg [31:0] twiddle_mem [0:1023];
    integer i;

    initial begin
        $readmemh("twiddleHex.mem", twiddle_mem);
    end

    always_ff @(posedge clk) begin
        twiddle_real <= twiddle_mem[2*twiddleIndex];
        twiddle_imag <= twiddle_mem[2*twiddleIndex + 1];
    end
    
endmodule