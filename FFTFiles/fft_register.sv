module fft_register(
    input clk, rst, en,
    input signed [31:0] d,
    output signed [31:0] q
);
    genvar i;

    generate
        for (i = 0; i < 32; i++) begin
            dff dff_i(.d(en ? d[i] : q[i]), .q(q[i]), .clk(clk), .rst(rst));
        end
    endgenerate

endmodule