module dff(q, d, clk, rst);

    input d, clk, rst;
    output q;

    reg state;

    assign #(1) q = state;

    always @(posedge clk) begin
        state = rst ? 0 : d;
    end
    
endmodule