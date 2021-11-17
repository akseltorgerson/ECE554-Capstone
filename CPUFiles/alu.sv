/**********************************************************
Opcode: Operation

0000: Add | A + B
0001: Subtract | B - A
0010: XOR | A XOR B
0011: ANDN | A and ~B
0100: BEQZ | A == 0
0101: BNEZ | A != 0
0110: BLTZ | A < 0
0111: BGEZ | A >= 0
1000: Equal | A == B then out = 1 o.w out = 0
1001: Less Than | (A < B) out = 1 o.w out = 0
1010: Less Than or Equal | (A <= B) out = 1 o.w out = 0
1011: Pass Through | B goes through (used for LBI)
1100: SLBI | (A << 16) | B
1101: Unused
1110: Unused
1111: Unused
**********************************************************/
module alu(
    //Inputs
    A, B, op,
    //Outputs
    out, isTaken
);

    input [31:0] A;
    input [31:0] B;
    input [3:0] op;

    output [31:0] out;

    //For Branch statements
    output isTaken;

    //Outputs of the always black that can be changed
    reg [31:0] regOut;
    reg [31:0] aNew;
    reg [31:0] bNew;
    reg regIsTaken;
    reg carryNew;
    wire [31:0] outXor, outAnd, outOr, outAdd;
    wire P, G, cOut;

    cla_32bit iCLA1(.A(aNew), 
                    .B(bNew), 
                    .Cin(carryNew), 
                    .Sum(outAdd), 
                    .Cout(cOut), 
                    .P(P),
                    .G(G));
    
    assign outXor = aNew ^ bNew;
    assign outAnd = aNew & bNew;
    assign outOr = aNew | bNew;

    assign out = regOut;
    assign isTaken = regIsTaken;

    always @(*) begin
        carryNew = 1'b0;
        aNew = 32'h0;
        bNew = 32'h0;
        regOut = 32'h0;
        regIsTaken = 1'b0;
        case(op)
            //Add
            4'b0000: begin
                aNew = A;
                bNew = B;
                regOut = outAdd;
                carryNew = 1'b0;
            end
            //Subtract
            4'b0001: begin
                aNew = B;
                bNew = ~A;
                carryNew = 1'b1;
                regOut = outAdd;
            end
            //XOR
            4'b0010: begin
                aNew = A;
                bNew = B;
                regOut = outXor;
            end
            //ANDN
            4'b0011: begin
                aNew = A;
                bNew = B;
                regOut = outAnd;
            end
            //BEQZ
            4'b0100: begin
                regIsTaken = (A == 32'h0) ? 1'b1 : 1'b0;
            end
            //BNEZ
            4'b0101: begin
                regIsTaken = (A == 32'h0) ? 1'b0 : 1'b1;
            end
            //BLTZ
            4'b0110: begin
                regIsTaken = A[15];
            end
            //BGEZ
            4'b0111: begin
                regIsTaken = ~A[15];
            end
            //Equal
            4'b1000: begin
                regOut = (A == B) ? 32'h0001 : 32'h0;
            end
            //Less Than
            4'b1001: begin
                carryNew = 1'b1;
                aNew = A;
                bNew = ~B;
                regOut = (outAdd == 32'h0) ? 32'h0 : {31'b0, outAdd[31]};
            end
            //Less than or equal
            4'b1010: begin
                carryNew = 1'b1;
                aNew = A;
                bNew = ~B;
                regOut = (outAdd == 32'h0) ? 32'h0 : {31'b0, outAdd[31]};
            end
            //Pass Through (LBI)
            4'b1011: begin
                regOut = B;
            end
            //SLBI
            4'b1100: begin
                regOut = {A[15:0], B[15:0]};
            end
            //Unused
            4'b1101: begin
                
            end
            //Unused
            4'b1110: begin
                
            end
            //Unused
            4'b1111: begin
                
            end
        endcase
    end 

endmodule