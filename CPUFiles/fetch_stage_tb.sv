module fetch_stage_tb();

    // input signals
    logic clk, rst, halt;
    logic stallDMAMem;
    logic blockInstruction;
    logic mcDataValid;
    logic [511:0] mcDataIn;
    logic [31:0] nextPC;
    
    // output signals
    logic [31:0] instr;
    logic [31:0] pcPlus4;
    logic cacheMiss;

    // other signals
    integer errors;

    fetch_stage iFetchStage(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        halt = 1'b0;
        stallDMAMem = 1'b0;
        blockInstruction = 1'b0;
        mcDataValid = 1'b0;
        mcDataIn = 512'b0;
        nextPC = 32'b0;

        errors = 0;

        // RESET
        @(posedge clk);
        @(negedge clk);
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // If we are missing at our current PC
        if (cacheMiss) begin

            // Wait some clocks, CacheMiss should still be asserted
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);

            // Should be a miss
            if (!cacheMiss) begin
                $display("ERROR: Cache Hit");
                errors += 1;
            end

            // MEM CTRL got the request and returned data
            mcDataValid = 1'b1;
            // Supply random 512 bit value rn
            mcDataIn = {$urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom()};

            @(posedge clk);
            mcDataValid = 1'b0;
            @(posedge clk);

            mcDataValid = 1'b0;

            // Shouldnt be a miss
            if (cacheMiss) begin
                $display("ERROR: Cache Miss");
                errors += 1;
            end

        end else begin
            $display("ERROR: Should be a cold miss");
            errors += 1;
        end

        if (errors != 0) begin
            $display("TEST FAILED: %d ERROR(S)", errors);
        end else begin
            $display("TEST PASSED");
        end

        $stop();

    end

endmodule