module  address_generator
    #(
        NUM_FACTORS=512
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

    localparam [4:0] numFactorBits = log2(NUM_FACTORS);

    /////////////////////////
    ///// intermediates /////
    /////////////////////////

    logic [8:0] twiddle_int;
    logic [9:0] indexA_reg;
    logic [4:0] stageDifference;

    //////////////////
    ///// modules ////
    //////////////////

    assign stageDifference = (stageCount - numFactorBits);

    assign twiddle_int = ~stageDifference[5] ? 
                            cycleCount << {4'b0000, stageDifference} : 
                            cycleCount >> {4'b0000, (~stageDifference + 5'b00001)};
    
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
                casez(cycleCount)
                    9'b00???????: begin
                        indexA_reg = {3'b000, cycleCount[6:0]};
                    end
                    9'b01???????: begin
                        indexA_reg = {3'b010, cycleCount[6:0]};
                    end
                    9'b10???????: begin
                        indexA_reg = {3'b100, cycleCount[6:0]};
                    end
                    9'b11???????: begin
                        indexA_reg = {3'b110, cycleCount[6:0]};
                    end
                endcase
            end
            5'h03: begin
                casez(cycleCount)
                    9'b000??????: begin
                        indexA_reg = {4'b0000, cycleCount[5:0]};
                    end
                    9'b001??????: begin
                        indexA_reg = {4'b0010, cycleCount[5:0]};
                    end
                    9'b010??????: begin
                        indexA_reg = {4'b0100, cycleCount[5:0]};
                    end
                    9'b011??????: begin
                        indexA_reg = {4'b0110, cycleCount[5:0]};
                    end
                    9'b100??????: begin
                        indexA_reg = {4'b1000, cycleCount[5:0]};
                    end
                    9'b101??????: begin
                        indexA_reg = {4'b1010, cycleCount[5:0]};
                    end
                    9'b110??????: begin
                        indexA_reg = {4'b1100, cycleCount[5:0]};
                    end
                    9'b111??????: begin
                        indexA_reg = {4'b1110, cycleCount[5:0]};
                    end
                endcase
            end
            5'h04: begin
                casez(cycleCount)
                    9'b0000?????: begin
                        indexA_reg = {5'b00000, cycleCount[4:0]};
                    end
                    9'b0001?????: begin
                        indexA_reg = {5'b00010, cycleCount[4:0]};
                    end
                    9'b0010?????: begin
                        indexA_reg = {5'b00100, cycleCount[4:0]};
                    end
                    9'b0011?????: begin
                        indexA_reg = {5'b00110, cycleCount[4:0]};
                    end
                    9'b0100?????: begin
                        indexA_reg = {5'b01000, cycleCount[4:0]};
                    end
                    9'b0101?????: begin
                        indexA_reg = {5'b01010, cycleCount[4:0]};
                    end
                    9'b0110?????: begin
                        indexA_reg = {5'b01100, cycleCount[4:0]};
                    end
                    9'b0111?????: begin
                        indexA_reg = {5'b01110, cycleCount[4:0]};
                    end
                    9'b1000?????: begin
                        indexA_reg = {5'b10000, cycleCount[4:0]};
                    end
                    9'b1001?????: begin
                        indexA_reg = {5'b10010, cycleCount[4:0]};
                    end
                    9'b1010?????: begin
                        indexA_reg = {5'b10100, cycleCount[4:0]};
                    end
                    9'b1011?????: begin
                        indexA_reg = {5'b10110, cycleCount[4:0]};
                    end
                    9'b1100?????: begin
                        indexA_reg = {5'b11000, cycleCount[4:0]};
                    end
                    9'b1101?????: begin
                        indexA_reg = {5'b11010, cycleCount[4:0]};
                    end
                    9'b1110?????: begin
                        indexA_reg = {5'b11100, cycleCount[4:0]};
                    end
                    9'b1111?????: begin
                        indexA_reg = {5'b11110, cycleCount[4:0]};
                    end
                endcase
            end
            5'h05: begin
                casez(cycleCount)
                    9'b00000????: begin
                        indexA_reg = {6'b000000, cycleCount[3:0]};
                    end
                    9'b00001????: begin
                        indexA_reg = {6'b000010, cycleCount[3:0]};
                    end
                    9'b00010????: begin
                        indexA_reg = {6'b000100, cycleCount[3:0]};
                    end
                    9'b00011????: begin
                        indexA_reg = {6'b000110, cycleCount[3:0]};
                    end
                    9'b00100????: begin
                        indexA_reg = {6'b001000, cycleCount[3:0]};
                    end
                    9'b00101????: begin
                        indexA_reg = {6'b001010, cycleCount[3:0]};
                    end
                    9'b00110????: begin
                        indexA_reg = {6'b001100, cycleCount[3:0]};
                    end
                    9'b00111????: begin
                        indexA_reg = {6'b001110, cycleCount[3:0]};
                    end
                    9'b01000????: begin
                        indexA_reg = {6'b010000, cycleCount[3:0]};
                    end
                    9'b01001????: begin
                        indexA_reg = {6'b010010, cycleCount[3:0]};
                    end
                    9'b01010????: begin
                        indexA_reg = {6'b010100, cycleCount[3:0]};
                    end
                    9'b01011????: begin
                        indexA_reg = {6'b010110, cycleCount[3:0]};
                    end
                    9'b01100????: begin
                        indexA_reg = {6'b011000, cycleCount[3:0]};
                    end
                    9'b01101????: begin
                        indexA_reg = {6'b011010, cycleCount[3:0]};
                    end
                    9'b01110????: begin
                        indexA_reg = {6'b011100, cycleCount[3:0]};
                    end
                    9'b01111????: begin
                        indexA_reg = {6'b011110, cycleCount[3:0]};
                    end
                    ///////
                    9'b10000????: begin
                        indexA_reg = {6'b100000, cycleCount[3:0]};
                    end
                    9'b10001????: begin
                        indexA_reg = {6'b100010, cycleCount[3:0]};
                    end
                    9'b10010????: begin
                        indexA_reg = {6'b100100, cycleCount[3:0]};
                    end
                    9'b10011????: begin
                        indexA_reg = {6'b100110, cycleCount[3:0]};
                    end
                    9'b10100????: begin
                        indexA_reg = {6'b101000, cycleCount[3:0]};
                    end
                    9'b10101????: begin
                        indexA_reg = {6'b101010, cycleCount[3:0]};
                    end
                    9'b10110????: begin
                        indexA_reg = {6'b101100, cycleCount[3:0]};
                    end
                    9'b10111????: begin
                        indexA_reg = {6'b101110, cycleCount[3:0]};
                    end
                    9'b11000????: begin
                        indexA_reg = {6'b110000, cycleCount[3:0]};
                    end
                    9'b11001????: begin
                        indexA_reg = {6'b110010, cycleCount[3:0]};
                    end
                    9'b11010????: begin
                        indexA_reg = {6'b110100, cycleCount[3:0]};
                    end
                    9'b11011????: begin
                        indexA_reg = {6'b110110, cycleCount[3:0]};
                    end
                    9'b11100????: begin
                        indexA_reg = {6'b111000, cycleCount[3:0]};
                    end
                    9'b11101????: begin
                        indexA_reg = {6'b111010, cycleCount[3:0]};
                    end
                    9'b11110????: begin
                        indexA_reg = {6'b111100, cycleCount[3:0]};
                    end
                    9'b11111????: begin
                        indexA_reg = {6'b111110, cycleCount[3:0]};
                    end
                endcase
            end
            5'h06: begin
                casez(cycleCount)
                    9'b000000???: begin
                        indexA_reg = {7'b0000000, cycleCount[2:0]};
                    end
                    9'b000001???: begin
                        indexA_reg = {7'b0000010, cycleCount[2:0]};
                    end
                    9'b000010???: begin
                        indexA_reg = {7'b0000100, cycleCount[2:0]};
                    end
                    9'b000011???: begin
                        indexA_reg = {7'b0000110, cycleCount[2:0]};
                    end
                    9'b000100???: begin
                        indexA_reg = {7'b0001000, cycleCount[2:0]};
                    end
                    9'b000101???: begin
                        indexA_reg = {7'b0001010, cycleCount[2:0]};
                    end
                    9'b000110???: begin
                        indexA_reg = {7'b0001100, cycleCount[2:0]};
                    end
                    9'b000111???: begin
                        indexA_reg = {7'b0001110, cycleCount[2:0]};
                    end
                    9'b001000???: begin
                        indexA_reg = {7'b0010000, cycleCount[2:0]};
                    end
                    9'b001001???: begin
                        indexA_reg = {7'b0010010, cycleCount[2:0]};
                    end
                    9'b001010???: begin
                        indexA_reg = {7'b0010100, cycleCount[2:0]};
                    end
                    9'b001011???: begin
                        indexA_reg = {7'b0010110, cycleCount[2:0]};
                    end
                    9'b001100???: begin
                        indexA_reg = {7'b0011000, cycleCount[2:0]};
                    end
                    9'b001101???: begin
                        indexA_reg = {7'b0011010, cycleCount[2:0]};
                    end
                    9'b001110???: begin
                        indexA_reg = {7'b0011100, cycleCount[2:0]};
                    end
                    9'b001111???: begin
                        indexA_reg = {7'b0011110, cycleCount[2:0]};
                    end
                    9'b010000???: begin
                        indexA_reg = {7'b0100000, cycleCount[2:0]};
                    end
                    9'b010001???: begin
                        indexA_reg = {7'b0100010, cycleCount[2:0]};
                    end
                    9'b010010???: begin
                        indexA_reg = {7'b0100100, cycleCount[2:0]};
                    end
                    9'b010011???: begin
                        indexA_reg = {7'b0100110, cycleCount[2:0]};
                    end
                    9'b010100???: begin
                        indexA_reg = {7'b0101000, cycleCount[2:0]};
                    end
                    9'b010101???: begin
                        indexA_reg = {7'b0101010, cycleCount[2:0]};
                    end
                    9'b010110???: begin
                        indexA_reg = {7'b0101100, cycleCount[2:0]};
                    end
                    9'b010111???: begin
                        indexA_reg = {7'b0101110, cycleCount[2:0]};
                    end
                    9'b011000???: begin
                        indexA_reg = {7'b0110000, cycleCount[2:0]};
                    end
                    9'b011001???: begin
                        indexA_reg = {7'b0110010, cycleCount[2:0]};
                    end
                    9'b011010???: begin
                        indexA_reg = {7'b0110100, cycleCount[2:0]};
                    end
                    9'b011011???: begin
                        indexA_reg = {7'b0110110, cycleCount[2:0]};
                    end
                    9'b011100???: begin
                        indexA_reg = {7'b0111000, cycleCount[2:0]};
                    end
                    9'b011101???: begin
                        indexA_reg = {7'b0111010, cycleCount[2:0]};
                    end
                    9'b011110???: begin
                        indexA_reg = {7'b0111100, cycleCount[2:0]};
                    end
                    9'b011111???: begin
                        indexA_reg = {7'b0111110, cycleCount[2:0]};
                    end
                    //////////////////
                    9'b100000???: begin
                        indexA_reg = {7'b1000000, cycleCount[2:0]};
                    end
                    9'b100001???: begin
                        indexA_reg = {7'b1000010, cycleCount[2:0]};
                    end
                    9'b100010???: begin
                        indexA_reg = {7'b1000100, cycleCount[2:0]};
                    end
                    9'b100011???: begin
                        indexA_reg = {7'b1000110, cycleCount[2:0]};
                    end
                    9'b100100???: begin
                        indexA_reg = {7'b1001000, cycleCount[2:0]};
                    end
                    9'b100101???: begin
                        indexA_reg = {7'b1001010, cycleCount[2:0]};
                    end
                    9'b100110???: begin
                        indexA_reg = {7'b1001100, cycleCount[2:0]};
                    end
                    9'b100111???: begin
                        indexA_reg = {7'b1001110, cycleCount[2:0]};
                    end
                    9'b101000???: begin
                        indexA_reg = {7'b1010000, cycleCount[2:0]};
                    end
                    9'b001001???: begin
                        indexA_reg = {7'b1010010, cycleCount[2:0]};
                    end
                    9'b101010???: begin
                        indexA_reg = {7'b1010100, cycleCount[2:0]};
                    end
                    9'b101011???: begin
                        indexA_reg = {7'b1010110, cycleCount[2:0]};
                    end
                    9'b101100???: begin
                        indexA_reg = {7'b1011000, cycleCount[2:0]};
                    end
                    9'b101101???: begin
                        indexA_reg = {7'b1011010, cycleCount[2:0]};
                    end
                    9'b101110???: begin
                        indexA_reg = {7'b1011100, cycleCount[2:0]};
                    end
                    9'b101111???: begin
                        indexA_reg = {7'b1011110, cycleCount[2:0]};
                    end
                    9'b110000???: begin
                        indexA_reg = {7'b1100000, cycleCount[2:0]};
                    end
                    9'b110001???: begin
                        indexA_reg = {7'b1100010, cycleCount[2:0]};
                    end
                    9'b110010???: begin
                        indexA_reg = {7'b1100100, cycleCount[2:0]};
                    end
                    9'b110011???: begin
                        indexA_reg = {7'b1100110, cycleCount[2:0]};
                    end
                    9'b110100???: begin
                        indexA_reg = {7'b1101000, cycleCount[2:0]};
                    end
                    9'b110101???: begin
                        indexA_reg = {7'b1101010, cycleCount[2:0]};
                    end
                    9'b110110???: begin
                        indexA_reg = {7'b1101100, cycleCount[2:0]};
                    end
                    9'b110111???: begin
                        indexA_reg = {7'b1101110, cycleCount[2:0]};
                    end
                    9'b111000???: begin
                        indexA_reg = {7'b1110000, cycleCount[2:0]};
                    end
                    9'b111001???: begin
                        indexA_reg = {7'b1110010, cycleCount[2:0]};
                    end
                    9'b111010???: begin
                        indexA_reg = {7'b1110100, cycleCount[2:0]};
                    end
                    9'b111011???: begin
                        indexA_reg = {7'b1110110, cycleCount[2:0]};
                    end
                    9'b111100???: begin
                        indexA_reg = {7'b1111000, cycleCount[2:0]};
                    end
                    9'b111101???: begin
                        indexA_reg = {7'b1111010, cycleCount[2:0]};
                    end
                    9'b111110???: begin
                        indexA_reg = {7'b1111100, cycleCount[2:0]};
                    end
                    9'b111111???: begin
                        indexA_reg = {7'b1111110, cycleCount[2:0]};
                    end
                endcase
            end
            5'h07: begin
                casez(cycleCount)
                    9'b0000000??: begin
                        indexA_reg = {8'b00000000, cycleCount[1:0]};
                    end
                    9'b0000001??: begin
                        indexA_reg = {8'b00000010, cycleCount[1:0]};
                    end
                    9'b0000010??: begin
                        indexA_reg = {8'b00000100, cycleCount[1:0]};
                    end
                    9'b0000011??: begin
                        indexA_reg = {8'b00000110, cycleCount[1:0]};
                    end
                    9'b0000100??: begin
                        indexA_reg = {8'b00001000, cycleCount[1:0]};
                    end
                    9'b0000101??: begin
                        indexA_reg = {8'b00001010, cycleCount[1:0]};
                    end
                    9'b0000110??: begin
                        indexA_reg = {8'b00001100, cycleCount[1:0]};
                    end
                    9'b0000111??: begin
                        indexA_reg = {8'b00001110, cycleCount[1:0]};
                    end
                    9'b0001000??: begin
                        indexA_reg = {8'b00010000, cycleCount[1:0]};
                    end
                    9'b0001001??: begin
                        indexA_reg = {8'b00010010, cycleCount[1:0]};
                    end
                    9'b0001010??: begin
                        indexA_reg = {8'b00010100, cycleCount[1:0]};
                    end
                    9'b0001011??: begin
                        indexA_reg = {8'b00010110, cycleCount[1:0]};
                    end
                    9'b0001100??: begin
                        indexA_reg = {8'b00011000, cycleCount[1:0]};
                    end
                    9'b0001101??: begin
                        indexA_reg = {8'b00011010, cycleCount[1:0]};
                    end
                    9'b0001110??: begin
                        indexA_reg = {8'b00011100, cycleCount[1:0]};
                    end
                    9'b0001111??: begin
                        indexA_reg = {8'b00011110, cycleCount[1:0]};
                    end
                    9'b0010000??: begin
                        indexA_reg = {8'b00100000, cycleCount[1:0]};
                    end
                    9'b0010001??: begin
                        indexA_reg = {8'b00100010, cycleCount[1:0]};
                    end
                    9'b0010010??: begin
                        indexA_reg = {8'b00100100, cycleCount[1:0]};
                    end
                    9'b0010011??: begin
                        indexA_reg = {8'b00100110, cycleCount[1:0]};
                    end
                    9'b0010100??: begin
                        indexA_reg = {8'b00101000, cycleCount[1:0]};
                    end
                    9'b0010101??: begin
                        indexA_reg = {8'b00101010, cycleCount[1:0]};
                    end
                    9'b0010110??: begin
                        indexA_reg = {8'b00101100, cycleCount[1:0]};
                    end
                    9'b0010111??: begin
                        indexA_reg = {8'b00101110, cycleCount[1:0]};
                    end
                    9'b0011000??: begin
                        indexA_reg = {8'b00110000, cycleCount[1:0]};
                    end
                    9'b0011001??: begin
                        indexA_reg = {8'b00110010, cycleCount[1:0]};
                    end
                    9'b0011010??: begin
                        indexA_reg = {8'b00110100, cycleCount[1:0]};
                    end
                    9'b0011011??: begin
                        indexA_reg = {8'b00110110, cycleCount[1:0]};
                    end
                    9'b0011100??: begin
                        indexA_reg = {8'b00111000, cycleCount[1:0]};
                    end
                    9'b0011101??: begin
                        indexA_reg = {8'b00111010, cycleCount[1:0]};
                    end
                    9'b0011110??: begin
                        indexA_reg = {8'b00111100, cycleCount[1:0]};
                    end
                    9'b0011111??: begin
                        indexA_reg = {8'b00111110, cycleCount[1:0]};
                    end
                    9'b0100000??: begin
                        indexA_reg = {8'b01000000, cycleCount[1:0]};
                    end
                    9'b0100001??: begin
                        indexA_reg = {8'b01000010, cycleCount[1:0]};
                    end
                    9'b0100010??: begin
                        indexA_reg = {8'b01000100, cycleCount[1:0]};
                    end
                    9'b0100011??: begin
                        indexA_reg = {8'b01000110, cycleCount[1:0]};
                    end
                    9'b0100100??: begin
                        indexA_reg = {8'b01001000, cycleCount[1:0]};
                    end
                    9'b0100101??: begin
                        indexA_reg = {8'b01001010, cycleCount[1:0]};
                    end
                    9'b0100110??: begin
                        indexA_reg = {8'b01001100, cycleCount[1:0]};
                    end
                    9'b0100111??: begin
                        indexA_reg = {8'b01001110, cycleCount[1:0]};
                    end
                    9'b0101000??: begin
                        indexA_reg = {8'b01010000, cycleCount[1:0]};
                    end
                    9'b0001001??: begin
                        indexA_reg = {8'b01010010, cycleCount[1:0]};
                    end
                    9'b0101010??: begin
                        indexA_reg = {8'b01010100, cycleCount[1:0]};
                    end
                    9'b0101011??: begin
                        indexA_reg = {8'b01010110, cycleCount[1:0]};
                    end
                    9'b0101100??: begin
                        indexA_reg = {8'b01011000, cycleCount[1:0]};
                    end
                    9'b0101101??: begin
                        indexA_reg = {8'b01011010, cycleCount[1:0]};
                    end
                    9'b0101110??: begin
                        indexA_reg = {8'b01011100, cycleCount[1:0]};
                    end
                    9'b0101111??: begin
                        indexA_reg = {8'b01011110, cycleCount[1:0]};
                    end
                    9'b0110000??: begin
                        indexA_reg = {8'b01100000, cycleCount[1:0]};
                    end
                    9'b0110001??: begin
                        indexA_reg = {8'b01100010, cycleCount[1:0]};
                    end
                    9'b0110010??: begin
                        indexA_reg = {8'b01100100, cycleCount[1:0]};
                    end
                    9'b0110011??: begin
                        indexA_reg = {8'b01100110, cycleCount[1:0]};
                    end
                    9'b0110100??: begin
                        indexA_reg = {8'b01101000, cycleCount[1:0]};
                    end
                    9'b0110101??: begin
                        indexA_reg = {8'b01101010, cycleCount[1:0]};
                    end
                    9'b0110110??: begin
                        indexA_reg = {8'b01101100, cycleCount[1:0]};
                    end
                    9'b0110111??: begin
                        indexA_reg = {8'b01101110, cycleCount[1:0]};
                    end
                    9'b0111000??: begin
                        indexA_reg = {8'b01110000, cycleCount[1:0]};
                    end
                    9'b0111001??: begin
                        indexA_reg = {8'b01110010, cycleCount[1:0]};
                    end
                    9'b0111010??: begin
                        indexA_reg = {8'b01110100, cycleCount[1:0]};
                    end
                    9'b0111011??: begin
                        indexA_reg = {8'b01110110, cycleCount[1:0]};
                    end
                    9'b0111100??: begin
                        indexA_reg = {8'b01111000, cycleCount[1:0]};
                    end
                    9'b0111101??: begin
                        indexA_reg = {8'b01111010, cycleCount[1:0]};
                    end
                    9'b0111110??: begin
                        indexA_reg = {8'b01111100, cycleCount[1:0]};
                    end
                    9'b0111111??: begin
                        indexA_reg = {8'b01111110, cycleCount[1:0]};
                    end
                    ///////////////
                    9'b1000000??: begin
                        indexA_reg = {8'b10000000, cycleCount[1:0]};
                    end
                    9'b1000001??: begin
                        indexA_reg = {8'b10000010, cycleCount[1:0]};
                    end
                    9'b1000010??: begin
                        indexA_reg = {8'b10000100, cycleCount[1:0]};
                    end
                    9'b1000011??: begin
                        indexA_reg = {8'b10000110, cycleCount[1:0]};
                    end
                    9'b1000100??: begin
                        indexA_reg = {8'b10001000, cycleCount[1:0]};
                    end
                    9'b1000101??: begin
                        indexA_reg = {8'b10001010, cycleCount[1:0]};
                    end
                    9'b1000110??: begin
                        indexA_reg = {8'b10001100, cycleCount[1:0]};
                    end
                    9'b1000111??: begin
                        indexA_reg = {8'b10001110, cycleCount[1:0]};
                    end
                    9'b1001000??: begin
                        indexA_reg = {8'b10010000, cycleCount[1:0]};
                    end
                    9'b1001001??: begin
                        indexA_reg = {8'b10010010, cycleCount[1:0]};
                    end
                    9'b1001010??: begin
                        indexA_reg = {8'b10010100, cycleCount[1:0]};
                    end
                    9'b1001011??: begin
                        indexA_reg = {8'b10010110, cycleCount[1:0]};
                    end
                    9'b1001100??: begin
                        indexA_reg = {8'b10011000, cycleCount[1:0]};
                    end
                    9'b1001101??: begin
                        indexA_reg = {8'b10011010, cycleCount[1:0]};
                    end
                    9'b1001110??: begin
                        indexA_reg = {8'b10011100, cycleCount[1:0]};
                    end
                    9'b1001111??: begin
                        indexA_reg = {8'b10011110, cycleCount[1:0]};
                    end
                    9'b1010000??: begin
                        indexA_reg = {8'b10100000, cycleCount[1:0]};
                    end
                    9'b1010001??: begin
                        indexA_reg = {8'b10100010, cycleCount[1:0]};
                    end
                    9'b1010010??: begin
                        indexA_reg = {8'b10100100, cycleCount[1:0]};
                    end
                    9'b1010011??: begin
                        indexA_reg = {8'b10100110, cycleCount[1:0]};
                    end
                    9'b1010100??: begin
                        indexA_reg = {8'b10101000, cycleCount[1:0]};
                    end
                    9'b1010101??: begin
                        indexA_reg = {8'b10101010, cycleCount[1:0]};
                    end
                    9'b1010110??: begin
                        indexA_reg = {8'b10101100, cycleCount[1:0]};
                    end
                    9'b1010111??: begin
                        indexA_reg = {8'b10101110, cycleCount[1:0]};
                    end
                    9'b1011000??: begin
                        indexA_reg = {8'b10110000, cycleCount[1:0]};
                    end
                    9'b1011001??: begin
                        indexA_reg = {8'b10110010, cycleCount[1:0]};
                    end
                    9'b1011010??: begin
                        indexA_reg = {8'b10110100, cycleCount[1:0]};
                    end
                    9'b1011011??: begin
                        indexA_reg = {8'b10110110, cycleCount[1:0]};
                    end
                    9'b1011100??: begin
                        indexA_reg = {8'b10111000, cycleCount[1:0]};
                    end
                    9'b1011101??: begin
                        indexA_reg = {8'b10111010, cycleCount[1:0]};
                    end
                    9'b1011110??: begin
                        indexA_reg = {8'b10111100, cycleCount[1:0]};
                    end
                    9'b1011111??: begin
                        indexA_reg = {8'b10111110, cycleCount[1:0]};
                    end
                    9'b1100000??: begin
                        indexA_reg = {8'b11000000, cycleCount[1:0]};
                    end
                    9'b1100001??: begin
                        indexA_reg = {8'b11000010, cycleCount[1:0]};
                    end
                    9'b1100010??: begin
                        indexA_reg = {8'b11000100, cycleCount[1:0]};
                    end
                    9'b1100011??: begin
                        indexA_reg = {8'b11000110, cycleCount[1:0]};
                    end
                    9'b1100100??: begin
                        indexA_reg = {8'b11001000, cycleCount[1:0]};
                    end
                    9'b1100101??: begin
                        indexA_reg = {8'b11001010, cycleCount[1:0]};
                    end
                    9'b1100110??: begin
                        indexA_reg = {8'b11001100, cycleCount[1:0]};
                    end
                    9'b1100111??: begin
                        indexA_reg = {8'b11001110, cycleCount[1:0]};
                    end
                    9'b1101000??: begin
                        indexA_reg = {8'b11010000, cycleCount[1:0]};
                    end
                    9'b1001001??: begin
                        indexA_reg = {8'b11010010, cycleCount[1:0]};
                    end
                    9'b1101010??: begin
                        indexA_reg = {8'b11010100, cycleCount[1:0]};
                    end
                    9'b1101011??: begin
                        indexA_reg = {8'b11010110, cycleCount[1:0]};
                    end
                    9'b1101100??: begin
                        indexA_reg = {8'b11011000, cycleCount[1:0]};
                    end
                    9'b1101101??: begin
                        indexA_reg = {8'b11011010, cycleCount[1:0]};
                    end
                    9'b1101110??: begin
                        indexA_reg = {8'b11011100, cycleCount[1:0]};
                    end
                    9'b1101111??: begin
                        indexA_reg = {8'b11011110, cycleCount[1:0]};
                    end
                    9'b1110000??: begin
                        indexA_reg = {8'b11100000, cycleCount[1:0]};
                    end
                    9'b1110001??: begin
                        indexA_reg = {8'b11100010, cycleCount[1:0]};
                    end
                    9'b1110010??: begin
                        indexA_reg = {8'b11100100, cycleCount[1:0]};
                    end
                    9'b1110011??: begin
                        indexA_reg = {8'b11100110, cycleCount[1:0]};
                    end
                    9'b1110100??: begin
                        indexA_reg = {8'b11101000, cycleCount[1:0]};
                    end
                    9'b1110101??: begin
                        indexA_reg = {8'b11101010, cycleCount[1:0]};
                    end
                    9'b1110110??: begin
                        indexA_reg = {8'b11101100, cycleCount[1:0]};
                    end
                    9'b1110111??: begin
                        indexA_reg = {8'b11101110, cycleCount[1:0]};
                    end
                    9'b1111000??: begin
                        indexA_reg = {8'b11110000, cycleCount[1:0]};
                    end
                    9'b1111001??: begin
                        indexA_reg = {8'b11110010, cycleCount[1:0]};
                    end
                    9'b1111010??: begin
                        indexA_reg = {8'b11110100, cycleCount[1:0]};
                    end
                    9'b1111011??: begin
                        indexA_reg = {8'b11110110, cycleCount[1:0]};
                    end
                    9'b1111100??: begin
                        indexA_reg = {8'b11111000, cycleCount[1:0]};
                    end
                    9'b1111101??: begin
                        indexA_reg = {8'b11111010, cycleCount[1:0]};
                    end
                    9'b1111110??: begin
                        indexA_reg = {8'b11111100, cycleCount[1:0]};
                    end
                    9'b1111111??: begin
                        indexA_reg = {8'b11111110, cycleCount[1:0]};
                    end
                endcase
            end
            5'h08: begin
                casez(cycleCount)
                    9'b00000000?: begin
                        indexA_reg = {9'b000000000, cycleCount[0]};
                    end
                    9'b00000001?: begin
                        indexA_reg = {9'b000000010, cycleCount[0]};
                    end
                    9'b00000010?: begin
                        indexA_reg = {9'b000000100, cycleCount[0]};
                    end
                    9'b00000011?: begin
                        indexA_reg = {9'b000000110, cycleCount[0]};
                    end
                    9'b00000100?: begin
                        indexA_reg = {9'b000001000, cycleCount[0]};
                    end
                    9'b00000101?: begin
                        indexA_reg = {9'b000001010, cycleCount[0]};
                    end
                    9'b00000110?: begin
                        indexA_reg = {9'b000001100, cycleCount[0]};
                    end
                    9'b00000111?: begin
                        indexA_reg = {9'b000001110, cycleCount[0]};
                    end
                    9'b00001000?: begin
                        indexA_reg = {9'b000010000, cycleCount[0]};
                    end
                    9'b00001001?: begin
                        indexA_reg = {9'b000010010, cycleCount[0]};
                    end
                    9'b00001010?: begin
                        indexA_reg = {9'b000010100, cycleCount[0]};
                    end
                    9'b00001011?: begin
                        indexA_reg = {9'b000010110, cycleCount[0]};
                    end
                    9'b00001100?: begin
                        indexA_reg = {9'b000011000, cycleCount[0]};
                    end
                    9'b00001101?: begin
                        indexA_reg = {9'b000011010, cycleCount[0]};
                    end
                    9'b00001110?: begin
                        indexA_reg = {9'b000011100, cycleCount[0]};
                    end
                    9'b00001111?: begin
                        indexA_reg = {9'b000011110, cycleCount[0]};
                    end
                    9'b00010000?: begin
                        indexA_reg = {9'b000100000, cycleCount[0]};
                    end
                    9'b00010001?: begin
                        indexA_reg = {9'b000100010, cycleCount[0]};
                    end
                    9'b00010010?: begin
                        indexA_reg = {9'b000100100, cycleCount[0]};
                    end
                    9'b00010011?: begin
                        indexA_reg = {9'b000100110, cycleCount[0]};
                    end
                    9'b00010100?: begin
                        indexA_reg = {9'b000101000, cycleCount[0]};
                    end
                    9'b00010101?: begin
                        indexA_reg = {9'b000101010, cycleCount[0]};
                    end
                    9'b00010110?: begin
                        indexA_reg = {9'b000101100, cycleCount[0]};
                    end
                    9'b00010111?: begin
                        indexA_reg = {9'b000101110, cycleCount[0]};
                    end
                    9'b00011000?: begin
                        indexA_reg = {9'b000110000, cycleCount[0]};
                    end
                    9'b00011001?: begin
                        indexA_reg = {9'b000110010, cycleCount[0]};
                    end
                    9'b00011010?: begin
                        indexA_reg = {9'b000110100, cycleCount[0]};
                    end
                    9'b00011011?: begin
                        indexA_reg = {9'b000110110, cycleCount[0]};
                    end
                    9'b00011100?: begin
                        indexA_reg = {9'b000111000, cycleCount[0]};
                    end
                    9'b00011101?: begin
                        indexA_reg = {9'b000111010, cycleCount[0]};
                    end
                    9'b00011110?: begin
                        indexA_reg = {9'b000111100, cycleCount[0]};
                    end
                    9'b00011111?: begin
                        indexA_reg = {9'b000111110, cycleCount[0]};
                    end
                    9'b00100000?: begin
                        indexA_reg = {9'b001000000, cycleCount[0]};
                    end
                    9'b00100001?: begin
                        indexA_reg = {9'b001000010, cycleCount[0]};
                    end
                    9'b00100010?: begin
                        indexA_reg = {9'b001000100, cycleCount[0]};
                    end
                    9'b00100011?: begin
                        indexA_reg = {9'b001000110, cycleCount[0]};
                    end
                    9'b00100100?: begin
                        indexA_reg = {9'b001001000, cycleCount[0]};
                    end
                    9'b00100101?: begin
                        indexA_reg = {9'b001001010, cycleCount[0]};
                    end
                    9'b00100110?: begin
                        indexA_reg = {9'b001001100, cycleCount[0]};
                    end
                    9'b00100111?: begin
                        indexA_reg = {9'b001001110, cycleCount[0]};
                    end
                    9'b00101000?: begin
                        indexA_reg = {9'b001010000, cycleCount[0]};
                    end
                    9'b00001001?: begin
                        indexA_reg = {9'b001010010, cycleCount[0]};
                    end
                    9'b00101010?: begin
                        indexA_reg = {9'b001010100, cycleCount[0]};
                    end
                    9'b00101011?: begin
                        indexA_reg = {9'b001010110, cycleCount[0]};
                    end
                    9'b00101100?: begin
                        indexA_reg = {9'b001011000, cycleCount[0]};
                    end
                    9'b00101101?: begin
                        indexA_reg = {9'b001011010, cycleCount[0]};
                    end
                    9'b00101110?: begin
                        indexA_reg = {9'b001011100, cycleCount[0]};
                    end
                    9'b00101111?: begin
                        indexA_reg = {9'b001011110, cycleCount[0]};
                    end
                    9'b00110000?: begin
                        indexA_reg = {9'b001100000, cycleCount[0]};
                    end
                    9'b00110001?: begin
                        indexA_reg = {9'b001100010, cycleCount[0]};
                    end
                    9'b00110010?: begin
                        indexA_reg = {9'b001100100, cycleCount[0]};
                    end
                    9'b00110011?: begin
                        indexA_reg = {9'b001100110, cycleCount[0]};
                    end
                    9'b00110100?: begin
                        indexA_reg = {9'b001101000, cycleCount[0]};
                    end
                    9'b00110101?: begin
                        indexA_reg = {9'b001101010, cycleCount[0]};
                    end
                    9'b00110110?: begin
                        indexA_reg = {9'b001101100, cycleCount[0]};
                    end
                    9'b00110111?: begin
                        indexA_reg = {9'b001101110, cycleCount[0]};
                    end
                    9'b00111000?: begin
                        indexA_reg = {9'b001110000, cycleCount[0]};
                    end
                    9'b00111001?: begin
                        indexA_reg = {9'b001110010, cycleCount[0]};
                    end
                    9'b00111010?: begin
                        indexA_reg = {9'b001110100, cycleCount[0]};
                    end
                    9'b00111011?: begin
                        indexA_reg = {9'b001110110, cycleCount[0]};
                    end
                    9'b00111100?: begin
                        indexA_reg = {9'b001111000, cycleCount[0]};
                    end
                    9'b00111101?: begin
                        indexA_reg = {9'b001111010, cycleCount[0]};
                    end
                    9'b00111110?: begin
                        indexA_reg = {9'b001111100, cycleCount[0]};
                    end
                    9'b00111111?: begin
                        indexA_reg = {9'b001111110, cycleCount[0]};
                    end
                    9'b01000000?: begin
                        indexA_reg = {9'b010000000, cycleCount[0]};
                    end
                    9'b01000001?: begin
                        indexA_reg = {9'b010000010, cycleCount[0]};
                    end
                    9'b01000010?: begin
                        indexA_reg = {9'b010000100, cycleCount[0]};
                    end
                    9'b01000011?: begin
                        indexA_reg = {9'b010000110, cycleCount[0]};
                    end
                    9'b01000100?: begin
                        indexA_reg = {9'b010001000, cycleCount[0]};
                    end
                    9'b01000101?: begin
                        indexA_reg = {9'b010001010, cycleCount[0]};
                    end
                    9'b01000110?: begin
                        indexA_reg = {9'b010001100, cycleCount[0]};
                    end
                    9'b01000111?: begin
                        indexA_reg = {9'b010001110, cycleCount[0]};
                    end
                    9'b01001000?: begin
                        indexA_reg = {9'b010010000, cycleCount[0]};
                    end
                    9'b01001001?: begin
                        indexA_reg = {9'b010010010, cycleCount[0]};
                    end
                    9'b01001010?: begin
                        indexA_reg = {9'b010010100, cycleCount[0]};
                    end
                    9'b01001011?: begin
                        indexA_reg = {9'b010010110, cycleCount[0]};
                    end
                    9'b01001100?: begin
                        indexA_reg = {9'b010011000, cycleCount[0]};
                    end
                    9'b01001101?: begin
                        indexA_reg = {9'b010011010, cycleCount[0]};
                    end
                    9'b01001110?: begin
                        indexA_reg = {9'b010011100, cycleCount[0]};
                    end
                    9'b01001111?: begin
                        indexA_reg = {9'b010011110, cycleCount[0]};
                    end
                    9'b01010000?: begin
                        indexA_reg = {9'b010100000, cycleCount[0]};
                    end
                    9'b01010001?: begin
                        indexA_reg = {9'b010100010, cycleCount[0]};
                    end
                    9'b01010010?: begin
                        indexA_reg = {9'b010100100, cycleCount[0]};
                    end
                    9'b01010011?: begin
                        indexA_reg = {9'b010100110, cycleCount[0]};
                    end
                    9'b01010100?: begin
                        indexA_reg = {9'b010101000, cycleCount[0]};
                    end
                    9'b01010101?: begin
                        indexA_reg = {9'b010101010, cycleCount[0]};
                    end
                    9'b01010110?: begin
                        indexA_reg = {9'b010101100, cycleCount[0]};
                    end
                    9'b01010111?: begin
                        indexA_reg = {9'b010101110, cycleCount[0]};
                    end
                    9'b01011000?: begin
                        indexA_reg = {9'b010110000, cycleCount[0]};
                    end
                    9'b01011001?: begin
                        indexA_reg = {9'b010110010, cycleCount[0]};
                    end
                    9'b01011010?: begin
                        indexA_reg = {9'b010110100, cycleCount[0]};
                    end
                    9'b01011011?: begin
                        indexA_reg = {9'b010110110, cycleCount[0]};
                    end
                    9'b01011100?: begin
                        indexA_reg = {9'b010111000, cycleCount[0]};
                    end
                    9'b01011101?: begin
                        indexA_reg = {9'b010111010, cycleCount[0]};
                    end
                    9'b01011110?: begin
                        indexA_reg = {9'b010111100, cycleCount[0]};
                    end
                    9'b01011111?: begin
                        indexA_reg = {9'b010111110, cycleCount[0]};
                    end
                    9'b01100000?: begin
                        indexA_reg = {9'b011000000, cycleCount[0]};
                    end
                    9'b01100001?: begin
                        indexA_reg = {9'b011000010, cycleCount[0]};
                    end
                    9'b01100010?: begin
                        indexA_reg = {9'b011000100, cycleCount[0]};
                    end
                    9'b01100011?: begin
                        indexA_reg = {9'b011000110, cycleCount[0]};
                    end
                    9'b01100100?: begin
                        indexA_reg = {9'b011001000, cycleCount[0]};
                    end
                    9'b01100101?: begin
                        indexA_reg = {9'b011001010, cycleCount[0]};
                    end
                    9'b01100110?: begin
                        indexA_reg = {9'b011001100, cycleCount[0]};
                    end
                    9'b01100111?: begin
                        indexA_reg = {9'b011001110, cycleCount[0]};
                    end
                    9'b01101000?: begin
                        indexA_reg = {9'b011010000, cycleCount[0]};
                    end
                    9'b01001001?: begin
                        indexA_reg = {9'b011010010, cycleCount[0]};
                    end
                    9'b01101010?: begin
                        indexA_reg = {9'b011010100, cycleCount[0]};
                    end
                    9'b01101011?: begin
                        indexA_reg = {9'b011010110, cycleCount[0]};
                    end
                    9'b01101100?: begin
                        indexA_reg = {9'b011011000, cycleCount[0]};
                    end
                    9'b01101101?: begin
                        indexA_reg = {9'b011011010, cycleCount[0]};
                    end
                    9'b01101110?: begin
                        indexA_reg = {9'b011011100, cycleCount[0]};
                    end
                    9'b01101111?: begin
                        indexA_reg = {9'b011011110, cycleCount[0]};
                    end
                    9'b01110000?: begin
                        indexA_reg = {9'b011100000, cycleCount[0]};
                    end
                    9'b01110001?: begin
                        indexA_reg = {9'b011100010, cycleCount[0]};
                    end
                    9'b01110010?: begin
                        indexA_reg = {9'b011100100, cycleCount[0]};
                    end
                    9'b01110011?: begin
                        indexA_reg = {9'b011100110, cycleCount[0]};
                    end
                    9'b01110100?: begin
                        indexA_reg = {9'b011101000, cycleCount[0]};
                    end
                    9'b01110101?: begin
                        indexA_reg = {9'b011101010, cycleCount[0]};
                    end
                    9'b01110110?: begin
                        indexA_reg = {9'b011101100, cycleCount[0]};
                    end
                    9'b01110111?: begin
                        indexA_reg = {9'b011101110, cycleCount[0]};
                    end
                    9'b01111000?: begin
                        indexA_reg = {9'b011110000, cycleCount[0]};
                    end
                    9'b01111001?: begin
                        indexA_reg = {9'b011110010, cycleCount[0]};
                    end
                    9'b01111010?: begin
                        indexA_reg = {9'b011110100, cycleCount[0]};
                    end
                    9'b01111011?: begin
                        indexA_reg = {9'b011110110, cycleCount[0]};
                    end
                    9'b01111100?: begin
                        indexA_reg = {9'b011111000, cycleCount[0]};
                    end
                    9'b01111101?: begin
                        indexA_reg = {9'b011111010, cycleCount[0]};
                    end
                    9'b01111110?: begin
                        indexA_reg = {9'b011111100, cycleCount[0]};
                    end
                    9'b01111111?: begin
                        indexA_reg = {9'b011111110, cycleCount[0]};
                    end
                    
                    ///////////////

                    9'b10000000?: begin
                        indexA_reg = {9'b100000000, cycleCount[0]};
                    end
                    9'b10000001?: begin
                        indexA_reg = {9'b100000010, cycleCount[0]};
                    end
                    9'b10000010?: begin
                        indexA_reg = {9'b100000100, cycleCount[0]};
                    end
                    9'b10000011?: begin
                        indexA_reg = {9'b100000110, cycleCount[0]};
                    end
                    9'b10000100?: begin
                        indexA_reg = {9'b100001000, cycleCount[0]};
                    end
                    9'b10000101?: begin
                        indexA_reg = {9'b100001010, cycleCount[0]};
                    end
                    9'b10000110?: begin
                        indexA_reg = {9'b100001100, cycleCount[0]};
                    end
                    9'b10000111?: begin
                        indexA_reg = {9'b100001110, cycleCount[0]};
                    end
                    9'b10001000?: begin
                        indexA_reg = {9'b100010000, cycleCount[0]};
                    end
                    9'b10001001?: begin
                        indexA_reg = {9'b100010010, cycleCount[0]};
                    end
                    9'b10001010?: begin
                        indexA_reg = {9'b100010100, cycleCount[0]};
                    end
                    9'b10001011?: begin
                        indexA_reg = {9'b100010110, cycleCount[0]};
                    end
                    9'b10001100?: begin
                        indexA_reg = {9'b100011000, cycleCount[0]};
                    end
                    9'b10001101?: begin
                        indexA_reg = {9'b100011010, cycleCount[0]};
                    end
                    9'b10001110?: begin
                        indexA_reg = {9'b100011100, cycleCount[0]};
                    end
                    9'b10001111?: begin
                        indexA_reg = {9'b100011110, cycleCount[0]};
                    end
                    9'b10010000?: begin
                        indexA_reg = {9'b100100000, cycleCount[0]};
                    end
                    9'b10010001?: begin
                        indexA_reg = {9'b100100010, cycleCount[0]};
                    end
                    9'b10010010?: begin
                        indexA_reg = {9'b100100100, cycleCount[0]};
                    end
                    9'b10010011?: begin
                        indexA_reg = {9'b100100110, cycleCount[0]};
                    end
                    9'b10010100?: begin
                        indexA_reg = {9'b100101000, cycleCount[0]};
                    end
                    9'b10010101?: begin
                        indexA_reg = {9'b100101010, cycleCount[0]};
                    end
                    9'b10010110?: begin
                        indexA_reg = {9'b100101100, cycleCount[0]};
                    end
                    9'b10010111?: begin
                        indexA_reg = {9'b100101110, cycleCount[0]};
                    end
                    9'b10011000?: begin
                        indexA_reg = {9'b100110000, cycleCount[0]};
                    end
                    9'b10011001?: begin
                        indexA_reg = {9'b100110010, cycleCount[0]};
                    end
                    9'b10011010?: begin
                        indexA_reg = {9'b100110100, cycleCount[0]};
                    end
                    9'b10011011?: begin
                        indexA_reg = {9'b100110110, cycleCount[0]};
                    end
                    9'b10011100?: begin
                        indexA_reg = {9'b100111000, cycleCount[0]};
                    end
                    9'b10011101?: begin
                        indexA_reg = {9'b100111010, cycleCount[0]};
                    end
                    9'b10011110?: begin
                        indexA_reg = {9'b100111100, cycleCount[0]};
                    end
                    9'b10011111?: begin
                        indexA_reg = {9'b100111110, cycleCount[0]};
                    end
                    9'b10100000?: begin
                        indexA_reg = {9'b101000000, cycleCount[0]};
                    end
                    9'b10100001?: begin
                        indexA_reg = {9'b101000010, cycleCount[0]};
                    end
                    9'b10100010?: begin
                        indexA_reg = {9'b101000100, cycleCount[0]};
                    end
                    9'b10100011?: begin
                        indexA_reg = {9'b101000110, cycleCount[0]};
                    end
                    9'b10100100?: begin
                        indexA_reg = {9'b101001000, cycleCount[0]};
                    end
                    9'b10100101?: begin
                        indexA_reg = {9'b101001010, cycleCount[0]};
                    end
                    9'b10100110?: begin
                        indexA_reg = {9'b101001100, cycleCount[0]};
                    end
                    9'b10100111?: begin
                        indexA_reg = {9'b101001110, cycleCount[0]};
                    end
                    9'b10101000?: begin
                        indexA_reg = {9'b101010000, cycleCount[0]};
                    end
                    9'b10001001?: begin
                        indexA_reg = {9'b101010010, cycleCount[0]};
                    end
                    9'b10101010?: begin
                        indexA_reg = {9'b101010100, cycleCount[0]};
                    end
                    9'b10101011?: begin
                        indexA_reg = {9'b101010110, cycleCount[0]};
                    end
                    9'b10101100?: begin
                        indexA_reg = {9'b101011000, cycleCount[0]};
                    end
                    9'b10101101?: begin
                        indexA_reg = {9'b101011010, cycleCount[0]};
                    end
                    9'b10101110?: begin
                        indexA_reg = {9'b101011100, cycleCount[0]};
                    end
                    9'b10101111?: begin
                        indexA_reg = {9'b101011110, cycleCount[0]};
                    end
                    9'b10110000?: begin
                        indexA_reg = {9'b101100000, cycleCount[0]};
                    end
                    9'b10110001?: begin
                        indexA_reg = {9'b101100010, cycleCount[0]};
                    end
                    9'b10110010?: begin
                        indexA_reg = {9'b101100100, cycleCount[0]};
                    end
                    9'b10110011?: begin
                        indexA_reg = {9'b101100110, cycleCount[0]};
                    end
                    9'b10110100?: begin
                        indexA_reg = {9'b101101000, cycleCount[0]};
                    end
                    9'b10110101?: begin
                        indexA_reg = {9'b101101010, cycleCount[0]};
                    end
                    9'b10110110?: begin
                        indexA_reg = {9'b101101100, cycleCount[0]};
                    end
                    9'b10110111?: begin
                        indexA_reg = {9'b101101110, cycleCount[0]};
                    end
                    9'b10111000?: begin
                        indexA_reg = {9'b101110000, cycleCount[0]};
                    end
                    9'b10111001?: begin
                        indexA_reg = {9'b101110010, cycleCount[0]};
                    end
                    9'b10111010?: begin
                        indexA_reg = {9'b101110100, cycleCount[0]};
                    end
                    9'b10111011?: begin
                        indexA_reg = {9'b101110110, cycleCount[0]};
                    end
                    9'b10111100?: begin
                        indexA_reg = {9'b101111000, cycleCount[0]};
                    end
                    9'b10111101?: begin
                        indexA_reg = {9'b101111010, cycleCount[0]};
                    end
                    9'b10111110?: begin
                        indexA_reg = {9'b101111100, cycleCount[0]};
                    end
                    9'b10111111?: begin
                        indexA_reg = {9'b101111110, cycleCount[0]};
                    end
                    9'b11000000?: begin
                        indexA_reg = {9'b110000000, cycleCount[0]};
                    end
                    9'b11000001?: begin
                        indexA_reg = {9'b110000010, cycleCount[0]};
                    end
                    9'b11000010?: begin
                        indexA_reg = {9'b110000100, cycleCount[0]};
                    end
                    9'b11000011?: begin
                        indexA_reg = {9'b110000110, cycleCount[0]};
                    end
                    9'b11000100?: begin
                        indexA_reg = {9'b110001000, cycleCount[0]};
                    end
                    9'b11000101?: begin
                        indexA_reg = {9'b110001010, cycleCount[0]};
                    end
                    9'b11000110?: begin
                        indexA_reg = {9'b110001100, cycleCount[0]};
                    end
                    9'b11000111?: begin
                        indexA_reg = {9'b110001110, cycleCount[0]};
                    end
                    9'b11001000?: begin
                        indexA_reg = {9'b110010000, cycleCount[0]};
                    end
                    9'b11001001?: begin
                        indexA_reg = {9'b110010010, cycleCount[0]};
                    end
                    9'b11001010?: begin
                        indexA_reg = {9'b110010100, cycleCount[0]};
                    end
                    9'b11001011?: begin
                        indexA_reg = {9'b110010110, cycleCount[0]};
                    end
                    9'b11001100?: begin
                        indexA_reg = {9'b110011000, cycleCount[0]};
                    end
                    9'b11001101?: begin
                        indexA_reg = {9'b110011010, cycleCount[0]};
                    end
                    9'b11001110?: begin
                        indexA_reg = {9'b110011100, cycleCount[0]};
                    end
                    9'b11001111?: begin
                        indexA_reg = {9'b110011110, cycleCount[0]};
                    end
                    9'b11010000?: begin
                        indexA_reg = {9'b110100000, cycleCount[0]};
                    end
                    9'b11010001?: begin
                        indexA_reg = {9'b110100010, cycleCount[0]};
                    end
                    9'b11010010?: begin
                        indexA_reg = {9'b110100100, cycleCount[0]};
                    end
                    9'b11010011?: begin
                        indexA_reg = {9'b110100110, cycleCount[0]};
                    end
                    9'b11010100?: begin
                        indexA_reg = {9'b110101000, cycleCount[0]};
                    end
                    9'b11010101?: begin
                        indexA_reg = {9'b110101010, cycleCount[0]};
                    end
                    9'b11010110?: begin
                        indexA_reg = {9'b110101100, cycleCount[0]};
                    end
                    9'b11010111?: begin
                        indexA_reg = {9'b110101110, cycleCount[0]};
                    end
                    9'b11011000?: begin
                        indexA_reg = {9'b110110000, cycleCount[0]};
                    end
                    9'b11011001?: begin
                        indexA_reg = {9'b110110010, cycleCount[0]};
                    end
                    9'b11011010?: begin
                        indexA_reg = {9'b110110100, cycleCount[0]};
                    end
                    9'b11011011?: begin
                        indexA_reg = {9'b110110110, cycleCount[0]};
                    end
                    9'b11011100?: begin
                        indexA_reg = {9'b110111000, cycleCount[0]};
                    end
                    9'b11011101?: begin
                        indexA_reg = {9'b110111010, cycleCount[0]};
                    end
                    9'b11011110?: begin
                        indexA_reg = {9'b110111100, cycleCount[0]};
                    end
                    9'b11011111?: begin
                        indexA_reg = {9'b110111110, cycleCount[0]};
                    end
                    9'b11100000?: begin
                        indexA_reg = {9'b111000000, cycleCount[0]};
                    end
                    9'b11100001?: begin
                        indexA_reg = {9'b111000010, cycleCount[0]};
                    end
                    9'b11100010?: begin
                        indexA_reg = {9'b111000100, cycleCount[0]};
                    end
                    9'b11100011?: begin
                        indexA_reg = {9'b111000110, cycleCount[0]};
                    end
                    9'b11100100?: begin
                        indexA_reg = {9'b111001000, cycleCount[0]};
                    end
                    9'b11100101?: begin
                        indexA_reg = {9'b111001010, cycleCount[0]};
                    end
                    9'b11100110?: begin
                        indexA_reg = {9'b111001100, cycleCount[0]};
                    end
                    9'b11100111?: begin
                        indexA_reg = {9'b111001110, cycleCount[0]};
                    end
                    9'b11101000?: begin
                        indexA_reg = {9'b111010000, cycleCount[0]};
                    end
                    9'b11001001?: begin
                        indexA_reg = {9'b111010010, cycleCount[0]};
                    end
                    9'b11101010?: begin
                        indexA_reg = {9'b111010100, cycleCount[0]};
                    end
                    9'b11101011?: begin
                        indexA_reg = {9'b111010110, cycleCount[0]};
                    end
                    9'b11101100?: begin
                        indexA_reg = {9'b111011000, cycleCount[0]};
                    end
                    9'b11101101?: begin
                        indexA_reg = {9'b111011010, cycleCount[0]};
                    end
                    9'b11101110?: begin
                        indexA_reg = {9'b111011100, cycleCount[0]};
                    end
                    9'b11101111?: begin
                        indexA_reg = {9'b111011110, cycleCount[0]};
                    end
                    9'b11110000?: begin
                        indexA_reg = {9'b111100000, cycleCount[0]};
                    end
                    9'b11110001?: begin
                        indexA_reg = {9'b111100010, cycleCount[0]};
                    end
                    9'b11110010?: begin
                        indexA_reg = {9'b111100100, cycleCount[0]};
                    end
                    9'b11110011?: begin
                        indexA_reg = {9'b111100110, cycleCount[0]};
                    end
                    9'b11110100?: begin
                        indexA_reg = {9'b111101000, cycleCount[0]};
                    end
                    9'b11110101?: begin
                        indexA_reg = {9'b111101010, cycleCount[0]};
                    end
                    9'b11110110?: begin
                        indexA_reg = {9'b111101100, cycleCount[0]};
                    end
                    9'b11110111?: begin
                        indexA_reg = {9'b111101110, cycleCount[0]};
                    end
                    9'b11111000?: begin
                        indexA_reg = {9'b111110000, cycleCount[0]};
                    end
                    9'b11111001?: begin
                        indexA_reg = {9'b111110010, cycleCount[0]};
                    end
                    9'b11111010?: begin
                        indexA_reg = {9'b111110100, cycleCount[0]};
                    end
                    9'b11111011?: begin
                        indexA_reg = {9'b111110110, cycleCount[0]};
                    end
                    9'b11111100?: begin
                        indexA_reg = {9'b111111000, cycleCount[0]};
                    end
                    9'b11111101?: begin
                        indexA_reg = {9'b111111010, cycleCount[0]};
                    end
                    9'b11111110?: begin
                        indexA_reg = {9'b111111100, cycleCount[0]};
                    end
                    9'b11111111?: begin
                        indexA_reg = {9'b111111110, cycleCount[0]};
                    end
                endcase
            end
            5'h09: begin
                indexA_reg = {1'b0, cycleCount} << 1'b1;
            end
        endcase
    end
    
endmodule