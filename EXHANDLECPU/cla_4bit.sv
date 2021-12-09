module CLA_4bit(
    //Inputs
    A, B, Cin,
    //Outputs
    Sum, Cout, P, G
);

    input [3:0] A, B;
    input Cin;
    output [3:0] Sum;
    output Cout, P, G;

    wire [3:0] innerG, innerP, innerC;

    assign innerG = A & B; //calculates the generate bitwise
	//Xored because you Xor it later with inner_C to get the sum
	assign innerP = A ^ B; //calculates the propagate bitwise
	assign innerC[0] = Cin; // assign the first bit of inner_C to Cin for easier readability

	//Calculate each carry so that you can get the 4-bit sum
	assign innerC[1] = innerG[0] | (innerP[0] & innerC[0]);
	assign innerC[2] = innerG[1] | (innerP[1] & innerG[0]) | (innerP[1] & innerP[0] & innerC[0]);
	assign innerC[3] = innerG[2] | (innerP[2] & innerG[1]) | (innerP[2] & innerP[1] & innerG[0]) | (innerP[2] & innerP[1] & innerP[0] & innerC[0]);
	assign Cout = innerG[3] | (innerP[3] & innerG[2]) | (innerP[3] & innerP[2] & innerG[1]) | (innerP[3] & innerP[2] & innerP[1] & innerG[0]) |(innerP[3] & innerP[2] & innerP[1] & innerP[0] & innerC[0]);
	//Solve the sum using the propgate logic
	assign Sum = innerP ^ innerC;
	
	//Propgate/Generate out of the 4bits (into the next block)
	assign P = innerP[3] & innerP[2] & innerP[1] & innerP[0];
	assign G = innerG[3] | (innerP[3] & innerG[2]) | (innerP[3] & innerP[2] & innerG[1]) | (innerP[3] & innerP[2] & innerP[1] & innerG[0]);
endmodule