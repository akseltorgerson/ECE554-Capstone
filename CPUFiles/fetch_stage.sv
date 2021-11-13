module fetch_stage(
    //Inputs
    clk, rst, halt, nextPC,
    //Outputs
    instr, pcPlus4
);

    input clk, rst, halt;

    //The next address that the PC should point to
    input [31:0] nextPC;

    //The instruction to decode
    output [31:0] instr;

    //The current PC plus 4 (to get the next instruction if there is no branch or jump)
    output [31:0] pcPlus4;

    wire [31:0] currPC;

    //These signals are not important (but can be used later if need be)
    wire cout, P, G;

    //The instruction memeory
    // Instantiate module here

    //The halt signal will be ~ inside PC so when it is 0, it writes on the next clk cycle
    prgoram_counter iPC(.clk(clk), .rst(rst), .halt(halt), .nextAddr(nextPC), .currAddr(currPC));
    
    //Add four to the current PC (if there is no branch)
    cla_32bit iPCAdder(.A(currPC), .B(16'h00000004), .Cin(1'b0), .Sum(pcPlus4), .Cout(cout), .P(P), .G(G));

endmodule