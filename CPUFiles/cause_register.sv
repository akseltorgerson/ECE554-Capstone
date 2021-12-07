module cause_register(
    //Inputs
    clk, rst, realImagLoadEx, complexArithmeticEx,
    fftNotCompleteEx, memAccessEx, memWriteEx, invalidJMPEx, invalidFilterEx,
    //Outputs
    causeDataOut, exception, err
);

    input clk, rst;
    input realImagLoadEx, complexArithmeticEx; 
    input fftNotCompleteEx, memAccessEx, memWriteEx, invalidJMPEx, invalidFilterEx;

    output [31:0] causeDataOut;
    output exception;
    output reg err;
    

    logic [31:0] dataIn;
    logic write;

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
	err = 1'b0;
        case({realImagLoadEx, complexArithmeticEx, fftNotCompleteEx, memAccessEx, memWriteEx, invalidJMPEx, invalidFilterEx})
            //-------------realImagLoad Exception---------------
            //Details: If try to load real into imag reg or vice versa
            7'b1000000: begin 
                dataIn = 32'h00000001;
                write = 1'b1;
            end
            //------------Complex arithmetic Exception-----------
            //Details: If try to do arithmetic on a real and imaginary registers
            //Note: If both realImag and Complex, code is written so this exception gets priority
            7'b0100000: begin 
                dataIn = 32'h00000002;
                write = 1'b1;
            end
            //----------fftNotComplete Exception -----------
            //Details: If access fft output memory addresses while data is calculating in accelerator
            7'b0010000: begin 
                dataIn = 32'h00000004;
                write = 1'b1;
            end
            //---------memAccess Exception---------
            //Details: If read an illegal memory address
            7'b0001000: begin 
                dataIn = 32'h00000008;
                write = 1'b1;
            end
            //---------memWrite Exception---------
            //Details: If write to an illegal memory address
            7'b0000100: begin 
                dataIn = 32'h00000010;
                write = 1'b1;
            end
            //---------invalidJMP Exception---------
            //Details: If jump to an invalid address
            7'b0000010: begin 
                dataIn = 32'h00000020;
                write = 1'b1;
            end
            //--------Invalid Filter Exception-----------
            //Details: If there is a startF with filtering before a loadF has been done
            7'b0000001: begin
                dataIn = 32'h00000040;
                write = 1'b1;
            end
            default: begin
		// Issue if get here
                err = 1'b1;
            end
        endcase
    end

    // If any of the bits are set, then there is an exception
    assign exception = ^causeDataOut;

endmodule