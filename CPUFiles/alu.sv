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

endmodule