module cause_register(
    //Inputs
    clk, rst, imaginaryToRealEx, realToImaginaryEx, complexArithmeticEx,
    fftEx, fftNotCompleteEx, fftNotReadyEx, memAccessEx, memWriteEx, invalidJMPEx, invalidFilterEx,
    //Outputs
    causeDataOut, exception, err
);

    input clk, rst;
    input [31:0] imaginaryToRealEx, realToImaginaryEx, complexArithmeticEx;
    input [31:0] fftEx, fftNotCompleteEx, fftNotReadyEx, memAccessEx, memWriteEx, invalidJMPEx, invalidFilterEx;

    output [31:0] causeDataOut;
    output exception, err;


    wire [31:0] dataIn;
    wire write;

    //Always write?
    reg_multi_bit iCR(.clk(clk), 
                  .rst(rst), 
                  .write(1'b1), 
                  .wData(dataIn),
                  .rData(causeDataOut));

    //TODO: Probably can make imag to Real and real to Imag just one exception
    assign dataIn = imaginaryToRealEx | 
                    realToImaginaryEx | 
                    complexArithmeticEx |
                    fftEx |
                    fftNotCompleteEx |
                    fftNotReadEx |
                    memAccessEx |
                    memWriteEx |
                    invalidJMPEx |
                    invalidFilterEx;
    
    //assign write = 

    //assgin err?


endmodule