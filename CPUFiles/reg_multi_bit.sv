module reg_multi_bit(clk, rst, write, wData, rData);

    parameter width = 32;

    input clk, rst, write;
    input [width - 1:0] wData;
    output [width - 1:0] rData;

    wire [width -1:0] dataIn;

    dff iDff [width -1:0] (.q(rData), .d(dataIn), .clk(clk), .rst(rst));

    assign dataIn = write ? wData : rData;


endmodule