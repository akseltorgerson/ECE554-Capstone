module mem_arb(

    input clk,
    input rst,
    input dump,

    // Instr Cache Interface
    input instrCacheBlkReq,             // cacheMiss    
    input [31:0] instrAddr,             // instrAddr
    output reg [511:0] instrBlk2Cache,  // blkIn
    output reg instrBlk2CacheValid,     // mcDataValid

    // Data Cache Interface
    input dataCacheBlkReq,              // cacheMiss
    input [31:0] dataAddr,              // aluResult
    input dataCacheEvictReq,            // cacheEvict
    input [511:0] dataBlk2Mem,          // mcDataOut
    output reg dataEvictAck,            // evictDone
    output reg dataBlk2CacheValid,      // mcDataValid
    output reg [511:0] dataBlk2Cache,   // mcDataIn

    // FT Accelerator Buffer Interface
    input accelDataRd,                  // lets MC know we want to read a sig chunk from host
    input accelDataWr,                  // lets the MC know we want to write a sig chunk to host, data is ready
    input [511:0] accelBlk2Mem,         // the block we want to write to mem
    input [17:0] sigNum,                // the signal number that corresponds to the signal data
    output reg accelWrBlkDone,          // lets the a-buf know that a blk as been written to host, ready for next block
    output reg accelRdBlkDone,          // lets the a-buf know that a blk has been sent to a-buf is done, ready for next block
    output reg [511:0] accelBlk2Buffer, // block of data going to the buffer
    output reg transformComplete,

    // Mem Controller interface
    output logic [1:0] op,
    output reg [511:0] common_data_bus_out,
    output reg [31:0] io_addr,
    input [511:0] common_data_bus_in,
    input tx_done,
    input rd_valid,

    output logic[63:0] cv_value
);

    localparam WORD_SIZE = 32;
	localparam CL_SIZE_WIDTH = 512;

    // Definitions
	typedef enum reg[1:0]
	{
        IDLE_OP = 2'b00,
		READ = 2'b01,
		WRITE = 2'b11 
	} opcode;

    opcode op_out;

    assign op = opcode'(op_out);
    assign cv_value[0] = dump;

    // state enum
    typedef enum reg[3:0] {
        INIT = 4'b0000,
        IDLE = 4'b0001,
        INSTR_RD = 4'b0010,
        INSTR_RD_DONE = 4'b0011,
        DATA_RD = 4'b0100,
        DATA_RD_DONE = 4'b0101,
        DATA_WR = 4'b0110,
        DATA_WR_DONE = 4'b0111,
        ACCEL_RD = 4'b1000,
        ACCEL_RD_DONE = 4'b1001,
        ACCEL_WR = 4'b1010,
        ACCEL_WR_DONE = 4'b1011
    } state_t;

    state_t currState, nextState;

    // transform enum
    typedef enum reg[1:0] {
        IDLE_TRANSFORM = 2'b00,
        IN_PROGRESS = 2'b01,
        CHUNK_DONE = 2'b10,
        TRANSFORM_COMPLETE = 2'b11
    } sig_state_t;

    sig_state_t currSigState, nextSigState;

    // Signum Table
    // {18 bits end blkNum, 18 bits start blkNum}
    reg [35:0] signumTable [8192][2];
    logic [31:0] sigBaseAddr;
    logic [31:0] sigEndAddr;
    reg [6:0] sigOffset;
    reg accelTransferDone;
    logic [17:0] sigBaseBlkAddr;
    logic [17:0] sigEndBlkAddr;
    logic en;
    //logic [31:0] sigPtr;

    // Address alignment
    logic dataAddrAligned;
    logic instrAddrAligned;

    // Instr req, Data req, Accel Reqg
    reg priorityReg [2:0];
    logic enable;
    reg instrStart, dataStart, accelStart;


    /************************************************************************   
    *                      SIG COUNTER AND ADDR LOOKUP                      *
    ************************************************************************/
    assign dataAddrAligned = dataAddr & 32'hfffffff0;
    assign instrAddrAligned = instrAddr & 32'hfffffff0;

    assign sigBaseAddr = {3'b0, signumTable[sigNum][0], 11'b0} + 32'h1000_0000;
    assign sigEndAddr = {3'b0, signumTable[sigNum][1], 11'b0} + 32'h1000_0000;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            sigOffset <= 8'b0;
            // TODO These wont be here
            signumTable[0][0] <= 36'b0;
            signumTable[0][1] <= 36'b0; 
        end else begin
            if (en) begin
                sigOffset <= sigOffset + 1'b1;
            end
        end
    end

    assign accelTransferDone = rst ? 1'b0 : &sigOffset;
    assign transformComplete = accelTransferDone;

    /************************************************************************
    *                           PRIORITY ENCODER                            *
    ************************************************************************/
    assign priorityReg[0] = instrCacheBlkReq;
    assign priorityReg[1] = (dataCacheBlkReq | dataCacheEvictReq);
    assign priorityReg[2] = (accelDataRd | accelDataWr);
    assign enable = priorityReg[0] | priorityReg[1] | priorityReg[2];
    assign accelStart = (enable & priorityReg[2]) ? 1'b1 : 1'b0;
    assign dataStart = (enable & priorityReg[1]) ? 1'b1 : 1'b0;
    assign instrStart = (enable & priorityReg[0]) ? 1'b1 : 1'b0;

    /************************************************************************
    *                        REQEST STATE MACHINE                           *
    ************************************************************************/
    always_comb begin
        // Default values
        nextState = IDLE;
        io_addr = 32'b0;
        op_out = IDLE_OP;
        instrBlk2Cache = 512'b0;
        instrBlk2CacheValid = 1'b0;
        dataBlk2Cache = 1'b0;
        dataBlk2CacheValid = 1'b0;
        common_data_bus_out = 512'b0;
        dataEvictAck = 1'b0;
        accelBlk2Buffer = 512'b0;
        accelRdBlkDone = 1'b0;
        accelWrBlkDone = 1'b0;
        en = 1'b0;

        case(currState)
            INIT: begin
                // TODO Need to load the accel sigNums from host mem
                // for now lets just assume its
                nextState = IDLE;
            end
            IDLE: begin
                if (accelStart) begin
                    if (accelDataRd) begin
                        nextState = ACCEL_RD;
                    end else begin
                        nextState = ACCEL_WR;
                    end
                end else if (dataStart) begin
                    if (dataCacheEvictReq) begin
                        nextState = DATA_WR;
                    end else begin
                        nextState = DATA_RD;
                    end
                end else if (instrStart) begin
                    nextState = INSTR_RD;
                end else begin
                    nextState = IDLE;
                end
            end
            /************************************************************************
            *                            INSTR STATES                                *
            ************************************************************************/
            INSTR_RD: begin
                io_addr = instrAddrAligned;
                op_out = READ;
                nextState = tx_done ? INSTR_RD_DONE : INSTR_RD;
            end
            INSTR_RD_DONE: begin    
                instrBlk2Cache = common_data_bus_in;
                instrBlk2CacheValid = rd_valid;
                nextState = rd_valid ? IDLE : INSTR_RD_DONE;
            end
            /************************************************************************
            *                            DATA STATES                                *
            ************************************************************************/
            DATA_RD: begin
                io_addr = dataAddrAligned;
                op_out = READ;
                nextState = tx_done ? DATA_RD_DONE : DATA_RD;
            end
            DATA_RD_DONE: begin 
                dataBlk2Cache = common_data_bus_in;
                dataBlk2CacheValid = rd_valid;
                nextState = rd_valid ? IDLE : DATA_RD_DONE;
            end
            DATA_WR: begin
                io_addr = dataAddrAligned;
                op_out = WRITE;
                common_data_bus_out = dataBlk2Mem;
                nextState = tx_done ? DATA_WR_DONE : DATA_WR; 
            end
            DATA_WR_DONE: begin
                dataEvictAck = 1'b1;
                nextState = IDLE;
            end
            /************************************************************************
            *                               ACCEL STATES                            *
            ************************************************************************/
            // FILLING BUFFER FROM HOST
            ACCEL_RD: begin
                io_addr = sigBaseAddr + (sigOffset << 11);
                op_out = READ;
                accelRdBlkDone = 1'b0;
                nextState = tx_done ? ACCEL_RD_DONE : ACCEL_RD;
            end
            ACCEL_RD_DONE: begin
                accelBlk2Buffer = common_data_bus_in;
                accelRdBlkDone = 1'b1;
                en = 1'b1;
                nextState = rd_valid ? (accelTransferDone ? IDLE : ACCEL_RD) : ACCEL_RD_DONE;
            end
            // EMPTYING BUFFER TO HOST
            ACCEL_WR: begin
                io_addr = sigBaseAddr + (sigOffset << 11);
                op_out = WRITE;
                common_data_bus_out = accelBlk2Mem;
                accelWrBlkDone = 1'b0;
                nextState = tx_done ? ACCEL_WR_DONE : ACCEL_WR;
            end
            ACCEL_WR_DONE: begin
                accelWrBlkDone = 1'b1;
                en = 1'b1;
                nextState = accelTransferDone ? IDLE : ACCEL_WR;
            end
            default: begin
                
            end
        endcase

    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            currState <= INIT;
        end else begin
            currState <= nextState;
        end
    end

    // TODO DO NOT THINK THIS IS RIGHT AT ALL
    /************************************************************************
    *                      TRANSFORM STATE MACHINE                          *
    ************************************************************************/
    /*
    always_comb begin
        // zero stuff
        nextState = IDLE_TRANSFORM;
        sigPtr = 32'b0;
        transformComplete = 1'b1;

        case(currSigState)
            IDLE_TRANSFORM: begin
                sigPtr = sigBaseAddr;
                transformComplete = 1'b1;
                // Move to in progress once we get our first accelDataRd request.
                nextState = accelDataRd ? IN_PROGRESS : IDLE_TRANSFORM;
            end
            IN_PROGRESS: begin
                transformComplete = 1'b0;
                // Move to chunk done state when we get a write request from the accelerator
                sigPtr = (accelDataWr) ? sigPtr + 32'h00000800 : sigPtr;
                nextState = accelDataWr ? CHUNK_DONE : IN_PROGRESS;
            end
            CHUNK_DONE: begin
                transformComplete = 1'b0;
                nextState = (sigPtr < sigEndAddr) ? TRANSFORM_COMPLETE : IN_PROGRESS;
            end
            TRANSFORM_COMPLETE: begin
                transformComplete = 1'b1;
                nextState = IDLE_TRANSFORM;
            end
            default: begin

            end
        endcase
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            currState <= IDLE;
        end else begin
            currState <= nextState;
        end
    end
    */

endmodule