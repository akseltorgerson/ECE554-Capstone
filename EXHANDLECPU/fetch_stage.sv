module fetch_stage(
    //Inputs
    clk, rst, halt, nextPC, stallDMAMem, mcDataValid, blockInstruction, mcDataIn, exception,
    //Outputs
    instr, pcPlus1, cacheMiss, instrAddr
);

    input clk, rst, halt;

    //If there is an exception, halt the processor
    //NOTE: Will want to change this to run through the exception handler
    input exception;

    //Control signal from memory stage that stalls the PC if there is an ongoing DMA request
    input stallDMAMem;

    //Control signal from the decode stage that stalls the PC if there is an issue with the instruction order
    input blockInstruction;

    //Control signal from the memory controller to let the instruction cache know the data is valid for the cache
    input mcDataValid;

    //Data from the memory controller via a DMA request to fill the instruction cache
    input [511:0] mcDataIn;

    //The next address that the PC should point to
    input [31:0] nextPC;

    //The instruction to decode
    output [31:0] instr;

    // The current PC plus 1 (to get the next instruction if there is no branch or jump)
    output [31:0] pcPlus1;

    //Lets the mc know there was a miss in the instruction cache and to start a DMA request
    output cacheMiss;

    // current address for the MC to use
    output [31:0] instrAddr;

    wire [31:0] currPC;
    wire stallPC;

    // cache signals
    logic cacheHit;

    //These signals are not important (but can be used later if need be)
    wire cout, P, G;

    // NOTE: Might need to add in another state after request to wait a clk cycle that unconditionally goes to IDLE
    typedef enum reg {IDLE = 1'b0, REQUEST = 1'b1} state;
    state currState;
    state nextState;

    //Control logic for if the PC needs to be stalled
    assign stallPC = stallDMAMem | blockInstruction | cacheMiss | exception;

    assign instrAddr = currPC;

    //The halt signal will be ~ inside PC so when it is 0, it writes on the next clk cycle
    program_counter iPC(.clk(clk), .rst(rst), .halt(halt), .nextAddr(nextPC), .currAddr(currPC), .stallPC(stallPC));
    
    //Add four to the current PC (if there is no branch, this will be where the next instruction is)
    cla_32bit iPCAdder(.A(currPC), .B(32'h1), .Cin(1'b0), .Sum(pcPlus1), .Cout(cout), .P(P), .G(G));

    //The instruction memeory
    instr_cache iInstrCache(.clk(clk), 
                            .rst(rst), 
                            .addr(currPC), 
                            .blkIn(mcDataIn), 
                            .ld(mcDataValid), 
                            .instrOut(instr), 
                            .hit(cacheHit), 
                            .miss(cacheMiss));


    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            currState <= IDLE;
        end else begin
            currState <= nextState;
        end
    end

    always_comb begin
        // Must assign all signals
        nextState = IDLE;
        case(currState)
            IDLE: begin
                nextState = (cacheMiss) ? REQUEST : IDLE; 
            end
            REQUEST: begin
                nextState = (mcDataValid) ? IDLE : REQUEST;
            end
        endcase
    end

endmodule