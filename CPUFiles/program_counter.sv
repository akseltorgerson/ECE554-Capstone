module program_counter(
    //Inputs
    clk, rst, halt, nextAddr, stallPC,
    //Outputs
    currAddr
);

    input clk, rst, halt;
    input [31:0] nextAddr;
    input stallPC;
    output [31:0] currAddr;

    wire write;

    //If either of these signals is 1 then don't want pc to go to next location so set the write signal to zero
    assign write = ~(halt | stallPC);

    reg_multi_bit iPC(.clk(clk), .rst(rst), .write(write), .wData(nextAddr), .rData(currAddr));

endmodule
