module cause_register(
    //Inputs
    clk, rst, realImagLoadEx, complexArithmeticEx,
    fftNotCompleteEx, memAccessEx, memWriteEx, invalidJMPEx, invalidFilterEx, invalidWaveEx
    //Outputs
    causeDataOut, exception, err
);

    input clk, rst;
    input realImagLoadEx, complexArithmeticEx, invalidWaveEx; 
    input fftNotCompleteEx, memAccessEx, memWriteEx, invalidJMPEx, invalidFilterEx;

    output [31:0] causeDataOut;
    output exception, err;
    

    wire [31:0] dataIn;
    wire write;

    //Plan: We will only write when an Exception is raised because we are just going to halt on an exception
    //Later: We will want to always write so when the exception handler is done executing it can clear the exception from the cause register
    reg_multi_bit iCR(.clk(clk), 
                  .rst(rst), 
                  .write(write), 
                  .wData(dataIn),
                  .rData(causeDataOut));
    
    always_comb begin
        dataIn = 32'h00000000;
        write = 1'b0;
        case({realImagLoadEx, complexArithmeticEx, fftNotCompleteEx, memAccessEx, memWriteEx, invalidJMPEx, invalidWaveEx, invalidFilterEx})
            //-------------realImagLoad Exception---------------
            //Details: If try to load real into imag reg or vice versa
            8'b10000000: begin 
                dataIn = 32'h00000001;
                write = 1'b1;
            end
            //------------Complex arithmetic Exception-----------
            //Details: If try to do arithmetic on a real and imaginary registers
            //Note: If both realImag and Complex, code is written so this exception gets priority
            8'b01000000: begin 
                dataIn = 32'h00000002;
                write = 1'b1;
            end
            //----------fftNotComplete Exception -----------
            //Details: If access fft output memory addresses while data is calculating in accelerator
            8'b00100000: begin 
                dataIn = 32'h00000004;
                write = 1'b1;
            end
            //---------memAccess Exception---------
            //Details: If read an illegal memory address
            8'b00010000: begin 
                dataIn = 32'h00000008;
                write = 1'b1;
            end
            //---------memWrite Exception---------
            //Details: If write to an illegal memory address
            8'b00001000: begin 
                dataIn = 32'h00000010;
                write = 1'b1;
            end
            //---------invalidJMP Exception---------
            //Details: If jump to an invalid address
            8'b00000100: begin 
                dataIn = 32'h00000020;
                write = 1'b1;
            end
            //-------------invalidWave Exception------------
            //Details: If the wave file doesn't begin with 0x52494646 big endian form
            8'b00000010: begin 
                dataIn = 32'h00000040;
                write = 1'b1;
            end
            //--------Invalid Filter Exception-----------
            //Details: If there is a startF with filtering before a loadF has been done
            8'b00000001: begin
                dataIn = 32'h00000080;
                write = 1'b1;
            end
            default: begin
                //Do nothing
            end
        endcase
    end

    // If any of the bits are set, then there is an exception
    assign exception |= causeDataOut;

    //TODO: Can get to later, need this to be set to 1 if there is more than 1 bit set in the CR
    assign err = 1'b0;

endmodule