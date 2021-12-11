module fft_accel(
    input clk, rst, startF, startI, loadF, filter, read,
    input [9:0] externalIndexA
    input [17:0] sigNum,
    input [31:0] external_real_A, external_imag_A,
    output done, calculating, 
    output [17:0] sigNumMC
    output [31:0] real_out, imag_out;
);

    logic [31:0] butterfly_real_A_out, butterfly_real_B_out, butterfly_imag_A_out, butterfly_imag_B_out, 
                        butterfly_real_A_in, butterfly_real_B_in, butterfly_imag_A_in, butterfly_imag_B_in,
                        twiddle_real, twiddle_imag, external_real_A, external_imag_A;

    logic [4:0] stageCount;
    logic [9:0] indexA, indexB;
    logic [8:0] twiddleIndex, cycleCount;

    logic loadExternalDone;                                     // external signal for indicating loading RAM is done
    logic doFilter, writeFilter, isIFFT, fDone, doneCalculating;

    ////////////////////////
    ////// modules//////////
    ////////////////////////
    twiddle_ROM rom1(.clk(clk)
                     .twiddleIndex(twiddleIndex),
                     .twiddle_real(twiddle_real),
                     .twiddle_imag(twiddle_imag));

    control control1(.clk(clk), 
                     .rst(rst), 
                     .done(doneCalculating), 
                     .loadExternalDone(loadExternalDone), 
                     .doFilter(doFilter),
                     .sigNum(sigNum), 
                     .sigNumMC(sigNumMC), 
                     .startF(startF), 
                     .startI(startI), 
                     .calculating(calculating), 
                     .loadInternal(loadInternal), 
                     .writeFilter(writeFilter), 
                     .isIFFT(isIFFT), 
                     .fDone(fDone), 
                     .aDone(done));

    butterfly_unit iBUnit(.real_A(butterfly_real_A_in), 
                          .imag_A(butterfly_imag_A_in), 
                          .real_B(butterfly_real_B_in), 
                          .imag_B(butterfly_imag_B_in), 
                          .twiddle_real(twiddle_real), 
                          .twiddle_imag(twiddle_imag), 
                          .real_A_out(butterfly_real_A_out), 
                          .imag_A_out(butterfly_imag_A_out), 
                          .real_B_out(butterfly_real_B_out), 
                          .imag_B_out(butterfly_imag_B_out));

    address_generator iAgen(.stageCount(stageCount), 
                            .cycleCount(cycleCount), 
                            .indexA(indexA), 
                            .indexB(indexB), 
                            .twiddleIndex(twiddleIndex));

    fft_ram iRam(.clk(clk), 
                 .rst(rst), 
                 .load(loadInternal), 
                 .externalLoad(externalLoad), 
                 .indexA(externalLoad | read ? externalIndexA : indexA), 
                 .indexB(indexB), 
                 .A_real_i(externalLoad ? external_real_A : butterfly_real_A_out), 
                 .A_imag_i(externalLoad ? external_imag_A : butterfly_imag_A_out), 
                 .B_real_i(butterfly_real_B_out), 
                 .B_imag_i(butterfly_imag_B_out), 
                 .A_real_o(butterfly_real_A_in), 
                 .A_imag_o(butterfly_imag_A_in), 
                 .B_real_o(butterfly_real_B_in), 
                 .B_imag_o(butterfly_imag_B_in));

    //////////////////////////////
    ////// DFFs //////////////
    //////////////////////////////

    // cycleCount dff
    always_ff @(posedge clk, posedge rst) begin
        if (rst | &cycleCount)
            cycleCount <= 9'b000000000;
        else if (calculating & loadInternal)
            cycleCount <= cycleCount + 1;
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            stageCount <= 5'b00000;
        else if (&stageCount) begin
            stageCount <= 5'b00000;
            doneCalculating <= 1'b1;
        end else if (calculating & loadInternal & &cycleCount)
            stageCount <= stageCount + 1;
    end

    //////
    assign real_out = butterfly_real_A_in;
    assign imag_out = butterfly_imag_A_in;

endmodule