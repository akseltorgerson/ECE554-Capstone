/*
    Register File
*/
module rf(
    // Outputs
    read1Data, read2Data, err,
    // Inputs
    clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, write
);

    parameter width = 32;
    parameter numRegs = 16;

    input clk, rst;
    input [3:0] read1RegSel;
    input [3:0] read2RegSel;
    input [3:0] writeRegSel;
    input [width - 1:0] writeData; //32 bit input data
    input write;

    output [width - 1:0] read1Data;
    output [width - 1:0] read2Data;
    output err;

    // Controls each register's write ability
    reg [numRegs - 1:0] writeSigs;

    //16 32 bit wide output regs
    wire [width - 1:0] outputReg [0:numRegs-1];

    //NOTE: Might want to change so not everything is in parallel, but can change if that is an issue later
    reg_multi_bit iReg0(.clk(clk), .rst(rst), .write(writeSigs[0]), .wData(writeData), .rData(outputReg[0]));
    reg_multi_bit iReg1(.clk(clk), .rst(rst), .write(writeSigs[1]), .wData(writeData), .rData(outputReg[1]));
    reg_multi_bit iReg2(.clk(clk), .rst(rst), .write(writeSigs[2]), .wData(writeData), .rData(outputReg[2]));
    reg_multi_bit iReg3(.clk(clk), .rst(rst), .write(writeSigs[3]), .wData(writeData), .rData(outputReg[3]));
    reg_multi_bit iReg4(.clk(clk), .rst(rst), .write(writeSigs[4]), .wData(writeData), .rData(outputReg[4]));
    reg_multi_bit iReg5(.clk(clk), .rst(rst), .write(writeSigs[5]), .wData(writeData), .rData(outputReg[5]));
    reg_multi_bit iReg6(.clk(clk), .rst(rst), .write(writeSigs[6]), .wData(writeData), .rData(outputReg[6]));
    reg_multi_bit iReg7(.clk(clk), .rst(rst), .write(writeSigs[7]), .wData(writeData), .rData(outputReg[7]));
    reg_multi_bit iReg8(.clk(clk), .rst(rst), .write(writeSigs[8]), .wData(writeData), .rData(outputReg[8]));
    reg_multi_bit iReg9(.clk(clk), .rst(rst), .write(writeSigs[9]), .wData(writeData), .rData(outputReg[9]));
    reg_multi_bit iReg10(.clk(clk), .rst(rst), .write(writeSigs[10]), .wData(writeData), .rData(outputReg[10]));
    reg_multi_bit iReg11(.clk(clk), .rst(rst), .write(writeSigs[11]), .wData(writeData), .rData(outputReg[11]));
    reg_multi_bit iReg12(.clk(clk), .rst(rst), .write(writeSigs[12]), .wData(writeData), .rData(outputReg[12]));
    reg_multi_bit iReg13(.clk(clk), .rst(rst), .write(writeSigs[13]), .wData(writeData), .rData(outputReg[13]));
    reg_multi_bit iReg14(.clk(clk), .rst(rst), .write(writeSigs[14]), .wData(writeData), .rData(outputReg[14]));
    reg_multi_bit iReg15(.clk(clk), .rst(rst), .write(writeSigs[15]), .wData(writeData), .rData(outputReg[15]));

    always @(*) begin

        writeSigs[numRegs-1:0] = 1'b0;

        case(writeRegSel)
            4'b0: writeSigs[0] = write;
            4'b01: writeSigs[1] = write;
            4'b10: writeSigs[2] = write;
            4'b11: writeSigs[3] = write;
            4'b100: writeSigs[4] = write;
            4'b101: writeSigs[5] = write;
            4'b110: writeSigs[6] = write;
            4'b111: writeSigs[7] = write;
            4'b1000: writeSigs[8] = write;
            4'b1001: writeSigs[9] = write;
            4'b1010: writeSigs[10] = write;
            4'b1011: writeSigs[11] = write;
            4'b1100: writeSigs[12] = write;
            4'b1101: writeSigs[13] = write;
            4'b1110: writeSigs[14] = write;
            4'b1111: writeSigs[15] = write;
        endcase
    end

    assign read1Data = read1RegSel[3] ? (read1RegSel[2] ? (read1RegSel[1] ? (read1RegSel[0] ? outputReg[15] : outputReg[14]) : (read1RegSel[0] ? outputReg[13] : outputReg[12])) : (read1RegSel[1] ? (read1RegSel[0] ? outputReg[11]: outputReg[10]) : (read1RegSel[0] ? outputReg[9] : outputReg[8]))) : (read1RegSel[2] ? (read1RegSel[1] ? (read1RegSel[0] ? outputReg[7] : outputReg[6]) : (read1RegSel[0] ? outputReg[5] : outputReg[4])) : (read1RegSel[1] ? (read1RegSel[0] ? outputReg[3]: outputReg[2]) : (read1RegSel[0] ? outputReg[1] : outputReg[0])));
    assign read2Data = read2RegSel[3] ? (read2RegSel[2] ? (read2RegSel[1] ? (read2RegSel[0] ? outputReg[15] : outputReg[14]) : (read2RegSel[0] ? outputReg[13] : outputReg[12])) : (read2RegSel[1] ? (read2RegSel[0] ? outputReg[11]: outputReg[10]) : (read2RegSel[0] ? outputReg[9] : outputReg[8]))) : (read2RegSel[2] ? (read2RegSel[1] ? (read2RegSel[0] ? outputReg[7] : outputReg[6]) : (read2RegSel[0] ? outputReg[5] : outputReg[4])) : (read2RegSel[1] ? (read2RegSel[0] ? outputReg[3]: outputReg[2]) : (read2RegSel[0] ? outputReg[1] : outputReg[0])));

                       

endmodule
// DUMMY LINE FOR REV CONTROL :1: