module reg_1bit(clk, rst, write, wData, rData);

    input clk, rst, write, wData;
    output rData;

    wire dataIn;

    dff iDff (.q(rData), .d(dataIn), .clk(clk), .rst(rst));

    assign dataIn = write ? wData : rData;
    
endmodule