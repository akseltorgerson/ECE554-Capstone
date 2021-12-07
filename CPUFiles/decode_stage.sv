module decode_stage(
    //Inputs
    clk, rst, instr, pcPlus1, writebackData, fftCalculating,
    //Outputs
    read1Data, read2Data, aluSrc, isSignExtend, isIType1, isBranch, halt, nop, memWrite, memRead,
    memToReg, isJR, isSLBI, isJump, aluOp, startI, startF, loadF, blockInstruction, realImagLoadEx, complexArithmeticEx, invalidFilterEx
);

    input clk, rst;
    //Control signal for if the fft is currently calculating on data
    input fftCalculating;

    input [31:0] instr, pcPlus1, writebackData;

    output [31:0] read1Data, read2Data;
    //Control signals
    output aluSrc, isSignExtend, isSLBI, isIType1, isBranch, halt, nop, memWrite, memRead, memToReg, isJR, isJump, blockInstruction;
    output [3:0] aluOp;

    //Accelerator Control Signals
    output startI, startF, loadF;

    //Exception signals
    output complexArithmeticEx, realImagLoadEx, invalidFilterEx;

    wire [3:0] writeRegSel;
    wire [31:0] writeData;

    //More control signals but internal to decode stage
    wire isJAL, regWrite, rsWrite, regDst, err;

    //Tells if there has been a loadF instruction yet
    wire filterLoaded;

    //Inputs: opcode
    //Outputs: Everything else
    control_unit iControlUnit(.opcode(instr[31:27]),
                              .fftCalculating(fftCalculating),
                              .isJAL(isJAL),
                              .regDst(regDst),
                              .rsWrite(rsWrite),
                              .regWrite(regWrite),
                              .aluSrc(aluSrc),
                              .isSignExtend(isSignExtend),
                              .isIType1(isIType1),
                              .isBranch(isBranch),
                              .halt(halt),
                              .nop(nop),
                              .memWrite(memWrite),
                              .memRead(memRead),
                              .memToReg(memToReg),
                              .isJR(isJR),
                              .isSLBI(isSLBI),
                              .aluOp(aluOp),
                              .isJump(isJump),
                              .startI(startI),
                              .startF(startF),
                              .loadF(loadF),
                              .blockInstruction(blockInstruction)
                             );
    
    //Inputs: clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, write
    //Outputs: read1Data, read2Data, err
    rf iRegisterFile(.clk(clk),
                     .rst(rst),
                     .read1RegSel(instr[26:23]),
                     .read2RegSel(instr[22:19]),
                     .writeRegSel(writeRegSel),
                     .writeData(writeData),
                     .write(regWrite),
                     .read1Data(read1Data),
                     .read2Data(read2Data),
                     .err(err)
                    );

    //Remembers if there is a filter loaded or not
    reg_1bit iFilterLoaded(.clk(clk),
                           .rst(rst),
                           .write(loadF),
                           .wData(1'b1),
                           .rData(filterLoaded));
    
    //Chooses the register that is being written to in the register file
    assign writeRegSel = isJAL ? 4'b1111 : (rsWrite ? instr[26:23] : (regDst ? instr[18:15] : instr[22:19]));

    //Data being written back to the register file
    assign writeData = isJAL ? pcPlus1 : writebackData;

    //-----------------------Exception Handling-------------------------------
    //Note: The way this is written is that complexArithmetic will get asserted over realImagLoad if both occur in one instr
    
    //ComplexArithmeticException 
    assign complexArithmeticEx = ((instr[31:29] == 3'b110) && (instr[26] != instr[22])) ? 1'b1 : 1'b0;
    
    //InvalidFilterException
    assign invalidFilterEx = (instr[31:27] == 5'b00010) && (instr[8] == 1'b1) && (filterLoaded == 1'b0) ? 1'b1 : 1'b0;

    //RealImaginaryLoadException First part here is for ADDI SUBI next part for SUB ADD
    assign realImagLoadEx = ((instr[31:29] == 3'b010) && (instr[26 != instr[22]])) || ((instr[31:29] == 3'b110) && (instr[26] == instr[22]) && (instr[26] != instr[18])) ? 1'b1 : 1'b0;
endmodule