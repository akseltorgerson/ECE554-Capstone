module writeback_stage(
    //Inputs
    memoryOut, aluResult, memToReg,
    //Outputs
    writebackData
);
    
    // Memory out that might need to go back into registers
    input [31:0] memoryOut;

    //aluResult that might need to go back into registers
    input [31:0] aluResult;

    // Control signal that determines whether aluResult or memoryOut is going back to decode stage
    input memToReg;

    output [31:0] writebackData;

    assign writebackData = memToReg ? memoryOut : aluResult;

endmodule