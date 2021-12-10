module execute_stage(
    //Inputs
    instr, pcPlus1, read1Data, read2Data, isSignExtend, isIType1,
    isBranch, aluSrc, isJump, isJR, isSLBI, aluOp,
    //Outputs
    nextPC, aluResult, invalidJMPEx
);
    input [31:0] instr, pcPlus1, read1Data, read2Data;
    input [3:0] aluOp;
    //Control signals (isTaken comes from the ALU not the Control Unit)
    input isSignExtend, isIType1, isBranch, aluSrc, isJump, isJR, isSLBI;

    output [31:0] nextPC;
    output [31:0] aluResult;
    output invalidJMPEx;

    wire [31:0] aluResultInterior;
    wire [31:0] extendedIType1;
    wire [31:0] iTypeWire;
    wire [31:0] extendedIType2;
    wire [31:0] offset;
    wire [31:0] offsetPCPlus1;
    wire [31:0] pcNotJR;
    wire [31:0] bInputALU;
    //Not used currently but can be later if needed
    wire cOut, P, G;
    //pseudo control signal
    wire jumpOrTaken;
    wire isTaken;

    cla_32bit iCLA(.A(offset),
                   .B(pcPlus1),
                   .Cin(1'b0),
                   .Sum(offsetPCPlus1),
                   .Cout(Cout),
                   .P(P),
                   .G(G)
                   );

    alu iALU(.A(read1Data),
             .B(bInputALU),
             .op(aluOp),
             .out(aluResultInterior),
             .isTaken(isTaken)
            );

    //Sign extend or zero extend the last 19 bits of IFormType1
    assign extendedIType1 = isSignExtend ? {{13{instr[18]}}, instr[18:0]} : {13'b0, instr[18:0]};

    //Need this becuase SLBI is zero extended whereas the rest of IFormType2 instructions are signextended
    assign extendedIType2 = isSLBI ? {16'b0, instr[15:0]} : {{9{instr[22]}}, instr[22:0]};

    //This is either IType1 or IType2 which have different immediates
    assign iTypeWire = isIType1 ? extendedIType1 : extendedIType2;

    //Offset for adding to the PC
    assign offset = isBranch ? iTypeWire : {{5{instr[26]}}, instr[26:0]};

    //pseudo control signal
    assign jumpOrTaken = (isTaken & isBranch) | (isJump);
    assign pcNotJR = jumpOrTaken ? offsetPCPlus1 : pcPlus1;

    //isJR referres to JR or JALR
    //TODO: Assign this to the exception handler address if there is an exception
    assign nextPC = isJR ? aluResultInterior : pcNotJR;

    assign bInputALU = aluSrc ? read2Data : iTypeWire;

    assign aluResult = aluResultInterior;

    //---------------------Exception Handling-----------------------------
    
    //If one of the top 4 bits is set, we are in the data section instead of instruction
    assign invalidJMPEx = ^nextPC[31:28];
endmodule