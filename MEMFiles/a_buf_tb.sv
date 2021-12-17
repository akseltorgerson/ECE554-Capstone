module a_buf_tb();

    // input
    logic clk, rst;
    logic accelWrEn;
    logic mcWrEn;
    logic [511:0] mcDataIn;
    logic [63:0] accelDataIn;
    logic accelWrBlkDone;

    // outputs
    logic outBufferFull;
    logic inBufferFull;
    logic [63:0] accelDataOut;
    logic [511:0] mcDataOut;
    logic mcDataOutValid;
    logic accelDataOutValid;
    logic inFifoEmpty;

    // other
    // Test Host Memory 1MB
    logic [31:0] testMemory [8192];
    integer errors;
    integer i, j;

    a_buf_top iBufTop(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        accelWrEn = 1'b0;
        mcWrEn = 1'b0;
        mcDataIn = 512'b0;
        accelDataIn = 64'b0;
        accelWrBlkDone = 1'b0;

        // Load test memory with acending data
        for (i = 0; i < 8192; i++) begin
            testMemory[i] = i;
        end

        @(negedge clk);
        @(posedge clk);
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        i = -1;

        repeat(128) begin
            i += 1;
            @(posedge clk);
            @(negedge clk);
            mcWrEn = 1'b1;
            mcDataIn = {testMemory[(i*16)+15],
                        testMemory[(i*16)+14],
                        testMemory[(i*16)+13],
                        testMemory[(i*16)+12],
                        testMemory[(i*16)+11],
                        testMemory[(i*16)+10],
                        testMemory[(i*16)+9],
                        testMemory[(i*16)+8],
                        testMemory[(i*16)+7],
                        testMemory[(i*16)+6],
                        testMemory[(i*16)+5],
                        testMemory[(i*16)+4],
                        testMemory[(i*16)+3],
                        testMemory[(i*16)+2],
                        testMemory[(i*16)+1],
                        testMemory[(i*16)]};

            @(posedge clk);
            @(negedge clk);
            mcWrEn = 1'b0;
        end

        repeat (1050) begin
            @(posedge clk);
        end

        i = -1;

        // Out buffer test
        repeat(1024) begin
            i += 1;
            @(posedge clk);
            @(negedge clk);
            accelWrEn = 1'b1;
            accelDataIn = {testMemory[(2*i)+1], testMemory[2*i]};

            @(posedge clk);
            @(negedge clk);
            accelWrEn = 1'b0;
        end

        repeat (140) begin
            @(posedge clk);
        end

        $stop();

    end

endmodule