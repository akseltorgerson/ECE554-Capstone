module address_generator_tb();
    /// intermediates
    logic [4:0] stageCount;
    logic [8:0] cycleCount, cycleCount_spec;
    logic [9:0] indexA, indexB, indexB_exp, indexA_exp;
    logic [8:0] twiddleIndex, twiddleIndex_int, twiddleIndex_exp;
    integer bucket, bucketsMAX, cycleLimit, startingPos, bucketIterationCnt, dftSize;    // bucket refers to which DFT the cycle iteration refers to
    logic clk;

    address_generator iDUT(.*);

    always #5 clk = ~clk;

    assign bucketsMAX = 2 ** stageCount;
    assign cycleLimit = 512 / bucketsMAX;
    assign dftSize = 1024 / bucketsMAX;
    assign startingPos = bucket * dftSize;
    assign indexB_exp = indexA + (512 >> stageCount);
    assign twiddleIndex_int = $floor(cycleCount * (2 ** (stageCount + 1)) / 1024);
    assign twiddleIndex_exp = {twiddleIndex_int[0], 
                           twiddleIndex_int[1],
                           twiddleIndex_int[2],
                           twiddleIndex_int[3],
                           twiddleIndex_int[4],
                           twiddleIndex_int[5],
                           twiddleIndex_int[6],
                           twiddleIndex_int[7],
                           twiddleIndex_int[8]};

    initial begin
        clk = 0;
        indexA_exp = 0;
        stageCount = 0;
        cycleCount = 0;

        // initial check
        // check everything in stage 0. indexA = cycleCount and indexB = indexA + 512
        for (cycleCount = 0; cycleCount < 511; cycleCount = cycleCount + 1) begin
            @(posedge clk);

            if (indexA != cycleCount && indexB != (indexA + 512)) begin
                $display("ERROR: Stage 0, indexA or indexB incorrect");
                $stop();
            end

            if (twiddleIndex != 0) begin
                $display("ERROR: Stage 0, twiddleIndex incorrect");
                $stop();
            end
        end

        for (stageCount = 0; stageCount < 10; stageCount ++) begin
            cycleCount = 0;
            // should go through each "Bucket" and compute the correct indices.  
            for (bucket = 0; bucket < bucketsMAX && cycleCount < 512; bucket++) begin
                for(bucketIterationCnt = 0; bucketIterationCnt < cycleLimit; bucketIterationCnt++) begin

                    indexA_exp = startingPos + bucketIterationCnt;

                    @(posedge clk);

                    if (indexA != (startingPos + bucketIterationCnt)) begin
                        $display("ERROR: Index A: %d Expected: %d", indexA, indexA_exp);
                        $stop();
                    end


                    if (indexB != indexB_exp) begin
                        $display("ERROR: Index B: %d Expected: %d", indexB, indexB_exp);
                        $stop();
                    end

                    if (twiddleIndex != twiddleIndex_exp) begin
                        $display("ERROR: Twiddle Index: %d Expected: %d", twiddleIndex, twiddleIndex_exp);
                        $stop();
                    end

                    cycleCount++;
                end
            end
        end

        $display("YAHOOOO! Test passed!");
        $stop();
    end

endmodule