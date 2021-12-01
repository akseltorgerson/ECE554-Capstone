module  address_generator
    #(
        NUM_FACTORS=512
    )
    (
        input [4:0] stageCount,
        input [8:0] cycleCount,
        input clk, rst,
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

    assign stageDifference = (stageCount - numFactorBits)

    assign twiddle_int = ~stageDifference[5] ? 
                            cycleCount << stageDifference : 
                            cycleCount >> (~stageDifference + 5'b00001);
    
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
    always @(stageCount | cycleCount) begin
        indexA_reg = 10'h000;

        case(stageCount)
            5'h00: begin
                indexA_reg = cycleCount;
            end
            5'h01: begin
                case(cycleCount)
                    9'b0xxxxxxxx: begin
                        indexA_reg = {2'b00, cycleCount[7:0]};
                    end
                    9'b1xxxxxxxx: begin
                        indexA_reg = {2'b10, cycleCount[7:0]};
                    end
                endcase
            end
            5'h02: begin
                case(cycleCount)
                    9'b00xxxxxxx: begin
                        indexA_reg = {3'b000, cycleCount[6:0]};
                    end
                    9'b01xxxxxxx: begin
                        indexA_reg = {3'b010, cycleCount[6:0]};
                    end
                    9'b10xxxxxxx: begin
                        indexA_reg = {3'b100, cycleCount[6:0]};
                    
                    9'b11xxxxxxx: begin
                        indexA_reg = {3'b110, cycleCount[6:0]};
                    end
                endcase
            end
            5'h03: begin
                case(cycleCount)
                    9'b000xxxxxx: begin
                        indexA_reg = {4'b0000, cycleCount[5:0]};
                    end
                    9'b001xxxxxx: begin
                        indexA_reg = {4'b0010, cycleCount[5:0]};
                    end
                    9'b010xxxxxx: begin
                        indexA_reg = {4'b0100, cycleCount[5:0]};
                    end
                    9'b011xxxxxx: begin
                        indexA_reg = {4'b0110, cycleCount[5:0]};
                    end
                    9'b100xxxxxx: begin
                        indexA_reg = {4'b1000, cycleCount[5:0]};
                    end
                    9'b101xxxxxx: begin
                        indexA_reg = {4'b1010, cycleCount[5:0]};
                    end
                    9'b110xxxxxx: begin
                        indexA_reg = {4'b1100, cycleCount[5:0]};
                    end
                    9'b111xxxxxx: begin
                        indexA_reg = {4'b1110, cycleCount[5:0]};
                    end
                endcase
            end
            5'h04: begin
                case(cycleCount)
                    9'b0000xxxxx: begin
                        indexA_reg = {5'b00000, cycleCount[4:0]};
                    end
                    9'b0001xxxxx: begin
                        indexA_reg = {5'b00010, cycleCount[4:0]};
                    end
                    9'b0010xxxxx: begin
                        indexA_reg = {5'b00100, cycleCount[4:0]};
                    end
                    9'b0011xxxxx: begin
                        indexA_reg = {5'b00110, cycleCount[4:0]};
                    end
                    9'b0100xxxxx: begin
                        indexA_reg = {5'b01000, cycleCount[4:0]};
                    end
                    9'b0101xxxxx: begin
                        indexA_reg = {5'b01010, cycleCount[4:0]};
                    end
                    9'b0110xxxxx: begin
                        indexA_reg = {5'b01100, cycleCount[4:0]};
                    end
                    9'b0111xxxxx: begin
                        indexA_reg = {5'b01110, cycleCount[4:0]};
                    end
                    9'b1000xxxxx: begin
                        indexA_reg = {5'b10000, cycleCount[4:0]};
                    end
                    9'b1001xxxxx: begin
                        indexA_reg = {5'b10010, cycleCount[4:0]};
                    end
                    9'b1010xxxxx: begin
                        indexA_reg = {5'b10100, cycleCount[4:0]};
                    end
                    9'b1011xxxxx: begin
                        indexA_reg = {5'b10110, cycleCount[4:0]};
                    end
                    9'b1100xxxxx: begin
                        indexA_reg = {5'b11000, cycleCount[4:0]};
                    end
                    9'b1101xxxxx: begin
                        indexA_reg = {5'b11010, cycleCount[4:0]};
                    end
                    9'b1110xxxxx: begin
                        indexA_reg = {5'b11100, cycleCount[4:0]};
                    end
                    9'b1111xxxxx: begin
                        indexA_reg = {5'b11110, cycleCount[4:0]};
                    end
                endcase
            end
            5'h05: begin
                case(cycleCount)
                    9'b00000xxxx: begin
                        indexA_reg = {6'b000000, cycleCount[3:0]};
                    end
                    9'b00001xxxx: begin
                        indexA_reg = {6'b000010, cycleCount[3:0]};
                    end
                    9'b00010xxxx: begin
                        indexA_reg = {6'b000100, cycleCount[3:0]};
                    end
                    9'b00011xxxx: begin
                        indexA_reg = {6'b000110, cycleCount[3:0]};
                    end
                    9'b00100xxxx: begin
                        indexA_reg = {6'b001000, cycleCount[3:0]};
                    end
                    9'b00101xxxx: begin
                        indexA_reg = {6'b001010, cycleCount[3:0]};
                    end
                    9'b00110xxxx: begin
                        indexA_reg = {6'b001100, cycleCount[3:0]};
                    end
                    9'b00111xxxx: begin
                        indexA_reg = {6'b001110, cycleCount[3:0]};
                    end
                    9'b01000xxxx: begin
                        indexA_reg = {6'b010000, cycleCount[3:0]};
                    end
                    9'b01001xxxx: begin
                        indexA_reg = {6'b010010, cycleCount[3:0]};
                    end
                    9'b01010xxxx: begin
                        indexA_reg = {6'b010100, cycleCount[3:0]};
                    end
                    9'b01011xxxx: begin
                        indexA_reg = {6'b010110, cycleCount[3:0]};
                    end
                    9'b01100xxxx: begin
                        indexA_reg = {6'b011000, cycleCount[3:0]};
                    end
                    9'b01101xxxx: begin
                        indexA_reg = {6'b011010, cycleCount[3:0]};
                    end
                    9'b01110xxxx: begin
                        indexA_reg = {6'b011100, cycleCount[3:0]};
                    end
                    9'b01111xxxx: begin
                        indexA_reg = {6'b011110, cycleCount[3:0]};
                    end
                    ///////
                    9'b10000xxxx: begin
                        indexA_reg = {6'b100000, cycleCount[3:0]};
                    end
                    9'b10001xxxx: begin
                        indexA_reg = {6'b100010, cycleCount[3:0]};
                    end
                    9'b10010xxxx: begin
                        indexA_reg = {6'b100100, cycleCount[3:0]};
                    end
                    9'b10011xxxx: begin
                        indexA_reg = {6'b100110, cycleCount[3:0]};
                    end
                    9'b10100xxxx: begin
                        indexA_reg = {6'b101000, cycleCount[3:0]};
                    end
                    9'b10101xxxx: begin
                        indexA_reg = {6'b101010, cycleCount[3:0]};
                    end
                    9'b10110xxxx: begin
                        indexA_reg = {6'b101100, cycleCount[3:0]};
                    end
                    9'b10111xxxx: begin
                        indexA_reg = {6'b101110, cycleCount[3:0]};
                    end
                    9'b11000xxxx: begin
                        indexA_reg = {6'b110000, cycleCount[3:0]};
                    end
                    9'b11001xxxx: begin
                        indexA_reg = {6'b110010, cycleCount[3:0]};
                    end
                    9'b11010xxxx: begin
                        indexA_reg = {6'b110100, cycleCount[3:0]};
                    end
                    9'b11011xxxx: begin
                        indexA_reg = {6'b110110, cycleCount[3:0]};
                    end
                    9'b11100xxxx: begin
                        indexA_reg = {6'b111000, cycleCount[3:0]};
                    end
                    9'b11101xxxx: begin
                        indexA_reg = {6'b111010, cycleCount[3:0]};
                    end
                    9'b11110xxxx: begin
                        indexA_reg = {6'b111100, cycleCount[3:0]};
                    end
                    9'b11111xxxx: begin
                        indexA_reg = {6'b111110, cycleCount[3:0]};
                    end
                endcase
            end
            5'h06: begin
                case(cycleCount)
                    9'b000000xxx: begin
                        indexA_reg = {7'b0000000, cycleCount[2:0]};
                    end
                    9'b000001xxx: begin
                        indexA_reg = {7'b0000010, cycleCount[2:0]};
                    end
                    9'b000010xxx: begin
                        indexA_reg = {7'b0000100, cycleCount[2:0]};
                    end
                    9'b000011xxx: begin
                        indexA_reg = {7'b0000110, cycleCount[2:0]};
                    end
                    9'b000100xxx: begin
                        indexA_reg = {7'b0001000, cycleCount[2:0]};
                    end
                    9'b000101xxx: begin
                        indexA_reg = {7'b0001010, cycleCount[2:0]};
                    end
                    9'b000110xxx: begin
                        indexA_reg = {7'b0001100, cycleCount[2:0]};
                    end
                    9'b000111xxx: begin
                        indexA_reg = {7'b0001110, cycleCount[2:0]};
                    end
                    9'b001000xxx: begin
                        indexA_reg = {7'b0010000, cycleCount[2:0]};
                    end
                    9'b001001xxx: begin
                        indexA_reg = {7'b0010010, cycleCount[2:0]};
                    end
                    9'b001010xxx: begin
                        indexA_reg = {7'b0010100, cycleCount[2:0]};
                    end
                    9'b001011xxx: begin
                        indexA_reg = {7'b0010110, cycleCount[2:0]};
                    end
                    9'b001100xxx: begin
                        indexA_reg = {7'b0011000, cycleCount[2:0]};
                    end
                    9'b001101xxx: begin
                        indexA_reg = {7'b0011010, cycleCount[2:0]};
                    end
                    9'b001110xxx: begin
                        indexA_reg = {7'b0011100, cycleCount[2:0]};
                    end
                    9'b001111xxx: begin
                        indexA_reg = {7'b0011110, cycleCount[2:0]};
                    end
                    9'b010000xxx: begin
                        indexA_reg = {7'b0100000, cycleCount[2:0]};
                    end
                    9'b010001xxx: begin
                        indexA_reg = {7'b0100010, cycleCount[2:0]};
                    end
                    9'b010010xxx: begin
                        indexA_reg = {7'b0100100, cycleCount[2:0]};
                    end
                    9'b010011xxx: begin
                        indexA_reg = {7'b0100110, cycleCount[2:0]};
                    end
                    9'b010100xxx: begin
                        indexA_reg = {7'b0101000, cycleCount[2:0]};
                    end
                    9'b010101xxx: begin
                        indexA_reg = {7'b0101010, cycleCount[2:0]};
                    end
                    9'b010110xxx: begin
                        indexA_reg = {7'b0101100, cycleCount[2:0]};
                    end
                    9'b010111xxx: begin
                        indexA_reg = {7'b0101110, cycleCount[2:0]};
                    end
                    9'b011000xxx: begin
                        indexA_reg = {7'b0110000, cycleCount[2:0]};
                    end
                    9'b011001xxx: begin
                        indexA_reg = {7'b0110010, cycleCount[2:0]};
                    end
                    9'b011010xxx: begin
                        indexA_reg = {7'b0110100, cycleCount[2:0]};
                    end
                    9'b011011xxx: begin
                        indexA_reg = {7'b0110110, cycleCount[2:0]};
                    end
                    9'b011100xxx: begin
                        indexA_reg = {7'b0111000, cycleCount[2:0]};
                    end
                    9'b011101xxx: begin
                        indexA_reg = {7'b0111010, cycleCount[2:0]};
                    end
                    9'b011110xxx: begin
                        indexA_reg = {7'b0111100, cycleCount[2:0]};
                    end
                    9'b011111xxx: begin
                        indexA_reg = {7'b0111110, cycleCount[2:0]};
                    end
                    //////////////////
                    9'b100000xxx: begin
                        indexA_reg = {7'b1000000, cycleCount[2:0]};
                    end
                    9'b100001xxx: begin
                        indexA_reg = {7'b1000010, cycleCount[2:0]};
                    end
                    9'b100010xxx: begin
                        indexA_reg = {7'b1000100, cycleCount[2:0]};
                    end
                    9'b100011xxx: begin
                        indexA_reg = {7'b1000110, cycleCount[2:0]};
                    end
                    9'b100100xxx: begin
                        indexA_reg = {7'b1001000, cycleCount[2:0]};
                    end
                    9'b100101xxx: begin
                        indexA_reg = {7'b1001010, cycleCount[2:0]};
                    end
                    9'b100110xxx: begin
                        indexA_reg = {7'b1001100, cycleCount[2:0]};
                    end
                    9'b100111xxx: begin
                        indexA_reg = {7'b1001110, cycleCount[2:0]};
                    end
                    9'b101000xxx: begin
                        indexA_reg = {7'b1010000, cycleCount[2:0]};
                    end
                    9'b001001xxx: begin
                        indexA_reg = {7'b1010010, cycleCount[2:0]};
                    end
                    9'b101010xxx: begin
                        indexA_reg = {7'b1010100, cycleCount[2:0]};
                    end
                    9'b101011xxx: begin
                        indexA_reg = {7'b1010110, cycleCount[2:0]};
                    end
                    9'b101100xxx: begin
                        indexA_reg = {7'b1011000, cycleCount[2:0]};
                    end
                    9'b101101xxx: begin
                        indexA_reg = {7'b1011010, cycleCount[2:0]};
                    end
                    9'b101110xxx: begin
                        indexA_reg = {7'b1011100, cycleCount[2:0]};
                    end
                    9'b101111xxx: begin
                        indexA_reg = {7'b1011110, cycleCount[2:0]};
                    end
                    9'b110000xxx: begin
                        indexA_reg = {7'b1100000, cycleCount[2:0]};
                    end
                    9'b110001xxx: begin
                        indexA_reg = {7'b1100010, cycleCount[2:0]};
                    end
                    9'b110010xxx: begin
                        indexA_reg = {7'b1100100, cycleCount[2:0]};
                    end
                    9'b110011xxx: begin
                        indexA_reg = {7'b1100110, cycleCount[2:0]};
                    end
                    9'b110100xxx: begin
                        indexA_reg = {7'b1101000, cycleCount[2:0]};
                    end
                    9'b110101xxx: begin
                        indexA_reg = {7'b1101010, cycleCount[2:0]};
                    end
                    9'b110110xxx: begin
                        indexA_reg = {7'b1101100, cycleCount[2:0]};
                    end
                    9'b110111xxx: begin
                        indexA_reg = {7'b1101110, cycleCount[2:0]};
                    end
                    9'b111000xxx: begin
                        indexA_reg = {7'b1110000, cycleCount[2:0]};
                    end
                    9'b111001xxx: begin
                        indexA_reg = {7'b1110010, cycleCount[2:0]};
                    end
                    9'b111010xxx: begin
                        indexA_reg = {7'b1110100, cycleCount[2:0]};
                    end
                    9'b111011xxx: begin
                        indexA_reg = {7'b1110110, cycleCount[2:0]};
                    end
                    9'b111100xxx: begin
                        indexA_reg = {7'b1111000, cycleCount[2:0]};
                    end
                    9'b111101xxx: begin
                        indexA_reg = {7'b1111010, cycleCount[2:0]};
                    end
                    9'b111110xxx: begin
                        indexA_reg = {7'b1111100, cycleCount[2:0]};
                    end
                    9'b111111xxx: begin
                        indexA_reg = {7'b1111110, cycleCount[2:0]};
                    end
                endcase
            end
            5'h07: begin
                case(cycleCount)
                    9'b0000000xx: begin
                        indexA_reg = {8'b00000000, cycleCount[1:0]};
                    end
                    9'b0000001xx: begin
                        indexA_reg = {8'b00000010, cycleCount[1:0]};
                    end
                    9'b0000010xx: begin
                        indexA_reg = {8'b00000100, cycleCount[1:0]};
                    end
                    9'b0000011xx: begin
                        indexA_reg = {8'b00000110, cycleCount[1:0]};
                    end
                    9'b0000100xx: begin
                        indexA_reg = {8'b00001000, cycleCount[1:0]};
                    end
                    9'b0000101xx: begin
                        indexA_reg = {8'b00001010, cycleCount[1:0]};
                    end
                    9'b0000110xx: begin
                        indexA_reg = {8'b00001100, cycleCount[1:0]};
                    end
                    9'b0000111xx: begin
                        indexA_reg = {8'b00001110, cycleCount[1:0]};
                    end
                    9'b0001000xx: begin
                        indexA_reg = {8'b00010000, cycleCount[1:0]};
                    end
                    9'b0001001xx: begin
                        indexA_reg = {8'b00010010, cycleCount[1:0]};
                    end
                    9'b0001010xx: begin
                        indexA_reg = {8'b00010100, cycleCount[1:0]};
                    end
                    9'b0001011xx: begin
                        indexA_reg = {8'b00010110, cycleCount[1:0]};
                    end
                    9'b0001100xx: begin
                        indexA_reg = {8'b00011000, cycleCount[1:0]};
                    end
                    9'b0001101xx: begin
                        indexA_reg = {8'b00011010, cycleCount[1:0]};
                    end
                    9'b0001110xx: begin
                        indexA_reg = {8'b00011100, cycleCount[1:0]};
                    end
                    9'b0001111xx: begin
                        indexA_reg = {8'b00011110, cycleCount[1:0]};
                    end
                    9'b0010000xx: begin
                        indexA_reg = {8'b00100000, cycleCount[1:0]};
                    end
                    9'b0010001xx: begin
                        indexA_reg = {8'b00100010, cycleCount[1:0]};
                    end
                    9'b0010010xx: begin
                        indexA_reg = {8'b00100100, cycleCount[1:0]};
                    end
                    9'b0010011xx: begin
                        indexA_reg = {8'b00100110, cycleCount[1:0]};
                    end
                    9'b0010100xx: begin
                        indexA_reg = {8'b00101000, cycleCount[1:0]};
                    end
                    9'b0010101xx: begin
                        indexA_reg = {8'b00101010, cycleCount[1:0]};
                    end
                    9'b0010110xx: begin
                        indexA_reg = {8'b00101100, cycleCount[1:0]};
                    end
                    9'b0010111xx: begin
                        indexA_reg = {8'b00101110, cycleCount[1:0]};
                    end
                    9'b0011000xx: begin
                        indexA_reg = {8'b00110000, cycleCount[1:0]};
                    end
                    9'b0011001xx: begin
                        indexA_reg = {8'b00110010, cycleCount[1:0]};
                    end
                    9'b0011010xx: begin
                        indexA_reg = {8'b00110100, cycleCount[1:0]};
                    end
                    9'b0011011xx: begin
                        indexA_reg = {8'b00110110, cycleCount[1:0]};
                    end
                    9'b0011100xx: begin
                        indexA_reg = {8'b00111000, cycleCount[1:0]};
                    end
                    9'b0011101xx: begin
                        indexA_reg = {8'b00111010, cycleCount[1:0]};
                    end
                    9'b0011110xx: begin
                        indexA_reg = {8'b00111100, cycleCount[1:0]};
                    end
                    9'b0011111xx: begin
                        indexA_reg = {8'b00111110, cycleCount[1:0]};
                    end
                    9'b0100000xx: begin
                        indexA_reg = {8'b01000000, cycleCount[1:0]};
                    end
                    9'b0100001xx: begin
                        indexA_reg = {8'b01000010, cycleCount[1:0]};
                    end
                    9'b0100010xx: begin
                        indexA_reg = {8'b01000100, cycleCount[1:0]};
                    end
                    9'b0100011xx: begin
                        indexA_reg = {8'b01000110, cycleCount[1:0]};
                    end
                    9'b0100100xx: begin
                        indexA_reg = {8'b01001000, cycleCount[1:0]};
                    end
                    9'b0100101xx: begin
                        indexA_reg = {8'b01001010, cycleCount[1:0]};
                    end
                    9'b0100110xx: begin
                        indexA_reg = {8'b01001100, cycleCount[1:0]};
                    end
                    9'b0100111xx: begin
                        indexA_reg = {8'b01001110, cycleCount[1:0]};
                    end
                    9'b0101000xx: begin
                        indexA_reg = {8'b01010000, cycleCount[1:0]};
                    end
                    9'b0001001xx: begin
                        indexA_reg = {8'b01010010, cycleCount[1:0]};
                    end
                    9'b0101010xx: begin
                        indexA_reg = {8'b01010100, cycleCount[1:0]};
                    end
                    9'b0101011xx: begin
                        indexA_reg = {8'b01010110, cycleCount[1:0]};
                    end
                    9'b0101100xx: begin
                        indexA_reg = {8'b01011000, cycleCount[1:0]};
                    end
                    9'b0101101xx: begin
                        indexA_reg = {8'b01011010, cycleCount[1:0]};
                    end
                    9'b0101110xx: begin
                        indexA_reg = {8'b01011100, cycleCount[1:0]};
                    end
                    9'b0101111xx: begin
                        indexA_reg = {8'b01011110, cycleCount[1:0]};
                    end
                    9'b0110000xx: begin
                        indexA_reg = {8'b01100000, cycleCount[1:0]};
                    end
                    9'b0110001xx: begin
                        indexA_reg = {8'b01100010, cycleCount[1:0]};
                    end
                    9'b0110010xx: begin
                        indexA_reg = {8'b01100100, cycleCount[1:0]};
                    end
                    9'b0110011xx: begin
                        indexA_reg = {8'b01100110, cycleCount[1:0]};
                    end
                    9'b0110100xx: begin
                        indexA_reg = {8'b01101000, cycleCount[1:0]};
                    end
                    9'b0110101xx: begin
                        indexA_reg = {8'b01101010, cycleCount[1:0]};
                    end
                    9'b0110110xx: begin
                        indexA_reg = {8'b01101100, cycleCount[1:0]};
                    end
                    9'b0110111xx: begin
                        indexA_reg = {8'b01101110, cycleCount[1:0]};
                    end
                    9'b0111000xx: begin
                        indexA_reg = {8'b01110000, cycleCount[1:0]};
                    end
                    9'b0111001xx: begin
                        indexA_reg = {8'b01110010, cycleCount[1:0]};
                    end
                    9'b0111010xx: begin
                        indexA_reg = {8'b01110100, cycleCount[1:0]};
                    end
                    9'b0111011xx: begin
                        indexA_reg = {8'b01110110, cycleCount[1:0]};
                    end
                    9'b0111100xx: begin
                        indexA_reg = {8'b01111000, cycleCount[1:0]};
                    end
                    9'b0111101xx: begin
                        indexA_reg = {8'b01111010, cycleCount[1:0]};
                    end
                    9'b0111110xx: begin
                        indexA_reg = {8'b01111100, cycleCount[1:0]};
                    end
                    9'b0111111xx: begin
                        indexA_reg = {8'b01111110, cycleCount[1:0]};
                    end
                    ///////////////
                    9'b1000000xx: begin
                        indexA_reg = {8'b10000000, cycleCount[1:0]};
                    end
                    9'b1000001xx: begin
                        indexA_reg = {8'b10000010, cycleCount[1:0]};
                    end
                    9'b1000010xx: begin
                        indexA_reg = {8'b10000100, cycleCount[1:0]};
                    end
                    9'b1000011xx: begin
                        indexA_reg = {8'b10000110, cycleCount[1:0]};
                    end
                    9'b1000100xx: begin
                        indexA_reg = {8'b10001000, cycleCount[1:0]};
                    end
                    9'b1000101xx: begin
                        indexA_reg = {8'b10001010, cycleCount[1:0]};
                    end
                    9'b1000110xx: begin
                        indexA_reg = {8'b10001100, cycleCount[1:0]};
                    end
                    9'b1000111xx: begin
                        indexA_reg = {8'b10001110, cycleCount[1:0]};
                    end
                    9'b1001000xx: begin
                        indexA_reg = {8'b10010000, cycleCount[1:0]};
                    end
                    9'b1001001xx: begin
                        indexA_reg = {8'b10010010, cycleCount[1:0]};
                    end
                    9'b1001010xx: begin
                        indexA_reg = {8'b10010100, cycleCount[1:0]};
                    end
                    9'b1001011xx: begin
                        indexA_reg = {8'b10010110, cycleCount[1:0]};
                    end
                    9'b1001100xx: begin
                        indexA_reg = {8'b10011000, cycleCount[1:0]};
                    end
                    9'b1001101xx: begin
                        indexA_reg = {8'b10011010, cycleCount[1:0]};
                    end
                    9'b1001110xx: begin
                        indexA_reg = {8'b10011100, cycleCount[1:0]};
                    end
                    9'b1001111xx: begin
                        indexA_reg = {8'b10011110, cycleCount[1:0]};
                    end
                    9'b1010000xx: begin
                        indexA_reg = {8'b10100000, cycleCount[1:0]};
                    end
                    9'b1010001xx: begin
                        indexA_reg = {8'b10100010, cycleCount[1:0]};
                    end
                    9'b1010010xx: begin
                        indexA_reg = {8'b10100100, cycleCount[1:0]};
                    end
                    9'b1010011xx: begin
                        indexA_reg = {8'b10100110, cycleCount[1:0]};
                    end
                    9'b1010100xx: begin
                        indexA_reg = {8'b10101000, cycleCount[1:0]};
                    end
                    9'b1010101xx: begin
                        indexA_reg = {8'b10101010, cycleCount[1:0]};
                    end
                    9'b1010110xx: begin
                        indexA_reg = {8'b10101100, cycleCount[1:0]};
                    end
                    9'b1010111xx: begin
                        indexA_reg = {8'b10101110, cycleCount[1:0]};
                    end
                    9'b1011000xx: begin
                        indexA_reg = {8'b10110000, cycleCount[1:0]};
                    end
                    9'b1011001xx: begin
                        indexA_reg = {8'b10110010, cycleCount[1:0]};
                    end
                    9'b1011010xx: begin
                        indexA_reg = {8'b10110100, cycleCount[1:0]};
                    end
                    9'b1011011xx: begin
                        indexA_reg = {8'b10110110, cycleCount[1:0]};
                    end
                    9'b1011100xx: begin
                        indexA_reg = {8'b10111000, cycleCount[1:0]};
                    end
                    9'b1011101xx: begin
                        indexA_reg = {8'b10111010, cycleCount[1:0]};
                    end
                    9'b1011110xx: begin
                        indexA_reg = {8'b10111100, cycleCount[1:0]};
                    end
                    9'b1011111xx: begin
                        indexA_reg = {8'b10111110, cycleCount[1:0]};
                    end
                    9'b1100000xx: begin
                        indexA_reg = {8'b11000000, cycleCount[1:0]};
                    end
                    9'b1100001xx: begin
                        indexA_reg = {8'b11000010, cycleCount[1:0]};
                    end
                    9'b1100010xx: begin
                        indexA_reg = {8'b11000100, cycleCount[1:0]};
                    end
                    9'b1100011xx: begin
                        indexA_reg = {8'b11000110, cycleCount[1:0]};
                    end
                    9'b1100100xx: begin
                        indexA_reg = {8'b11001000, cycleCount[1:0]};
                    end
                    9'b1100101xx: begin
                        indexA_reg = {8'b11001010, cycleCount[1:0]};
                    end
                    9'b1100110xx: begin
                        indexA_reg = {8'b11001100, cycleCount[1:0]};
                    end
                    9'b1100111xx: begin
                        indexA_reg = {8'b11001110, cycleCount[1:0]};
                    end
                    9'b1101000xx: begin
                        indexA_reg = {8'b11010000, cycleCount[1:0]};
                    end
                    9'b1001001xx: begin
                        indexA_reg = {8'b11010010, cycleCount[1:0]};
                    end
                    9'b1101010xx: begin
                        indexA_reg = {8'b11010100, cycleCount[1:0]};
                    end
                    9'b1101011xx: begin
                        indexA_reg = {8'b11010110, cycleCount[1:0]};
                    end
                    9'b1101100xx: begin
                        indexA_reg = {8'b11011000, cycleCount[1:0]};
                    end
                    9'b1101101xx: begin
                        indexA_reg = {8'b11011010, cycleCount[1:0]};
                    end
                    9'b1101110xx: begin
                        indexA_reg = {8'b11011100, cycleCount[1:0]};
                    end
                    9'b1101111xx: begin
                        indexA_reg = {8'b11011110, cycleCount[1:0]};
                    end
                    9'b1110000xx: begin
                        indexA_reg = {8'b11100000, cycleCount[1:0]};
                    end
                    9'b1110001xx: begin
                        indexA_reg = {8'b11100010, cycleCount[1:0]};
                    end
                    9'b1110010xx: begin
                        indexA_reg = {8'b11100100, cycleCount[1:0]};
                    end
                    9'b1110011xx: begin
                        indexA_reg = {8'b11100110, cycleCount[1:0]};
                    end
                    9'b1110100xx: begin
                        indexA_reg = {8'b11101000, cycleCount[1:0]};
                    end
                    9'b1110101xx: begin
                        indexA_reg = {8'b11101010, cycleCount[1:0]};
                    end
                    9'b1110110xx: begin
                        indexA_reg = {8'b11101100, cycleCount[1:0]};
                    end
                    9'b1110111xx: begin
                        indexA_reg = {8'b11101110, cycleCount[1:0]};
                    end
                    9'b1111000xx: begin
                        indexA_reg = {8'b11110000, cycleCount[1:0]};
                    end
                    9'b1111001xx: begin
                        indexA_reg = {8'b11110010, cycleCount[1:0]};
                    end
                    9'b1111010xx: begin
                        indexA_reg = {8'b11110100, cycleCount[1:0]};
                    end
                    9'b1111011xx: begin
                        indexA_reg = {8'b11110110, cycleCount[1:0]};
                    end
                    9'b1111100xx: begin
                        indexA_reg = {8'b11111000, cycleCount[1:0]};
                    end
                    9'b1111101xx: begin
                        indexA_reg = {8'b11111010, cycleCount[1:0]};
                    end
                    9'b1111110xx: begin
                        indexA_reg = {8'b11111100, cycleCount[1:0]};
                    end
                    9'b1111111xx: begin
                        indexA_reg = {8'b11111110, cycleCount[1:0]};
                    end
                endcase
            end
            5'h08: begin
                case(cycleCount)
                    9'b00000000x: begin
                        indexA_reg = {9'b000000000, cycleCount[0]};
                    end
                    9'b00000001x: begin
                        indexA_reg = {9'b000000010, cycleCount[0]};
                    end
                    9'b00000010x: begin
                        indexA_reg = {9'b000000100, cycleCount[0]};
                    end
                    9'b00000011x: begin
                        indexA_reg = {9'b000000110, cycleCount[0]};
                    end
                    9'b00000100x: begin
                        indexA_reg = {9'b000001000, cycleCount[0]};
                    end
                    9'b00000101x: begin
                        indexA_reg = {9'b000001010, cycleCount[0]};
                    end
                    9'b00000110x: begin
                        indexA_reg = {9'b000001100, cycleCount[0]};
                    end
                    9'b00000111x: begin
                        indexA_reg = {9'b000001110, cycleCount[0]};
                    end
                    9'b00001000x: begin
                        indexA_reg = {9'b000010000, cycleCount[0]};
                    end
                    9'b00001001x: begin
                        indexA_reg = {9'b000010010, cycleCount[0]};
                    end
                    9'b00001010x: begin
                        indexA_reg = {9'b000010100, cycleCount[0]};
                    end
                    9'b00001011x: begin
                        indexA_reg = {9'b000010110, cycleCount[0]};
                    end
                    9'b00001100x: begin
                        indexA_reg = {9'b000011000, cycleCount[0]};
                    end
                    9'b00001101x: begin
                        indexA_reg = {9'b000011010, cycleCount[0]};
                    end
                    9'b00001110x: begin
                        indexA_reg = {9'b000011100, cycleCount[0]};
                    end
                    9'b00001111x: begin
                        indexA_reg = {9'b000011110, cycleCount[0]};
                    end
                    9'b00010000x: begin
                        indexA_reg = {9'b000100000, cycleCount[0]};
                    end
                    9'b00010001x: begin
                        indexA_reg = {9'b000100010, cycleCount[0]};
                    end
                    9'b00010010x: begin
                        indexA_reg = {9'b000100100, cycleCount[0]};
                    end
                    9'b00010011x: begin
                        indexA_reg = {9'b000100110, cycleCount[0]};
                    end
                    9'b00010100x: begin
                        indexA_reg = {9'b000101000, cycleCount[0]};
                    end
                    9'b00010101x: begin
                        indexA_reg = {9'b000101010, cycleCount[0]};
                    end
                    9'b00010110x: begin
                        indexA_reg = {9'b000101100, cycleCount[0]};
                    end
                    9'b00010111x: begin
                        indexA_reg = {9'b000101110, cycleCount[0]};
                    end
                    9'b00011000x: begin
                        indexA_reg = {9'b000110000, cycleCount[0]};
                    end
                    9'b00011001x: begin
                        indexA_reg = {9'b000110010, cycleCount[0]};
                    end
                    9'b00011010x: begin
                        indexA_reg = {9'b000110100, cycleCount[0]};
                    end
                    9'b00011011x: begin
                        indexA_reg = {9'b000110110, cycleCount[0]};
                    end
                    9'b00011100x: begin
                        indexA_reg = {9'b000111000, cycleCount[0]};
                    end
                    9'b00011101x: begin
                        indexA_reg = {9'b000111010, cycleCount[0]};
                    end
                    9'b00011110x: begin
                        indexA_reg = {9'b000111100, cycleCount[0]};
                    end
                    9'b00011111x: begin
                        indexA_reg = {9'b000111110, cycleCount[0]};
                    end
                    9'b00100000x: begin
                        indexA_reg = {9'b001000000, cycleCount[0]};
                    end
                    9'b00100001x: begin
                        indexA_reg = {9'b001000010, cycleCount[0]};
                    end
                    9'b00100010x: begin
                        indexA_reg = {9'b001000100, cycleCount[0]};
                    end
                    9'b00100011x: begin
                        indexA_reg = {9'b001000110, cycleCount[0]};
                    end
                    9'b00100100x: begin
                        indexA_reg = {9'b001001000, cycleCount[0]};
                    end
                    9'b00100101x: begin
                        indexA_reg = {9'b001001010, cycleCount[0]};
                    end
                    9'b00100110x: begin
                        indexA_reg = {9'b001001100, cycleCount[0]};
                    end
                    9'b00100111x: begin
                        indexA_reg = {9'b001001110, cycleCount[0]};
                    end
                    9'b00101000x: begin
                        indexA_reg = {9'b001010000, cycleCount[0]};
                    end
                    9'b00001001x: begin
                        indexA_reg = {9'b001010010, cycleCount[0]};
                    end
                    9'b00101010x: begin
                        indexA_reg = {9'b001010100, cycleCount[0]};
                    end
                    9'b00101011x: begin
                        indexA_reg = {9'b001010110, cycleCount[0]};
                    end
                    9'b00101100x: begin
                        indexA_reg = {9'b001011000, cycleCount[0]};
                    end
                    9'b00101101x: begin
                        indexA_reg = {9'b001011010, cycleCount[0]};
                    end
                    9'b00101110x: begin
                        indexA_reg = {9'b001011100, cycleCount[0]};
                    end
                    9'b00101111x: begin
                        indexA_reg = {9'b001011110, cycleCount[0]};
                    end
                    9'b00110000x: begin
                        indexA_reg = {9'b001100000, cycleCount[0]};
                    end
                    9'b00110001x: begin
                        indexA_reg = {9'b001100010, cycleCount[0]};
                    end
                    9'b00110010x: begin
                        indexA_reg = {9'b001100100, cycleCount[0]};
                    end
                    9'b00110011x: begin
                        indexA_reg = {9'b001100110, cycleCount[0]};
                    end
                    9'b00110100x: begin
                        indexA_reg = {9'b001101000, cycleCount[0]};
                    end
                    9'b00110101x: begin
                        indexA_reg = {9'b001101010, cycleCount[0]};
                    end
                    9'b00110110x: begin
                        indexA_reg = {9'b001101100, cycleCount[0]};
                    end
                    9'b00110111x: begin
                        indexA_reg = {9'b001101110, cycleCount[0]};
                    end
                    9'b00111000x: begin
                        indexA_reg = {9'b001110000, cycleCount[0]};
                    end
                    9'b00111001x: begin
                        indexA_reg = {9'b001110010, cycleCount[0]};
                    end
                    9'b00111010x: begin
                        indexA_reg = {9'b001110100, cycleCount[0]};
                    end
                    9'b00111011x: begin
                        indexA_reg = {9'b001110110, cycleCount[0]};
                    end
                    9'b00111100x: begin
                        indexA_reg = {9'b001111000, cycleCount[0]};
                    end
                    9'b00111101x: begin
                        indexA_reg = {9'b001111010, cycleCount[0]};
                    end
                    9'b00111110x: begin
                        indexA_reg = {9'b001111100, cycleCount[0]};
                    end
                    9'b00111111x: begin
                        indexA_reg = {9'b001111110, cycleCount[0]};
                    end
                    9'b01000000x: begin
                        indexA_reg = {9'b010000000, cycleCount[0]};
                    end
                    9'b01000001x: begin
                        indexA_reg = {9'b010000010, cycleCount[0]};
                    end
                    9'b01000010x: begin
                        indexA_reg = {9'b010000100, cycleCount[0]};
                    end
                    9'b01000011x: begin
                        indexA_reg = {9'b010000110, cycleCount[0]};
                    end
                    9'b01000100x: begin
                        indexA_reg = {9'b010001000, cycleCount[0]};
                    end
                    9'b01000101x: begin
                        indexA_reg = {9'b010001010, cycleCount[0]};
                    end
                    9'b01000110x: begin
                        indexA_reg = {9'b010001100, cycleCount[0]};
                    end
                    9'b01000111x: begin
                        indexA_reg = {9'b010001110, cycleCount[0]};
                    end
                    9'b01001000x: begin
                        indexA_reg = {9'b010010000, cycleCount[0]};
                    end
                    9'b01001001x: begin
                        indexA_reg = {9'b010010010, cycleCount[0]};
                    end
                    9'b01001010x: begin
                        indexA_reg = {9'b010010100, cycleCount[0]};
                    end
                    9'b01001011x: begin
                        indexA_reg = {9'b010010110, cycleCount[0]};
                    end
                    9'b01001100x: begin
                        indexA_reg = {9'b010011000, cycleCount[0]};
                    end
                    9'b01001101x: begin
                        indexA_reg = {9'b010011010, cycleCount[0]};
                    end
                    9'b01001110x: begin
                        indexA_reg = {9'b010011100, cycleCount[0]};
                    end
                    9'b01001111x: begin
                        indexA_reg = {9'b010011110, cycleCount[0]};
                    end
                    9'b01010000x: begin
                        indexA_reg = {9'b010100000, cycleCount[0]};
                    end
                    9'b01010001x: begin
                        indexA_reg = {9'b010100010, cycleCount[0]};
                    end
                    9'b01010010x: begin
                        indexA_reg = {9'b010100100, cycleCount[0]};
                    end
                    9'b01010011x: begin
                        indexA_reg = {9'b010100110, cycleCount[0]};
                    end
                    9'b01010100x: begin
                        indexA_reg = {9'b010101000, cycleCount[0]};
                    end
                    9'b01010101x: begin
                        indexA_reg = {9'b010101010, cycleCount[0]};
                    end
                    9'b01010110x: begin
                        indexA_reg = {9'b010101100, cycleCount[0]};
                    end
                    9'b01010111x: begin
                        indexA_reg = {9'b010101110, cycleCount[0]};
                    end
                    9'b01011000x: begin
                        indexA_reg = {9'b010110000, cycleCount[0]};
                    end
                    9'b01011001x: begin
                        indexA_reg = {9'b010110010, cycleCount[0]};
                    end
                    9'b01011010x: begin
                        indexA_reg = {9'b010110100, cycleCount[0]};
                    end
                    9'b01011011x: begin
                        indexA_reg = {9'b010110110, cycleCount[0]};
                    end
                    9'b01011100x: begin
                        indexA_reg = {9'b010111000, cycleCount[0]};
                    end
                    9'b01011101x: begin
                        indexA_reg = {9'b010111010, cycleCount[0]};
                    end
                    9'b01011110x: begin
                        indexA_reg = {9'b010111100, cycleCount[0]};
                    end
                    9'b01011111x: begin
                        indexA_reg = {9'b010111110, cycleCount[0]};
                    end
                    9'b01100000x: begin
                        indexA_reg = {9'b011000000, cycleCount[0]};
                    end
                    9'b01100001x: begin
                        indexA_reg = {9'b011000010, cycleCount[0]};
                    end
                    9'b01100010x: begin
                        indexA_reg = {9'b011000100, cycleCount[0]};
                    end
                    9'b01100011x: begin
                        indexA_reg = {9'b011000110, cycleCount[0]};
                    end
                    9'b01100100x: begin
                        indexA_reg = {9'b011001000, cycleCount[0]};
                    end
                    9'b01100101x: begin
                        indexA_reg = {9'b011001010, cycleCount[0]};
                    end
                    9'b01100110x: begin
                        indexA_reg = {9'b011001100, cycleCount[0]};
                    end
                    9'b01100111x: begin
                        indexA_reg = {9'b011001110, cycleCount[0]};
                    end
                    9'b01101000x: begin
                        indexA_reg = {9'b011010000, cycleCount[0]};
                    end
                    9'b01001001x: begin
                        indexA_reg = {9'b011010010, cycleCount[0]};
                    end
                    9'b01101010x: begin
                        indexA_reg = {9'b011010100, cycleCount[0]};
                    end
                    9'b01101011x: begin
                        indexA_reg = {9'b011010110, cycleCount[0]};
                    end
                    9'b01101100x: begin
                        indexA_reg = {9'b011011000, cycleCount[0]};
                    end
                    9'b01101101x: begin
                        indexA_reg = {9'b011011010, cycleCount[0]};
                    end
                    9'b01101110x: begin
                        indexA_reg = {9'b011011100, cycleCount[0]};
                    end
                    9'b01101111x: begin
                        indexA_reg = {9'b011011110, cycleCount[0]};
                    end
                    9'b01110000x: begin
                        indexA_reg = {9'b011100000, cycleCount[0]};
                    end
                    9'b01110001x: begin
                        indexA_reg = {9'b011100010, cycleCount[0]};
                    end
                    9'b01110010x: begin
                        indexA_reg = {9'b011100100, cycleCount[0]};
                    end
                    9'b01110011x: begin
                        indexA_reg = {9'b011100110, cycleCount[0]};
                    end
                    9'b01110100x: begin
                        indexA_reg = {9'b011101000, cycleCount[0]};
                    end
                    9'b01110101x: begin
                        indexA_reg = {9'b011101010, cycleCount[0]};
                    end
                    9'b01110110x: begin
                        indexA_reg = {9'b011101100, cycleCount[0]};
                    end
                    9'b01110111x: begin
                        indexA_reg = {9'b011101110, cycleCount[0]};
                    end
                    9'b01111000x: begin
                        indexA_reg = {9'b011110000, cycleCount[0]};
                    end
                    9'b01111001x: begin
                        indexA_reg = {9'b011110010, cycleCount[0]};
                    end
                    9'b01111010x: begin
                        indexA_reg = {9'b011110100, cycleCount[0]};
                    end
                    9'b01111011x: begin
                        indexA_reg = {9'b011110110, cycleCount[0]};
                    end
                    9'b01111100x: begin
                        indexA_reg = {9'b011111000, cycleCount[0]};
                    end
                    9'b01111101x: begin
                        indexA_reg = {9'b011111010, cycleCount[0]};
                    end
                    9'b01111110x: begin
                        indexA_reg = {9'b011111100, cycleCount[0]};
                    end
                    9'b01111111x: begin
                        indexA_reg = {9'b011111110, cycleCount[0]};
                    end
                    
                    ///////////////

                    9'b10000000x: begin
                        indexA_reg = {9'b100000000, cycleCount[0]};
                    end
                    9'b10000001x: begin
                        indexA_reg = {9'b100000010, cycleCount[0]};
                    end
                    9'b10000010x: begin
                        indexA_reg = {9'b100000100, cycleCount[0]};
                    end
                    9'b10000011x: begin
                        indexA_reg = {9'b100000110, cycleCount[0]};
                    end
                    9'b10000100x: begin
                        indexA_reg = {9'b100001000, cycleCount[0]};
                    end
                    9'b10000101x: begin
                        indexA_reg = {9'b100001010, cycleCount[0]};
                    end
                    9'b10000110x: begin
                        indexA_reg = {9'b100001100, cycleCount[0]};
                    end
                    9'b10000111x: begin
                        indexA_reg = {9'b100001110, cycleCount[0]};
                    end
                    9'b10001000x: begin
                        indexA_reg = {9'b100010000, cycleCount[0]};
                    end
                    9'b10001001x: begin
                        indexA_reg = {9'b100010010, cycleCount[0]};
                    end
                    9'b10001010x: begin
                        indexA_reg = {9'b100010100, cycleCount[0]};
                    end
                    9'b10001011x: begin
                        indexA_reg = {9'b100010110, cycleCount[0]};
                    end
                    9'b10001100x: begin
                        indexA_reg = {9'b100011000, cycleCount[0]};
                    end
                    9'b10001101x: begin
                        indexA_reg = {9'b100011010, cycleCount[0]};
                    end
                    9'b10001110x: begin
                        indexA_reg = {9'b100011100, cycleCount[0]};
                    end
                    9'b10001111x: begin
                        indexA_reg = {9'b100011110, cycleCount[0]};
                    end
                    9'b10010000x: begin
                        indexA_reg = {9'b100100000, cycleCount[0]};
                    end
                    9'b10010001x: begin
                        indexA_reg = {9'b100100010, cycleCount[0]};
                    end
                    9'b10010010x: begin
                        indexA_reg = {9'b100100100, cycleCount[0]};
                    end
                    9'b10010011x: begin
                        indexA_reg = {9'b100100110, cycleCount[0]};
                    end
                    9'b10010100x: begin
                        indexA_reg = {9'b100101000, cycleCount[0]};
                    end
                    9'b10010101x: begin
                        indexA_reg = {9'b100101010, cycleCount[0]};
                    end
                    9'b10010110x: begin
                        indexA_reg = {9'b100101100, cycleCount[0]};
                    end
                    9'b10010111x: begin
                        indexA_reg = {9'b100101110, cycleCount[0]};
                    end
                    9'b10011000x: begin
                        indexA_reg = {9'b100110000, cycleCount[0]};
                    end
                    9'b10011001x: begin
                        indexA_reg = {9'b100110010, cycleCount[0]};
                    end
                    9'b10011010x: begin
                        indexA_reg = {9'b100110100, cycleCount[0]};
                    end
                    9'b10011011x: begin
                        indexA_reg = {9'b100110110, cycleCount[0]};
                    end
                    9'b10011100x: begin
                        indexA_reg = {9'b100111000, cycleCount[0]};
                    end
                    9'b10011101x: begin
                        indexA_reg = {9'b100111010, cycleCount[0]};
                    end
                    9'b10011110x: begin
                        indexA_reg = {9'b100111100, cycleCount[0]};
                    end
                    9'b10011111x: begin
                        indexA_reg = {9'b100111110, cycleCount[0]};
                    end
                    9'b10100000x: begin
                        indexA_reg = {9'b101000000, cycleCount[0]};
                    end
                    9'b10100001x: begin
                        indexA_reg = {9'b101000010, cycleCount[0]};
                    end
                    9'b10100010x: begin
                        indexA_reg = {9'b101000100, cycleCount[0]};
                    end
                    9'b10100011x: begin
                        indexA_reg = {9'b101000110, cycleCount[0]};
                    end
                    9'b10100100x: begin
                        indexA_reg = {9'b101001000, cycleCount[0]};
                    end
                    9'b10100101x: begin
                        indexA_reg = {9'b101001010, cycleCount[0]};
                    end
                    9'b10100110x: begin
                        indexA_reg = {9'b101001100, cycleCount[0]};
                    end
                    9'b10100111x: begin
                        indexA_reg = {9'b101001110, cycleCount[0]};
                    end
                    9'b10101000x: begin
                        indexA_reg = {9'b101010000, cycleCount[0]};
                    end
                    9'b10001001x: begin
                        indexA_reg = {9'b101010010, cycleCount[0]};
                    end
                    9'b10101010x: begin
                        indexA_reg = {9'b101010100, cycleCount[0]};
                    end
                    9'b10101011x: begin
                        indexA_reg = {9'b101010110, cycleCount[0]};
                    end
                    9'b10101100x: begin
                        indexA_reg = {9'b101011000, cycleCount[0]};
                    end
                    9'b10101101x: begin
                        indexA_reg = {9'b101011010, cycleCount[0]};
                    end
                    9'b10101110x: begin
                        indexA_reg = {9'b101011100, cycleCount[0]};
                    end
                    9'b10101111x: begin
                        indexA_reg = {9'b101011110, cycleCount[0]};
                    end
                    9'b10110000x: begin
                        indexA_reg = {9'b101100000, cycleCount[0]};
                    end
                    9'b10110001x: begin
                        indexA_reg = {9'b101100010, cycleCount[0]};
                    end
                    9'b10110010x: begin
                        indexA_reg = {9'b101100100, cycleCount[0]};
                    end
                    9'b10110011x: begin
                        indexA_reg = {9'b101100110, cycleCount[0]};
                    end
                    9'b10110100x: begin
                        indexA_reg = {9'b101101000, cycleCount[0]};
                    end
                    9'b10110101x: begin
                        indexA_reg = {9'b101101010, cycleCount[0]};
                    end
                    9'b10110110x: begin
                        indexA_reg = {9'b101101100, cycleCount[0]};
                    end
                    9'b10110111x: begin
                        indexA_reg = {9'b101101110, cycleCount[0]};
                    end
                    9'b10111000x: begin
                        indexA_reg = {9'b101110000, cycleCount[0]};
                    end
                    9'b10111001x: begin
                        indexA_reg = {9'b101110010, cycleCount[0]};
                    end
                    9'b10111010x: begin
                        indexA_reg = {9'b101110100, cycleCount[0]};
                    end
                    9'b10111011x: begin
                        indexA_reg = {9'b101110110, cycleCount[0]};
                    end
                    9'b10111100x: begin
                        indexA_reg = {9'b101111000, cycleCount[0]};
                    end
                    9'b10111101x: begin
                        indexA_reg = {9'b101111010, cycleCount[0]};
                    end
                    9'b10111110x: begin
                        indexA_reg = {9'b101111100, cycleCount[0]};
                    end
                    9'b10111111x: begin
                        indexA_reg = {9'b101111110, cycleCount[0]};
                    end
                    9'b11000000x: begin
                        indexA_reg = {9'b110000000, cycleCount[0]};
                    end
                    9'b11000001x: begin
                        indexA_reg = {9'b110000010, cycleCount[0]};
                    end
                    9'b11000010x: begin
                        indexA_reg = {9'b110000100, cycleCount[0]};
                    end
                    9'b11000011x: begin
                        indexA_reg = {9'b110000110, cycleCount[0]};
                    end
                    9'b11000100x: begin
                        indexA_reg = {9'b110001000, cycleCount[0]};
                    end
                    9'b11000101x: begin
                        indexA_reg = {9'b110001010, cycleCount[0]};
                    end
                    9'b11000110x: begin
                        indexA_reg = {9'b110001100, cycleCount[0]};
                    end
                    9'b11000111x: begin
                        indexA_reg = {9'b110001110, cycleCount[0]};
                    end
                    9'b11001000x: begin
                        indexA_reg = {9'b110010000, cycleCount[0]};
                    end
                    9'b11001001x: begin
                        indexA_reg = {9'b110010010, cycleCount[0]};
                    end
                    9'b11001010x: begin
                        indexA_reg = {9'b110010100, cycleCount[0]};
                    end
                    9'b11001011x: begin
                        indexA_reg = {9'b110010110, cycleCount[0]};
                    end
                    9'b11001100x: begin
                        indexA_reg = {9'b110011000, cycleCount[0]};
                    end
                    9'b11001101x: begin
                        indexA_reg = {9'b110011010, cycleCount[0]};
                    end
                    9'b11001110x: begin
                        indexA_reg = {9'b110011100, cycleCount[0]};
                    end
                    9'b11001111x: begin
                        indexA_reg = {9'b110011110, cycleCount[0]};
                    end
                    9'b11010000x: begin
                        indexA_reg = {9'b110100000, cycleCount[0]};
                    end
                    9'b11010001x: begin
                        indexA_reg = {9'b110100010, cycleCount[0]};
                    end
                    9'b11010010x: begin
                        indexA_reg = {9'b110100100, cycleCount[0]};
                    end
                    9'b11010011x: begin
                        indexA_reg = {9'b110100110, cycleCount[0]};
                    end
                    9'b11010100x: begin
                        indexA_reg = {9'b110101000, cycleCount[0]};
                    end
                    9'b11010101x: begin
                        indexA_reg = {9'b110101010, cycleCount[0]};
                    end
                    9'b11010110x: begin
                        indexA_reg = {9'b110101100, cycleCount[0]};
                    end
                    9'b11010111x: begin
                        indexA_reg = {9'b110101110, cycleCount[0]};
                    end
                    9'b11011000x: begin
                        indexA_reg = {9'b110110000, cycleCount[0]};
                    end
                    9'b11011001x: begin
                        indexA_reg = {9'b110110010, cycleCount[0]};
                    end
                    9'b11011010x: begin
                        indexA_reg = {9'b110110100, cycleCount[0]};
                    end
                    9'b11011011x: begin
                        indexA_reg = {9'b110110110, cycleCount[0]};
                    end
                    9'b11011100x: begin
                        indexA_reg = {9'b110111000, cycleCount[0]};
                    end
                    9'b11011101x: begin
                        indexA_reg = {9'b110111010, cycleCount[0]};
                    end
                    9'b11011110x: begin
                        indexA_reg = {9'b110111100, cycleCount[0]};
                    end
                    9'b11011111x: begin
                        indexA_reg = {9'b110111110, cycleCount[0]};
                    end
                    9'b11100000x: begin
                        indexA_reg = {9'b111000000, cycleCount[0]};
                    end
                    9'b11100001x: begin
                        indexA_reg = {9'b111000010, cycleCount[0]};
                    end
                    9'b11100010x: begin
                        indexA_reg = {9'b111000100, cycleCount[0]};
                    end
                    9'b11100011x: begin
                        indexA_reg = {9'b111000110, cycleCount[0]};
                    end
                    9'b11100100x: begin
                        indexA_reg = {9'b111001000, cycleCount[0]};
                    end
                    9'b11100101x: begin
                        indexA_reg = {9'b111001010, cycleCount[0]};
                    end
                    9'b11100110x: begin
                        indexA_reg = {9'b111001100, cycleCount[0]};
                    end
                    9'b11100111x: begin
                        indexA_reg = {9'b111001110, cycleCount[0]};
                    end
                    9'b11101000x: begin
                        indexA_reg = {9'b111010000, cycleCount[0]};
                    end
                    9'b11001001x: begin
                        indexA_reg = {9'b111010010, cycleCount[0]};
                    end
                    9'b11101010x: begin
                        indexA_reg = {9'b111010100, cycleCount[0]};
                    end
                    9'b11101011x: begin
                        indexA_reg = {9'b111010110, cycleCount[0]};
                    end
                    9'b11101100x: begin
                        indexA_reg = {9'b111011000, cycleCount[0]};
                    end
                    9'b11101101x: begin
                        indexA_reg = {9'b111011010, cycleCount[0]};
                    end
                    9'b11101110x: begin
                        indexA_reg = {9'b111011100, cycleCount[0]};
                    end
                    9'b11101111x: begin
                        indexA_reg = {9'b111011110, cycleCount[0]};
                    end
                    9'b11110000x: begin
                        indexA_reg = {9'b111100000, cycleCount[0]};
                    end
                    9'b11110001x: begin
                        indexA_reg = {9'b111100010, cycleCount[0]};
                    end
                    9'b11110010x: begin
                        indexA_reg = {9'b111100100, cycleCount[0]};
                    end
                    9'b11110011x: begin
                        indexA_reg = {9'b111100110, cycleCount[0]};
                    end
                    9'b11110100x: begin
                        indexA_reg = {9'b111101000, cycleCount[0]};
                    end
                    9'b11110101x: begin
                        indexA_reg = {9'b111101010, cycleCount[0]};
                    end
                    9'b11110110x: begin
                        indexA_reg = {9'b111101100, cycleCount[0]};
                    end
                    9'b11110111x: begin
                        indexA_reg = {9'b111101110, cycleCount[0]};
                    end
                    9'b11111000x: begin
                        indexA_reg = {9'b111110000, cycleCount[0]};
                    end
                    9'b11111001x: begin
                        indexA_reg = {9'b111110010, cycleCount[0]};
                    end
                    9'b11111010x: begin
                        indexA_reg = {9'b111110100, cycleCount[0]};
                    end
                    9'b11111011x: begin
                        indexA_reg = {9'b111110110, cycleCount[0]};
                    end
                    9'b11111100x: begin
                        indexA_reg = {9'b111111000, cycleCount[0]};
                    end
                    9'b11111101x: begin
                        indexA_reg = {9'b111111010, cycleCount[0]};
                    end
                    9'b11111110x: begin
                        indexA_reg = {9'b111111100, cycleCount[0]};
                    end
                    9'b11111111x: begin
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