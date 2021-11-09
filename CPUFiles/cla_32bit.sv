module cla_32bit(
    //Inputs
    A, B, Cin, Sum,
    //Outputs 
    Cout, P, G
);
    input [31:0] A, B;
    input Cin;
    output [31:0] Sum;
    output Cout, P, G;

    //inner Propagate, Generate, and CarryOut
    wire [6:0] innerP, innerG, innerC;
    CLA_4bit iCLA_4bit1(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .Sum(Sum[3:0]), .Cout(innerC[0]), .P(innerP[0]), .G(innerG[0]));
	CLA_4bit iCLA_4bit2(.A(A[7:4]), .B(B[7:4]), .Cin(innerC[0]), .Sum(Sum[7:4]), .Cout(innerC[1]), .P(innerP[1]), .G(innerG[1]));
	CLA_4bit iCLA_4bit3(.A(A[11:8]), .B(B[11:8]), .Cin(innerC[1]), .Sum(Sum[11:8]), .Cout(innerC[2]), .P(innerP[2]), .G(innerG[2]));
	CLA_4bit iCLA_4bit4(.A(A[15:12]), .B(B[15:12]), .Cin(innerC[2]), .Sum(Sum[15:12]), .Cout(innerC[3]), .P(innerP[3]), .G(innerG[3]));
    CLA_4bit iCLA_4bit5(.A(A[19:16]), .B(B[19:16]), .Cin(innerC[3]), .Sum(Sum[19:16]), .Cout(innerC[4]), .P(innerP[4]), .G(innerG[4]));
    CLA_4bit iCLA_4bit6(.A(A[23:20]), .B(B[23:20]), .Cin(innerC[4]), .Sum(Sum[23:20]), .Cout(innerC[5]), .P(innerP[5]), .G(innerG[5]));
    CLA_4bit iCLA_4bit7(.A(A[27:24]), .B(B[27:24]), .Cin(innerC[5]), .Sum(Sum[27:24]), .Cout(innerC[6]), .P(innerP[6]), .G(innerG[6]));
    CLA_4bit iCLA_4bit8(.A(A[31:28]), .B(B[31:28]), .Cin(innerC[6]), .Sum(Sum[31:28]), .Cout(Cout), .P(P), .G(G));
    
endmodule