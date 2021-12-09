/*
    Bypass version of register file
*/
module rf_bypass(
    //Outputs
    read1Data, read2Data, err,
    //Inputs
    clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, write 
);

    parameter width = 32;
    parameter numRegs = 16;

    input clk, rst;
    //3:0 because 4 bits for the 16 regs
    input [3:0] read1RegSel;
    input [3:0] read2RegSel;
    input [3:0] writeRegSel;
    input [width - 1:0] writeData; //32 bit input data
    input write;

    output [width - 1:0] read1Data;
    output [width - 1:0] read2Data;
    output err;

    wire [width - 1:0] read1Out;
    wire [width - 1:0] read2Out;

    rf iRF(.clk(clk), .rst(rst), .read1RegSel(read1RegSel), .read2RegSel(read2RegSel), .writeRegSel(writeRegSel), .writeData(writeData), .write(write), .read1Data(read1Out), .read2Data(read2Out), .err(err));

    assign read1Data = write ? (writeRegSel == read1RegSel ? writeData : read1Out) : read1Out;
    assign read2Data = write ? (writeRegSel == read2RegSel ? writeData : read2Out) : read2Out;

endmodule
// DUMMY LINE FOR REV CONTROL :1: