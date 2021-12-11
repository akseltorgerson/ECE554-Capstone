module mem_arb_tb();

    logic clk, rst;
    logic halt;
    
    // Inputs
    // Instr Cache Interface
    logic instrCacheBlkReq;
    logic [31:0] instrAddr;

    // Data Cache Interface
    logic dataCacheBlkReq;
    logic [31:0] dataAddr;
    logic dataCacheEvictReq;
    logic [511:0] dataBlk2Mem;

    // Accelerator Buffer Interface
    logic accelDataRd;
    logic accelDataWr;
    logic [511:0] accelBlk2Mem;
    logic [17:0] sigNum;

    // Mem Controller Interface
    logic [511:0] common_data_bus_in;
    logic tx_done;
    logic rd_valid; 

    // Outputs
    // Instr Cache Interface
    logic [511:0] instrBlk2Cache;
    logic instrBlk2CacheValid;

    // Data Cache Interface
    logic dataEvictAck;
    logic dataBlk2CacheValid;
    logic [511:0] dataBlk2Cache;

    // Accelerator Buffer Interface
    logic accelWrBlkDone;
    logic accelRdBlkDone;
    logic [511:0] accelBlk2Buffer;
    logic transformComplete;

    logic [511:0] common_data_bus_out;
    logic [31:0] io_addr;
    logic [1:0] op;
    logic [63:0] cv_value;

    // Test Host Memory 1MB
    logic [31:0] testMemory [1048576];
    integer errors;
    integer i;

    mem_arb iMemArb(.*);

    always #5 clk = ~clk;

    initial begin
        // zero out inputs
        clk = 1'b0;
        rst = 1'b0;
        instrCacheBlkReq = '0;
        instrAddr = '0;
        dataCacheBlkReq = '0;
        dataAddr = '0;
        dataCacheEvictReq = '0;
        dataBlk2Mem = '0;
        accelDataRd = '0;
        accelDataWr = '0;
        accelBlk2Mem = '0;
        sigNum = '0;
        common_data_bus_in = '0;
        tx_done = '0;
        rd_valid = '0;

        errors = 0;

        // Load test memory with acending data
        for (i = 0; i < 1048576; i++) begin
            testMemory[i] = i;
        end

        // RESET
        @(negedge clk);
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // wait some clock cycles
        for (i = 0; i < 10; i++) begin
            @(posedge clk);
        end

        // assign inputs at negedge
        @(negedge clk);

        // test an instr read req
        instrCacheBlkReq = 1'b1;
        instrAddr = 1'b0;

        // wait some clock cycles for request
        repeat(10) begin
            @(posedge clk);
        end

        @(negedge clk);
        if (op != 2'b01) begin
            $display("ERROR: OPCODE != READ");
        end

        // recieve done signal from mem_ctrl;
        tx_done = 1'b1;
        @(posedge clk);
        // Move into INSTR_RD_DONE state
        @(negedge clk);
        common_data_bus_in = {  testMemory[15],
                                testMemory[14],
                                testMemory[13],
                                testMemory[12],
                                testMemory[11],
                                testMemory[10],
                                testMemory[9],
                                testMemory[8],
                                testMemory[7],
                                testMemory[6],
                                testMemory[5],
                                testMemory[4],
                                testMemory[3],
                                testMemory[2],
                                testMemory[1],
                                testMemory[0]};

        rd_valid = 1'b1;

        @(posedge clk);

        if (instrBlk2Cache != common_data_bus_in) begin
            $display("ERROR: Instr Blk Expected, %32h, Got, %32h", common_data_bus_in, instrBlk2Cache);
            errors += 1;
        end

        if (instrBlk2CacheValid != 1'b1) begin
            $display("ERROR: Instr Blk Valid should be a 1");
            errors += 1;
        end

        @(negedge clk);
        instrCacheBlkReq = 1'b0;
        tx_done = 1'b0;
        rd_valid = 1'b0;

        @(posedge clk);

        // test out multiple requests at one time
        @(negedge clk);
        instrCacheBlkReq = 1'b1;
        instrAddr = 32'h16;
        dataCacheBlkReq = 1'b1;
        dataAddr = 32'h1f;

        // wait some clock cycles for request
        repeat(2) begin
            @(posedge clk);
        end

        @(negedge clk);
        if (op != 2'b01) begin
            $display("ERROR: OPCODE != READ");
        end

        // recieve done signal from mem_ctrl;
        tx_done = 1'b1;
        @(posedge clk);
        // Move into DATA_RD_DONE state
        @(negedge clk);
        common_data_bus_in = {  testMemory[15+(dataAddr&32'hfffffff0)],
                                testMemory[14+(dataAddr&32'hfffffff0)],
                                testMemory[13+(dataAddr&32'hfffffff0)],
                                testMemory[12+(dataAddr&32'hfffffff0)],
                                testMemory[11+(dataAddr&32'hfffffff0)],
                                testMemory[10+(dataAddr&32'hfffffff0)],
                                testMemory[9+(dataAddr&32'hfffffff0)],
                                testMemory[8+(dataAddr&32'hfffffff0)],
                                testMemory[7+(dataAddr&32'hfffffff0)],
                                testMemory[6+(dataAddr&32'hfffffff0)],
                                testMemory[5+(dataAddr&32'hfffffff0)],
                                testMemory[4+(dataAddr&32'hfffffff0)],
                                testMemory[3+(dataAddr&32'hfffffff0)],
                                testMemory[2+(dataAddr&32'hfffffff0)],
                                testMemory[1+(dataAddr&32'hfffffff0)],
                                testMemory[0+(dataAddr&32'hfffffff0)]};

        rd_valid = 1'b1;

        @(posedge clk);

        if (dataBlk2Cache != common_data_bus_in) begin
            $display("ERROR: Data Blk Expected, %32h, Got, %32h", common_data_bus_in, dataBlk2Cache);
            errors += 1;
        end

        if (dataBlk2CacheValid != 1'b1) begin
            $display("ERROR: Data Blk Valid should be a 1");
            errors += 1;
        end

        @(negedge clk);
        dataCacheBlkReq = 1'b0;
        tx_done = 1'b0;
        rd_valid = 1'b0;

        @(posedge clk);

        // wait some clock cycles for request
        repeat(10) begin
            @(posedge clk);
        end

        @(negedge clk);
        if (op != 2'b01) begin
            $display("ERROR: OPCODE != READ");
        end

        // recieve done signal from mem_ctrl;
        tx_done = 1'b1;
        @(posedge clk);
        // Move into INSTR_RD_DONE state
        @(negedge clk);
        common_data_bus_in = {  testMemory[15+(instrAddr&32'hfffffff0)],
                                testMemory[14+(instrAddr&32'hfffffff0)],
                                testMemory[13+(instrAddr&32'hfffffff0)],
                                testMemory[12+(instrAddr&32'hfffffff0)],
                                testMemory[11+(instrAddr&32'hfffffff0)],
                                testMemory[10+(instrAddr&32'hfffffff0)],
                                testMemory[9+(instrAddr&32'hfffffff0)],
                                testMemory[8+(instrAddr&32'hfffffff0)],
                                testMemory[7+(instrAddr&32'hfffffff0)],
                                testMemory[6+(instrAddr&32'hfffffff0)],
                                testMemory[5+(instrAddr&32'hfffffff0)],
                                testMemory[4+(instrAddr&32'hfffffff0)],
                                testMemory[3+(instrAddr&32'hfffffff0)],
                                testMemory[2+(instrAddr&32'hfffffff0)],
                                testMemory[1+(instrAddr&32'hfffffff0)],
                                testMemory[0+(instrAddr&32'hfffffff0)]};

        rd_valid = 1'b1;

        @(posedge clk);

        if (instrBlk2Cache != common_data_bus_in) begin
            $display("ERROR: Instr Blk Expected, %32h, Got, %32h", common_data_bus_in, instrBlk2Cache);
            errors += 1;
        end

        if (instrBlk2CacheValid != 1'b1) begin
            $display("ERROR: Instr Blk Valid should be a 1");
            errors += 1;
        end

        @(negedge clk);
        instrCacheBlkReq = 1'b0;
        tx_done = 1'b0;
        rd_valid = 1'b0;

        @(posedge clk);




        if (errors != 0) begin
            $display("TEST FAILED: %d ERROR(S)", errors);
        end else begin
            $display("TEST PASSED");
        end

        $stop();

    end

endmodule

