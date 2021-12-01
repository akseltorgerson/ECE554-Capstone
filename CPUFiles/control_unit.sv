
module control_unit(
    //Inputs
    opcode, fftCalculating,
    //Outputs
    blockInstruction, isJAL, regDst, rsWrite, regWrite, aluSrc, isSignExtend, isIType1, isBranch, nop, halt, memWrite, memRead, memToReg, isJR, isSLBI, aluOp, isJump, startI, startF, loadF
);

    //Determines the isntructions
    input [4:0] opcode;
    //A control flag to let know that the fft is currently calculating on data
    input fftCalculating;

    // Halt is not actually an output of the Control Unit
    // It will be set in the fetch stage module

    //Control Signals
    output reg isJAL;
    output reg regDst;
    output reg rsWrite; 
    output reg regWrite; 
    output reg aluSrc; 
    output reg isSignExtend; 
    output reg isIType1; 
    output reg isBranch;
    output reg halt;
    output reg nop;
    output reg memWrite; 
    output reg memRead; 
    output reg memToReg; 
    output reg isJR; 
    output reg isSLBI;
    output reg [3:0] aluOp;
    output reg isJump;
    //TODO: Check on this from 552, could be changed 
    //output reg [1:0] branchOp;
    //pcSrc not needed in single cycle implementation
    //output reg pcSrc;
    output reg startI; 
    output reg startF;
    output reg loadF;
    output reg blockInstruction;

    always @(*) begin
        isJAL = 1'b0;
        regDst = 1'b0;
        rsWrite = 1'b0;
        regWrite = 1'b0;
        aluSrc = 1'b0;
        isSignExtend = 1'b0;
        isIType1 = 1'b0;
        isBranch = 1'b0;
        halt = 1'b0;
        nop = 1'b0;
        memWrite = 1'b0;
        memRead = 1'b0;
        memToReg = 1'b0;
        isJR = 1'b0;
        isSLBI = 1'b0;
        aluOp = 4'b0000;
        isJump = 1'b0;
        //branchOp = 2'b00;
        //pcSrc = 1'b0;
        // Possibly want to just make these an output of the fetch stage
        // This way the instruction can go to the accelerator as fast as possible
        startI = 1'b0;
        startF = 1'b0;
        loadF = 1'b0;
        blockInstruction = 1'b0;
        case(opcode)
            //Halt
            5'b00000: begin
                halt = 1'b1;
            end
////////////////////////Special Instructions////////////////////////////////////
            //nop
            5'b00001: begin
                nop = 1'b1;
            end
            //STARTF
            5'b00010: begin
                //TODO: Might have to not set the startF or StartI instruction if it is calculating
                startF = 1'b1;
                //TODO: can this be done?
                blockInstruction = fftCalculating ? 1'b1 : 1'b0;
            end
            //STARTI
            5'b00011: begin
                startI = 1'b1;
                blockInstruction = fftCalculating ? 1'b1 : 1'b0;
            end
            //LOADF
            5'b11111: begin
                loadF = 1'b1;
            end
////////////////////////I Form Type 1////////////////////////////////////
            //ADDI
            5'b01000: begin
                //Add operation
                aluOp = 4'b0000;
                regWrite = 1'b1;
                isIType1 = 1'b1;
                isSignExtend = 1'b1;
                //aluSrc == 0 since immediate
            end
            //SUBI
			5'b01001: begin
                //subtract operation
				aluOp = 4'b0001;
				isSignExtend = 1'b1;
				regWrite = 1'b1;
				isIType1 = 1'b1;
				//aluSrc == 0 since immediate
			end
            //XORI
			5'b01010: begin
                //Xor operation
                aluOp = 4'b0010;
				regWrite = 1'b1;
				isIType1 = 1'b1;
				//aluSrc == 0 since immediate
			end
            //ANDNI
			5'b01011: begin
                // And operation
                aluOp = 4'b0011;
				regWrite = 1'b1;
				isIType1 = 1'b1;
				//aluSrc ==- 0 since immediate
			end
            //ST
			5'b10000: begin
				isSignExtend = 1'b1;
                //Add operation
				aluOp = 4'b0000;
				memWrite = 1'b1;
				isIType1 = 1'b1;
			end
            //LD
			5'b10001: begin
                //Add operation
				aluOp = 4'b0000;
				memRead = 1'b1;
				memToReg = 1'b1;
				isSignExtend = 1'b1;
				isIType1 = 1'b1;
				regWrite = 1'b1;
			end
            //STU
			5'b10011: begin
				isSignExtend = 1'b1;
				isIType1 = 1'b1;
				memWrite = 1'b1;
				rsWrite = 1'b1;
                //Add operation
				aluOp = 4'b0000;
				regWrite = 1'b1;
			end
//////////////////////R Format Instructions////////////////////////////////////
            //ADD
            5'b11000: begin
                regDst = 1'b1;
                aluSrc = 1'b1;
                regWrite = 1'b1;
                //Add operation
                aluOp = 4'b0000;
            end
            //SUB
            5'b11001: begin
                regDst = 1'b1;
                aluSrc = 1'b1;
                regWrite = 1'b1;
                //Subtract operation
                aluOp = 4'b0001;
            end
            //XOR
            5'b11010: begin
                regDst = 1'b1;
                aluSrc = 1'b1;
                regWrite = 1'b1;
                //Xor operation
                aluOp = 4'b0010;
            end
            //ANDN
            5'b11011: begin
                regDst = 1'b1;
                aluSrc = 1'b1;
                regWrite = 1'b1;
                //And operation
                aluOp = 4'b0011;
            end
            //SEQ
			5'b11100: begin
				regDst = 1'b1;
				aluSrc = 1'b1;
				aluOp = 4'b1000;
				regWrite = 1'b1;
			end
            //SLT
			5'b11101: begin
				regDst = 1'b1;
				aluSrc = 1'b1;
				aluOp = 4'b1001;
				regWrite = 1'b1;
			end
            //SLE
			5'b11110: begin
				regDst = 1'b1;
				aluSrc = 1'b1;
				aluOp = 4'b1010;
				regWrite = 1'b1;
			end
////////////////////////I Format Type 2/////////////////////////////////////////////
            //BEQZ
			5'b01100: begin 
				isBranch = 1'b1;
				//branchOp = 2'b00;
                //Branch Operation
				aluOp = 4'b0100;
				//pcSrc = 1'b1;
			end
            //BNEZ
			5'b01101: begin
				isBranch = 1'b1;
				//branchOp = 2'b01;
				aluOp = 4'b0101;
				//pcSrc = 1'b1;
			end
            //BLTZ
			5'b01110: begin
				isBranch = 1'b1;
				//branchOp = 2'b10;
				aluOp = 4'b0110;
				//pcSrc = 1'b1;
			end
            //BGEZ
			5'b01111: begin
				isBranch = 1'b1;
				//branchOp = 2'b11;
				aluOp = 4'b0111;
				//pcSrc = 1'b1;
			end
            //LBI
			5'b10100: begin
				aluOp = 4'b1011;
				rsWrite = 1'b1;
				regWrite = 1'b1;
			end
            //SLBI
			5'b10010: begin
				aluOp = 4'b1100;
				rsWrite = 1'b1;
				isSLBI = 1'b1;
				regWrite = 1'b1;
			end
            //JR
			5'b00101: begin
				isJR = 1'b1;
				//pcSrc = 1'b1;
			end
			//JALR
			5'b00111: begin
				isJAL = 1'b1;
				isJR = 1'b1;
				regWrite = 1'b1;
				//pcSrc = 1'b1;
			end
/////////////////////// J Format Instructions//////////////////////////////////////
            //J
			5'b00100: begin
				isJump = 1'b1;
				//pcSrc = 1'b1;
			end
			//JAL
			5'b00110: begin
				isJAL = 1'b1;
				isJump = 1'b1;
				regWrite = 1'b1;
				//pcSrc = 1'b1;
			end
/////////////////////// Extra Credit Instructions//////////////////////////////////
// TODO: Maybe want these from 552 for exceptions, not sure if do it this way    //
            5'b00010: begin
				//Set the SIIC illegal instruction exception
			end
			5'b00011: begin
				//RTI returns from an exception by loading the PC for the value in the EPC register
			end
			default: begin
				
			end
        endcase
    end

endmodule