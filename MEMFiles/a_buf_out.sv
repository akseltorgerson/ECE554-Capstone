module a_buf_out (
    input clk, rst, wrEn, dequeue;
    input reg [63:0] dataIn;
    output bufferFull;
    output reg [511:0] dataOut;
    output reg dataOutValid;

);

    localparam DEPTH = 1024;
    localparam WIDTH = 64;


endmodule