module  address_generator
    #(
        NUM_FACTORS=512,
        FFT_SIZE=1024
    )
    (
        input [4:0] stageCount,
        input [8:0] cycleCount,
        output [9:0] indexA, indexB,
        output [8:0] twiddleIndex
    );

    // log2 function
    function [31:0] log2;
        input [31:0] value;
        integer i;
        reg [31:0] j;
        begin
            j = value - 1;
            log2 = 0;
            for (i = 0; i < 31; i = i + 1)
                if (j[i]) log2 = i+1;
        end
    endfunction

    ////////////////////////
    ///// localparams //////
    ////////////////////////

    localparam [4:0] numFactorBits = log2(FFT_SIZE);

    /////////////////////////
    ///// intermediates /////
    /////////////////////////

    logic [8:0] twiddle_int;
    logic [8:0] shiftNumber;
    logic [18:0] numerator;
    logic [9:0] indexA_reg;
    logic [4:0] stagePlus1;

    //////////////////
    ///// comb logic ////
    //////////////////

    assign stagePlus1 = stageCount + 5'b00001;
    assign shiftNumber = {4'b0000, stagePlus1};
    assign numerator = (cycleCount << shiftNumber);
    assign twiddle_int = {numerator >> 10}[8:0];
    
    // Bit Reversal
    assign twiddleIndex = {twiddle_int[0], 
                           twiddle_int[1],
                           twiddle_int[2],
                           twiddle_int[3],
                           twiddle_int[4],
                           twiddle_int[5],
                           twiddle_int[6],
                           twiddle_int[7],
                           twiddle_int[8]};

    // which DFT the current cycle falls into
    assign indexB = indexA_reg + (NUM_FACTORS >> stageCount);
    assign indexA = indexA_reg;

    //////// Hardcoded address algorithm ////////
    always @(stageCount or cycleCount) begin
        indexA_reg = 10'h000;

        case(stageCount)
            5'h00: begin
                indexA_reg = cycleCount;
            end
            5'h01: begin
                indexA_reg = {cycleCount[8], 1'b0, cycleCount[7:0]};
            end
            5'h02: begin
                indexA_reg = {cycleCount[8:7], 1'b0, cycleCount[6:0]};
            end
            5'h03: begin
               indexA_reg = {cycleCount[8:6], 1'b0, cycleCount[5:0]};
            end
            5'h04: begin
                indexA_reg = {cycleCount[8:5], 1'b0, cycleCount[4:0]};
            end
            5'h05: begin
                indexA_reg = {cycleCount[8:4], 1'b0, cycleCount[3:0]};
            end
            5'h06: begin
                indexA_reg = {cycleCount[8:3], 1'b0, cycleCount[2:0]};
            end
            5'h07: begin
                indexA_reg = {cycleCount[8:2], 1'b0, cycleCount[1:0]};
            end
            5'h08: begin
                indexA_reg = {cycleCount[8:1], 1'b0, cycleCount[0]};
            end
            5'h09: begin
                indexA_reg = {cycleCount, 1'b0};
            end
        endcase
    end
    
endmodule