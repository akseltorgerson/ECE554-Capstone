module decode_stage(
    //Inputs
    clk, rst, instr, pcPlus4, writebackData
    //Outputs
    read1Data, read2Data, aluSrc, isSignExtend, isIType1, isBranch, halt, nop, memWrite, memRead,
    memToReg, isJR, isSLBI, isJump, aluOp, branchOp, startI, startF, loadF
);

    input clk, rst;
    input [31:0] instr, pcplus4, writebackData;

    //Control signals
    output aluSrc, isSignExtend, isIType1, isBranch, halt, nop, memWrite, memRead, memToReg, isJR, isJump;
    output [3:0] aluOp;
    output [1:0] branchOp;

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
                              .branchOp(branchOp),
                              .startI(startI),
                              .startF(startF),
                              .loadF(loadF)
                             );
    
    //Inputs: clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, write
    //Outputs: read1Data, read2Data, err
    rf iRegisterFile(.clk(clk),
                     .rst(rst),
                     .read1RegSel()
                    )

endmodule