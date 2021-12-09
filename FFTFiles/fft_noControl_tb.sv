module fft_noControl_tb();

    ////////////////////////
    ///// intermediates ////
    ////////////////////////

    // global signals
    logic clk, rst, load, externalLoad;

    // butterfly signals
    logic signed [31:0] butterfly_real_A_out, butterfly_real_B_out, butterfly_imag_A_out, butterfly_imag_B_out, 
                        butterfly_real_A_in, butterfly_real_B_in, butterfly_imag_A_in, butterfly_imag_B_in,
                        twiddle_real, twiddle_imag, external_real_A, external_imag_A;

    logic [4:0] stageCount;
    logic [9:0] indexA, indexB, externalIndexA;
    logic [8:0] cycleCount, twiddleIndex;

    // twiddle rom
    reg [31:0] twiddle_mem [0:1023];
    reg [31:0] fake_mem [0:2047];

    int i, j;

    ////////////////////////
    ////// modules /////////
    ////////////////////////
    butterfly_unit iBUnit(.real_A(butterfly_real_A_in), .imag_A(butterfly_imag_A_in), .real_B(butterfly_real_B_in), .imag_B(butterfly_imag_B_in), 
                          .twiddle_real(twiddle_real), .twiddle_imag(twiddle_imag), .real_A_out(butterfly_real_A_out), .imag_A_out(butterfly_imag_A_out), 
                          .real_B_out(butterfly_real_B_out), .imag_B_out(butterfly_imag_B_out));

    address_generator iAgen(.stageCount(stageCount), .cycleCount(cycleCount), .indexA(indexA), .indexB(indexB), .twiddleIndex(twiddleIndex));

    fft_ram iRam(.clk(clk), .rst(clk), .load(load), .externalLoad(externalLoad), .indexA(externalLoad ? externalIndexA : indexA), .indexB(indexB), 
                 .A_real_i(externalLoad ? external_real_A : butterfly_real_A_out), .A_imag_i(externalLoad ? external_imag_A : butterfly_imag_A_out), 
                 .B_real_i(butterfly_real_B_out), .B_imag_i(butterfly_imag_B_out), .A_real_o(butterfly_real_A_in), .A_imag_o(butterfly_imag_A_in), 
                 .B_real_o(butterfly_real_B_in), .B_imag_o(butterfly_imag_B_in));
    
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        externalLoad = 0;
        external_real_A = 32'h00000000;
        external_imag_A = 32'h00000000;
        stageCount = 0;
        cycleCount = 0;
        $readmemh("twiddleHex.mem", twiddle_mem);
        $readmemh("testSignalHex.mem", fake_mem);

        /////////////
        // reset
        /////////////
        rst = 1;

        @(posedge clk);

        rst = 0;

        /////////////////
        // load the ram
        /////////////////
        externalLoad = 1;

        for (i = 0; i < 1024; i++) begin
            externalIndexA = i;
            external_imag_A = fake_mem[2*i + 1];
            external_real_A = fake_mem[2*i];

            @(posedge clk);

            if (butterfly_real_A_in !== fake_mem[2*i] || butterfly_imag_A_in !== fake_mem[2*i + 1]) begin
                $display("RAM OUT REAL: %h, RAM OUT IMAG: %h", butterfly_real_A_in, butterfly_imag_A_in);
                $display("EXPECTED RAM OUT REAL: %h, EXPECTED RAM OUT IMAG: %h", fake_mem[2*i], fake_mem[2*i + 1]);
                $stop();
            end
        end

        $display("YAHOOOO! Tests Passed!");
        $stop();
    end

    
endmodule