module control(
    //Inputs
    startF, startI, loadF, sigNum, doFilter, done, clk, rst
    //Outputs
    fftCalculating, storeSigNum, writeFilter, isIFFT, fDone, 
);

    input clk, rst;

    //Control signal from CPU to let accel know to do an FFT
    input startF;

    //Control signal from CPU to let it know to do an inverse FFT
    input startI;

    //Control signal from CPU to let it know to load a filter in
    input loadF;

    //
    input [17:0] sigNum;

    //Control signal to let the accelerator know that it should be filtered on a STARTF
    input filter;


    input done;

    //Signal to show that the fft is currently calculating on the sigNum
    output fftCalculating;

    //Singal to determine that the sigNum should be stored in it's register
    output storeSigNum;

    output fDone;

    output isIFFT;

    always @(*) begin
        case()

        endcase
    end



endmodule