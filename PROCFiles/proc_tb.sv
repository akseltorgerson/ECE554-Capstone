module proc_tb();

    //Inputs to processor
    logic clk;
    logic rst;
    logic [511:0] common_data_bus_in;
    logic tx_done;
    logic rd_valid;
    //Outputs of the processor
    logic [1:0] op_actual, op_expected;
    logic [511:0] common_data_bus_out_actual, common_data_bus_out_expected;
    logic [31:0] io_addr_actual, io_addr_expected;
    logic [63:0] cv_value_actual, cv_value_expected;

    //Probably want some memory here
    logic [31:0] instrMemory[2048];     // instructions     // 0x0000_0000 - 0x0000_7fff
    logic [31:0] accelMemory[2048];     // accelerator      // 0x1000_0000 - 0x1000_7fff
    logic [31:0] dataMemory[2048];      // cpu data         // 0x2000_0000 - 0x2000_7fff
    integer i;
    integer errors = 0;
    
    proc iProcessor(.clk(clk),
                    .rst(rst),
                    .common_data_bus_in(common_data_bus_in),
                    .tx_done(tx_done),
                    .rd_valid(rd_valid),
                    //Outputs
                    .op(op_actual),
                    .common_data_bus_out(common_data_bus_out_actual),
                    .io_addr(io_addr_actual),
                    .cv_value(cv_value_actual));

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        //Expected outputs
        op_expected = 2'b0;
        common_data_bus_out_expected = 512'b0;
        io_addr_expected = 32'b0;
        cv_value_expected = 64'b0;
        //Input stimulus
        common_data_bus_in = 512'b0;
        tx_done = 1'b0;
        rd_valid = 1'b0;
        // load in our instructions into memory
        instrMemory[0] = 32'hA3001000; // LBI R6 <- 'h00003000;
        instrMemory[1] = 32'h43280002; // ADDI R5 ('h1002) <- R6('h1000) + ('h02)
        instrMemory[2] = 32'h93000000; // SLBI R6 zero filled so R6 = h'30000000
        instrMemory[3] = 32'h83280000; // ST Mem[R6 + 0 ('h30000000)] <- R5 ('h1002) //should cause a DMA request
        instrMemory[4] = 32'h8B200000; // LD R4 <- MEM [R6 + 0 'h30000000] R4('h1002) //should be a hit
        instrMemory[5] = 32'h10000000; // STARTF signum(0), filter (0)*/ //should cause accelerator request
        instrMemory[6] = 32'ha600000a; // LBI R12 <- 10 load 10 should work while accelerator is doing startF
        instrMemory[7] = 32'h10000000; // STARTF signum (0), filter (0) gets stalled while accelerator does work
        instrMemory[8] = 32'h00000000; //HALT (nothing after this gets executed)
        instrMemory[9] = 32'h00000000;
        instrMemory[10] = 32'h00000000;
        instrMemory[11] = 32'h00000000;
        instrMemory[12] = 32'h00000000;
        instrMemory[13] = 32'h00000000;
        instrMemory[14] = 32'h00000000;
        instrMemory[15] = 32'h00000000;
        instrMemory[16] = 32'h00000000;

        // load data and accel mem with acending values
        for (i = 0; i < 2048; i++) begin
            dataMemory[i] = i;
            accelMemory[i] = i;
        end

        //RESET
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        //START TESTING

        // wait some clk cycles simulate getting the instruction
        repeat(10) begin
            @(posedge clk);
            // INSTR_RD state
        end

        @(negedge clk);
        tx_done = 1'b1;
        common_data_bus_in = {  instrMemory[15],
                                instrMemory[14],
                                instrMemory[13],
                                instrMemory[12],
                                instrMemory[11],
                                instrMemory[10],
                                instrMemory[9],
                                instrMemory[8],
                                instrMemory[7],
                                instrMemory[6],
                                instrMemory[5],
                                instrMemory[4],
                                instrMemory[3],
                                instrMemory[2],
                                instrMemory[1],
                                instrMemory[0]
        };
        @(posedge clk);
        @(negedge clk);
        rd_valid = 1'b1;
        tx_done = 1'b0;
        @(posedge clk);
        @(negedge clk);
        rd_valid = 1'b0;
        // back to idle stage in mem_arb; instructions can start processing
        // will get a request from data cache now
        while (op_actual != 2'b01) begin
            @(posedge clk);
        end

        // Should be in DATA_RD state
        repeat(10) begin
            @(posedge clk);
        end
        @(negedge clk);
        common_data_bus_in = {  dataMemory[15],
                                dataMemory[14],
                                dataMemory[13],
                                dataMemory[12],
                                dataMemory[11],
                                dataMemory[10],
                                dataMemory[9],
                                dataMemory[8],
                                dataMemory[7],
                                dataMemory[6],
                                dataMemory[5],
                                dataMemory[4],
                                dataMemory[3],
                                dataMemory[2],
                                dataMemory[1],
                                dataMemory[0]};
        tx_done = 1'b1;

        @(posedge clk);
        @(negedge clk);
        tx_done = 1'b0;
        rd_valid = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rd_valid = 1'b0;
        @(posedge clk);
        @(negedge clk);
        // data should be in cache
        // startF should be executing soon.
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        


        if(errors == 0) begin
            $display("YAHOO! All Tests Passed!");
        end else begin
            $display("ARG! Yar code be blasted!");
        end


        $stop();
    end

    always #5 clk = ~clk;

endmodule