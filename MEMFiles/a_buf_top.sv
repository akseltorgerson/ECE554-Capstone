module a_buf_top(

    input clk, rst,
    input accelWrEn,
    input mcWrEn,
    input [511:0] mcDataIn,
    input [63:0] accelDataIn,
    output reg outBufferFull,
    output reg inBufferFull,
    output reg [63:0] accelDataOut,
    output reg [511:0] mcDataOut,
    output reg mcDataOutValid,
    output reg accelDataOutValid,
    output reg inFifoEmpty

);

    /********************************************************
    *          Buffers data from host to accelerator        *
    ********************************************************/
    a_buf_in iBufIn(.clk(clk), .rst(rst), 
                    .wrEn(mcWrEn), 
                    .dataIn(mcDataIn),
                    .bufferFull(inBufferFull),
                    .dataOut(accelDataOut),
                    .dataOutValid(accelDataOutValid),
                    .fifoEmpty(inFifoEmpty));

    /********************************************************
    *          Buffers data from accelerator to host        *
    ********************************************************/
    a_buf_out iBufOut(  .clk(clk), .rst(rst),
                        .wrEn(accelWrEn),
                        .dataIn(accelDataIn),
                        .bufferFull(outBufferFull),
                        .dataOut(mcDataOut),
                        .dataOutValid(mcDataOutValid));

endmodule