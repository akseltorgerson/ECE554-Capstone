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
    logic j;
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
        instrMemory[0] = 32'hA3003000; // LBI R6 <- 'h00003000;
        instrMemory[1] = 32'h43280002; // ADDI R5 ('h3002) <- R6('h3000) + ('h02)
        instrMemory[2] = 32'h93000000; // SLBI R6 zero filled so R6 = h'30000000
        instrMemory[3] = 32'h83280000; // ST Mem[R6 + 0 ('h30000000)] <- R5 ('h3002) //should cause a DMA request
        instrMemory[4] = 32'h8B200000; // LD R4 <- MEM [R6 + 0 'h30000000] R4('h3002) //should be a hit
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
        //SHOULD BE ON LBI INSTRUCTION HERE
        //Check LBI signals
        if(iProcessor.iCPU.instruction != 32'hA3003000 || iProcessor.iCPU.iDecode.rsWrite != 1'b1 || iProcessor.iCPU.iDecode.regWrite != 1'b1 || iProcessor.iCPU.iDecode.writeData != 32'h3000 || iProcessor.iCPU.iDecode.writeRegSel != 4'b0110) begin
            errors++;
            $display("FAILED LBI TEST");
        end

        @(posedge clk);
        @(negedge clk);
        //Check ADDI Signals
        if(iProcessor.iCPU.instruction != 32'h43280002 || iProcessor.iCPU.iDecode.isIType1 != 1'b1 || iProcessor.iCPU.iDecode.isSignExtend != 1'b1 || iProcessor.iCPU.iDecode.regWrite != 1'b1 || iProcessor.iCPU.iDecode.writeData != 32'h3002 || iProcessor.iCPU.iDecode.writeRegSel != 4'b0101) begin
            errors++;
            $display("FAILED ADDI TEST");
        end

        @(posedge clk);
        @(negedge clk);
        //Check SLBI Signals
        if(iProcessor.iCPU.instruction != 32'h93000000 || iProcessor.iCPU.iDecode.isSLBI != 1'b1 || iProcessor.iCPU.iDecode.rsWrite != 1'b1  || iProcessor.iCPU.iDecode.regWrite != 1'b1 || iProcessor.iCPU.iDecode.writeData != 32'h30000000 || iProcessor.iCPU.iDecode.writeRegSel != 4'b0110) begin
            errors++;
            $display("FAILED SLBI TEST");
        end

        @(posedge clk);
        @(negedge clk);
        //Check SLBI Signals
        if(iProcessor.iCPU.instruction != 32'h83280000 || iProcessor.iCPU.iDecode.isSignExtend != 1'b1 || iProcessor.iCPU.iDecode.isIType1 != 1'b1  || iProcessor.iCPU.iDecode.memWrite != 1'b1) begin
            errors++;
            $display("FAILED SLBI TEST");
        end

        @(posedge clk);
        @(negedge clk);
        //Check ST Signals again to show that the processor has stalled since there should be a data cache miss
        if(iProcessor.iCPU.instruction != 32'h83280000 || iProcessor.iCPU.iDecode.isSignExtend != 1'b1 || iProcessor.iCPU.iDecode.isIType1 != 1'b1  || iProcessor.iCPU.iDecode.memWrite != 1'b1) begin
            errors++;
            $display("FAILED ST TEST");
        end

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
        while (op_actual != 2'b01) begin
            @(posedge clk);
        end

        // In accel rd stage now
        if (io_addr_actual != 32'h1000_0000) begin
            $display("ERROR: IO_ADDR Expected: %32h, Got: %32h", 32'h1000_0000, io_addr_actual);
            errors += 1;
        end

        j = 1'b0;
        @(negedge clk);
        repeat (128) begin
            tx_done = 1'b1;
            common_data_bus_in = {  accelMemory[j*16]+15,
                                    accelMemory[j*16]+14,
                                    accelMemory[j*16]+13,
                                    accelMemory[j*16]+12,
                                    accelMemory[j*16]+11,
                                    accelMemory[j*16]+10,
                                    accelMemory[j*16]+9,
                                    accelMemory[j*16]+8,
                                    accelMemory[j*16]+7,
                                    accelMemory[j*16]+6,
                                    accelMemory[j*16]+5,
                                    accelMemory[j*16]+4,
                                    accelMemory[j*16]+3,
                                    accelMemory[j*16]+2,
                                    accelMemory[j*16]+1,
                                    accelMemory[j*16]+0};
            @(posedge clk);
            // ACCEL_RD_DONE stage
            @(negedge clk);
            tx_done = 1'b0;
            rd_valid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            rd_valid = 1'b0;
            j += 1;
        end

        // Arb should go back to idle here
        //repeat (1040) begin
            // tons of data being loaded into the buffer,
            // should start transform process
        //    @(posedge clk);
        //end

        while (op_actual != 2'b11) begin
            @(posedge clk);
        end

        j = 0;
        @(negedge clk);
        // now we in accel_wr stage
        repeat (128) begin
            tx_done = 1'b1;
            accelMemory[(j*16)+0] = common_data_bus_out_actual[31:0];
            accelMemory[(j*16)+1] = common_data_bus_out_actual[63:32];
            accelMemory[(j*16)+3] = common_data_bus_out_actual[95:64];
            accelMemory[(j*16)+3] = common_data_bus_out_actual[127:96];
            accelMemory[(j*16)+4] = common_data_bus_out_actual[159:128];
            accelMemory[(j*16)+5] = common_data_bus_out_actual[191:160];
            accelMemory[(j*16)+6] = common_data_bus_out_actual[223:192];
            accelMemory[(j*16)+7] = common_data_bus_out_actual[255:224];
            accelMemory[(j*16)+8] = common_data_bus_out_actual[287:256];
            accelMemory[(j*16)+9] = common_data_bus_out_actual[319:288];
            accelMemory[(j*16)+10] = common_data_bus_out_actual[351:320];
            accelMemory[(j*16)+11] = common_data_bus_out_actual[383:352];
            accelMemory[(j*16)+12] = common_data_bus_out_actual[415:384];
            accelMemory[(j*16)+13] = common_data_bus_out_actual[447:416];
            accelMemory[(j*16)+14] = common_data_bus_out_actual[479:448];
            accelMemory[(j*16)+15] = common_data_bus_out_actual[511:480];
            @(posedge clk);
            @(negedge clk);
            tx_done = 1'b0;
            @(posedge clk);
            @(negedge clk);
            j += 1;
        end 


        
        if(errors == 0) begin
            $display("YAHOO! All Tests Passed!");
        end else begin
            $display("ARG! Yar code be blasted!");
        end


        $stop();
    end

    always #5 clk = ~clk;

endmodule