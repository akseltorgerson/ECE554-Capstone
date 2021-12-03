module address_generator_tb();
    /// intermediates
    logic [4:0] stageCount;
    logic [8:0] cycleCount, cycleCount_spec;
    logic [9:0] indexA, indexB, indexB_exp, indexA_exp;
    logic [8:0] twiddleIndex;
    integer bucket, bucketsMAX, cycleLimit, startingPos, bucketIterationCnt;    // bucket refers to which DFT the cycle iteration refers to
    logic clk;

    address_generator iDUT(.*);

    always #5 clk = ~clk;

    assign bucketsMAX = 2 ** stageCount;
    assign cycleLimit = 512 / bucketsMAX;
    assign startingPos = bucket == 0 ? bucket : (1024 / (2 ** (bucketsMAX - bucket)));
    assign indexB_exp = indexA + (512 >> stageCount);

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

        // check stage 1
        stageCount = 1;
        cycleCount = 0;

        // should go through each "Bucket" and compute the correct indices.  
        for (bucket = 0; bucket < bucketsMAX && cycleCount < 511; bucket++) begin
            for(bucketIterationCnt = 0; bucketIterationCnt < cycleLimit; bucketIterationCnt++) begin

                indexA_exp = startingPos + bucketIterationCnt;

                @(posedge clk);

                if (indexA != (startingPos + bucketIterationCnt)) begin
                    $display("ERROR: FUCK YOU. EAT CUM");
                    $stop();
                end

                cycleCount++;
            end
        end

        $display("YAHOOOO! Test passed!");
        $stop();
    end

endmodule