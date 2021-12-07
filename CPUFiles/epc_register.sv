module epc_register(
    //Inputs
    clk, rst, epcIn, write,
    //Outputs
    epcOut
);
    input clk, rst, write;
    input [31:0] epcIn;
    output [31:0] epcOut;

    reg_multi_bit iEPC(.clk(clk),
                       .rst(rst),
                       .write(write),
                       .wData(epcIn),
                       .rData(epcOut));

endmodule