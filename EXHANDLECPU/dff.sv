module dff(q, d, clk, rst);

    input d, clk, rst;
    output reg q;

    always @(posedge clk or negedge rst) begin
        if(rst) begin
            q <= 1'b0;
        end
        else begin
            q <= d;
        end
    end
    
endmodule