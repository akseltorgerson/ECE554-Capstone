module decode_stage(
    //Inputs
    clk, rst, instr, pcPlus4, writebackData,
    //Outputs
    read1Data, read2Data, aluSrc, isSignExtend, isIType1, isBranch, halt, nop, memWrite, memRead,
    memToReg, isJR, isSLBI, isJump, aluOp, startI, startF, loadF
);

    input clk, rst;
    input [31:0] instr, pcPlus4, writebackData;

    output [31:0] read1Data, read2Data;
    //Control signals
    output aluSrc, isSignExtend, isSLBI, isIType1, isBranch, halt, nop, memWrite, memRead, memToReg, isJR, isJump;
    output [3:0] aluOp;

    //Accelerator Control Signals
    output startI, startF, loadF;

    wire [3:0] writeRegSel;
    wire [31:0] writeData;

    //More control signals but internal to decode stage
    wire isJAL, regWrite, rsWrite, regDst, err;

    //Inputs: opcode
    //Outputs: Everything else
    control_unit iControlUnit(.opcode(instr[31:27]), 
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
                              .loadF(loadF)
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
    
    //Chooses the register that is being written to in the register file
    assign writeRegSel = isJAL ? 4'b1111 : (rsWrite ? instr[26:23] : (regDst ? instr[18:15] : instr[22:19]));

    //Data being written back to the register file
    assign writeData = isJAL ? pcPlus4 : writebackData;

endmodule