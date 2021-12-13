module fft_alg_tb();

    ////////////////////////
    ///// intermediates ////
    ////////////////////////

    // global signals
    logic clk, rst, load, externalLoad, scan;

    // butterfly signals
    logic [31:0] butterfly_real_A_out, 
                 butterfly_real_B_out, 
                 butterfly_imag_A_out, 
                 butterfly_imag_B_out, 
                 butterfly_real_A_in, 
                 butterfly_real_B_in, 
                 butterfly_imag_A_in, 
                 butterfly_imag_B_in,
                 twiddle_real, 
                 twiddle_imag, 
                 external_real_A, 
                 external_imag_A,
                 test_realA,
                 test_imagA,
                 test_realB,
                 test_imagB;

    logic [4:0] stageCount;
    logic [9:0] indexA, 
                indexB, 
                externalIndexA, 
                cycleCount,
                outIndex;
    logic [8:0] twiddleIndex, fake_twiddleIndex;

    // rom
    reg signed [31:0] twiddle_mem [0:1023];
    reg signed [31:0] fake_mem [0:2047];

    integer i, j, k, fd;

    //////////////////////////
    // ADDRESS GEN BITS
    //////////////////////////
    integer bucket, bucketsMAX, cycleLimit, startingPos, bucketIterationCnt, dftSize, indexA_fake, indexB_fake;    // bucket refers to which DFT the cycle iteration refers to

    assign bucketsMAX = 2 ** stageCount;
    assign cycleLimit = 512 / bucketsMAX;
    assign dftSize = 1024 / bucketsMAX;
    assign startingPos = bucket * dftSize;
    assign indexB_fake = indexA_fake + (512 >> stageCount);

    ////////////////////////
    ////// modules /////////
    ////////////////////////
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
                            .cycleCount(cycleCount[8:0]), 
                            .indexA(indexA), 
                            .indexB(indexB), 
                            .twiddleIndex(twiddleIndex));

    fft_ram iRam(.clk(clk), 
                 .rst(rst), 
                 .load(load), 
                 .externalLoad(externalLoad), 
                 .indexA(externalLoad || scan ? externalIndexA : indexA), 
                 .indexB(indexB), 
                 .A_real_i(externalLoad ? external_real_A : butterfly_real_A_out), 
                 .A_imag_i(externalLoad ? external_imag_A : butterfly_imag_A_out), 
                 .B_real_i(butterfly_real_B_out), 
                 .B_imag_i(butterfly_imag_B_out), 
                 .A_real_o(butterfly_real_A_in), 
                 .A_imag_o(butterfly_imag_A_in), 
                 .B_real_o(butterfly_real_B_in), 
                 .B_imag_o(butterfly_imag_B_in));
    

    // CLOCK SIGNAL
    always #5 clk = ~clk;

    /////////////////////////////////////////////////
    ////////////// TASKS ////////////////////////////
    /////////////////////////////////////////////////
    task mult_complex;
        input signed [31:0] real_A, imag_A, real_B, imag_B, twiddle_real, twiddle_imag;
        output signed [31:0] real_A_out, imag_A_out, real_B_out, imag_B_out;
        logic signed [63:0] real_left_prod, real_right_prod, imag_left_prod, imag_right_prod, inter_real, inter_imag;
        logic signed [31:0] mult_B_real, mult_B_imag;

        begin
            real_left_prod = real_B * twiddle_real;
            real_right_prod = imag_B * twiddle_imag;
            imag_left_prod = real_B * twiddle_imag;
            imag_right_prod = imag_B * twiddle_real;

            inter_real = (real_left_prod - real_right_prod);
            inter_imag = (imag_left_prod + imag_right_prod);

            mult_B_real = inter_real[47:16];
            mult_B_imag = inter_imag[47:16];

            real_A_out = real_A + mult_B_real;
	        imag_A_out = imag_A + mult_B_imag;
	        real_B_out = real_A - mult_B_real;
	        imag_B_out = imag_A - mult_B_imag;
        end
    endtask

    /////////////////////////////////////////////////////
    /////////////////// TB //////////////////////////////
    /////////////////////////////////////////////////////
    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        scan = 0;
        externalLoad = 0;
        externalIndexA = 0;
        external_real_A = 32'h00000000;
        external_imag_A = 32'h00000000;
        fake_twiddleIndex = 9'h000;
        stageCount = 0;
        cycleCount = 0;
        outIndex = 0;
        $readmemh("twiddleHex.mem", twiddle_mem);
        $readmemh("testSignalHex.mem", fake_mem);

        // run through the FFT on the regular ram
        for(stageCount = 0; stageCount < 10; stageCount++) begin
            for (bucket = 0; bucket < bucketsMAX && k < 512; bucket++) begin
                for(bucketIterationCnt = 0; bucketIterationCnt < cycleLimit; bucketIterationCnt++) begin
                    
                    indexA_fake = k === 0 ? k : startingPos + bucketIterationCnt;

                    test_realA = 0;
                    test_imagA = 0;
                    test_realB = 0;
                    test_imagB = 0;

                    fake_twiddleIndex = $floor(k * (2 ** (stageCount + 1)) / 1024);
                    
                    fake_twiddleIndex = {fake_twiddleIndex[0], fake_twiddleIndex[1], fake_twiddleIndex[2],
                                        fake_twiddleIndex[3], fake_twiddleIndex[4], fake_twiddleIndex[5],
                                        fake_twiddleIndex[6], fake_twiddleIndex[7], fake_twiddleIndex[8]};

                    mult_complex(.real_A(fake_mem[2*indexA_fake ]),                     // real A in
                                .imag_A(fake_mem[2*indexA_fake + 1]),                   // imag A in
                                .real_B(fake_mem[2*indexB_fake ]),                      // real B in
                                .imag_B(fake_mem[2*indexB_fake + 1]),                   // imag B in
                                .twiddle_real(twiddle_mem[2*fake_twiddleIndex]),        // twiddle factors
                                .twiddle_imag(twiddle_mem[2*fake_twiddleIndex + 1]),
                                .real_A_out(test_realA),                                 // outputs
                                .imag_A_out(test_imagA),
                                .real_B_out(test_realB),
                                .imag_B_out(test_imagB));

                    @(posedge clk);

                    fake_mem[2*indexA_fake] = test_realA;
                    fake_mem[2*indexA_fake + 1] = test_imagA;
                    fake_mem[2*indexB_fake] = test_realB;
                    fake_mem[2*indexB_fake + 1] = test_imagB;

                    k++;
                end   
            end
        end
        
        

        fd = $fopen("./fftOutput.txt","w");

        for (j = 0; j < 1024; j++) begin

            outIndex = {j[0], j[1], j[2], j[3], j[4], j[5], j[6], j[7], j[8], j[9]};

            @(posedge clk);
            @(negedge clk);

            $fdisplay(fd, "%h", fake_mem[2*j]);
            $fdisplay(fd, "%h", fake_mem[2*j + 1]);

        end

        $fclose(fd);

        $display("YAHOOOO! Tests Passed!");
        $stop();
    end

    
endmodule