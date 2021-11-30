module alu_tb();

    logic [31:0] input1;
    logic [31:0] input2;
    logic [3:0] operation;
    logic [31:0] actualOutput;
    logic [31:0] expectedOutput;
    logic actualIsTaken;
    logic expectedIsTaken;

    int errors = 0;
    int i = 0;

    alu iALU(.A(input1),
             .B(input2),
             .op(operation),
             .out(actualOutput),
             .isTaken(actualIsTaken));

    initial begin

        //-------------- Test 1: Add Operation -----------------
        $display("Starting Test 1...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h0;
            expectedIsTaken = 1'b0;
            expectedOutput = input1 + input2;

            #5;

            if(expectedOutput != actualOutput || (expectedIsTaken != actualIsTaken))begin
                errors++;
                $display("Add operation failed");
            end
        end

        //------------- Test 2: Subtract Operation -------------
        $display("Starting Test 2...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h1;
            expectedIsTaken = 1'b0;
            expectedOutput = input2 - input1;

            #5;

            if(expectedOutput != actualOutput || (expectedIsTaken != actualIsTaken)) begin
                errors++;
                $display("Subtract operation failed");
            end
        end

        //----------- Test 3: XOR Operation -------------------- 
        $display("Starting Test 3...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h2;
            expectedIsTaken = 1'b0;
            expectedOutput = input1 ^ input2;

            #5;

            if(expectedOutput != actualOutput || (expectedIsTaken != actualIsTaken)) begin
                errors++;
                $display("XOR operation failed");
            end
        end

        //----------- Test 4: ANDN Operation -------------------- 
        $display("Starting Test 4...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h3;
            expectedIsTaken = 1'b0;
            expectedOutput = input1 & ~input2;

            #5;

            if(expectedOutput != actualOutput || (expectedIsTaken != actualIsTaken)) begin
                errors++;
                $display("ANDN operation failed");
            end
        end

        //----------- Test 5: BEQZ Operation -------------------- 
        $display("Starting Test 5...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h4;
            if(input1 == 32'h0)begin
                expectedIsTaken = 1'b1;
            end else begin
                expectedIsTaken = 1'b0;
            end

            #5;
            
            if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Equal Zero operation failed");
            end
        end
        //Explicitly Check that input = 0 sets isTaken 
        //(because rand might not cover it)
        input1 = 32'h0;
        expectedIsTaken = 1'b1;

        #5;
        
        if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Equal Zero operation failed");
        end

        //----------- Test 6: BNEZ Operation -------------------- 
        $display("Starting Test 6...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h5;
            if(input1 != 32'h0)begin
                expectedIsTaken = 1'b1;
            end else begin
                expectedIsTaken = 1'b0;
            end

            #5;
            
            if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Not Equal Zero operation failed");
            end
        end
        //Explicitly Check that input = 0 clears isTaken 
        //(because rand might not cover it)
        input1 = 32'h0;
        expectedIsTaken = 1'b0;

        #5;
        
        if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Not Equal Zero operation failed");
        end

        //----------- Test 7: BLTZ Operation -------------------- 
        $display("Starting Test 7...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h6;
            if(input1 < 32'b0)begin
                expectedIsTaken = 1'b1;
            end else begin
                expectedIsTaken = 1'b0;
            end

            #5;
            
            if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Less Than Zero operation failed");
            end
        end
        //Explicitly Check that input = 0 clear isTaken 
        //(because rand might not cover it)
        input1 = 32'h0;
        expectedIsTaken = 1'b0;

        #5;
        
        if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Less Than Zero operation failed");
        end

        //----------- Test 8: BGEZ Operation -------------------- 
        $display("Starting Test 8...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h7;
            if(input1 >= 32'h0)begin
                expectedIsTaken = 1'b1;
            end else begin
                expectedIsTaken = 1'b0;
            end

            #5;
            
            if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Greater Than Or Equal Zero operation failed");
            end
        end
        //Explicitly Check that input = 0 sets isTaken 
        //(because rand might not cover it)
        input1 = 32'h0;
        expectedIsTaken = 1'b1;

        #5;
        
        if(expectedIsTaken != actualIsTaken) begin
                errors++;
                $display("Branch Greater Than Or Equal Zero operation failed");
        end

        //----------- Test 9: Equal Operation -------------------- 
        $display("Starting Test 9...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h8;
            expectedIsTaken = 1'b0;

            if(input1 == input2)begin
                expectedOutput = 32'h1;
            end else begin
                expectedOutput = 32'h0;
            end

            #5;
            
            if((expectedOutput != actualOutput) || (expectedIsTaken != actualIsTaken)) begin
                errors++;
                $display("Equal operation failed");
            end
        end
        //Explicitly Check that input1 == input2 sets output 
        //(because rand might not cover it)
        input1 = 32'hABCD;
        input2 = 32'hABCD;
        expectedOutput = 32'h1;

        #5;
        
        if(expectedOutput != actualOutput || (expectedIsTaken != actualIsTaken)) begin
                errors++;
                $display("Equal operation failed");
        end

        //----------- Test 10: Less Than Operation -------------------- 
        $display("Starting Test 10...");

        for(i = 0; i < 16; i++) begin
            input1 = $random();
            input2 = $random();
            operation = 4'h9;
            expectedIsTaken = 1'b0;

            if(input1 < input2)begin
                expectedOutput = 32'h1;
            end else begin
                expectedOutput = 32'h0;
            end

            #5;
            
            if(expectedOutput != actualOutput || (expectedIsTaken != actualIsTaken)) begin
                errors++;
                $display("Less Than operation failed");
            end
        end
        //Explicitly Check that input1 == input2 clears output 
        //(because rand might not cover it)
        input1 = 32'h4657;
        input2 = 32'h3647;
        expectedOutput = 32'h0;

        #5;
        
        if(expectedIsTaken != actualIsTaken || (expectedIsTaken != actualIsTaken)) begin
                errors++;
                $display("Less Than operation failed");
        end

        if(errors == 0) begin
            $display("YAHOO! All tests passed");
        end else begin
            $display("DARN! Your code be blasted");
        end

        $stop();
    end

    `include "tb_tasks.txt"

endmodule