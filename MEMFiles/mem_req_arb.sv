module mem_req_arb(

    localparam WORD_SIZE = 32;
	localparam CL_SIZE_WIDTH = 512;
	localparam ADDR_BITCOUNT = 64;

    input clk;
    input rst;

    // Instr Cache Interface
    input instrCacheBlkReq;             // cacheMiss    
    input [31:0] instrCacheAddr;               // instrAddr
    output [511:0] instrBlk2Cache;    // blkIn
    output instrBlk2CacheValid;         // mcDataValid

    // Data Cache Interface
    input dataCacheBlkReq;              // cacheMiss
    input [31:0] dataAddr;              // aluResult
    input dataCacheEvictReq;            // cacheEvict
    input [511:0] dataBlk2Mem;        // mcDataOut
    output dataEvictAck;                // evictDone
    output dataBlk2CacheValid;          // mcDataValid
    output [511:0] dataBlk2Cache;     // mcDataIn

    // FT Accelerator Buffer Interface
    input accelDataRd;                  // lets MC know we want to read a sig chunk from host
    input accelDataWr;                  // lets the MC know we want to write a sig chunk to host, data is ready
    input [511:0] accelBlk2Mem;         // the block we want to write to mem
    input [17:0] sigNum;                // the signal number that corresponds to the signal data
    output accelWrBlkDone;              // lets the a-buf know that a blk as been written to host, ready for next block
    output accelRdBlkDone;               // lets the a-buf know that a blk has been sent to a-buf is done, ready for next block
    output [511:0] accelBlk2Buffer;     // block of data going to the buffer

    // Definitions
	typedef enum bit
	{
		READ = 2'b01,
		WRITE = 2'b11 
	} opcode;

    // Mem Controller interface
    output op;
    output [WORD_SIZE-1:0] common_data_bus_out;
    output [31:0] io_addr;
    input [WORD_SIZE-1:0] common_data_bus_in;
    input tx_done;
    input rd_valid;
    // TODO might need CV value
    output logic[63:0] cv_value;

);

    // state enum
    typedef enum reg[3:0] {
        INIT = 4'b0000;
        IDLE = 4'b0001;
        INSTR_RD = 4'b0010;
        INSTR_RD_DONE = 4'b0011;
        DATA_RD = 4'b0100;
        DATA_RD_DONE = 4'b0101;
        DATA_WR = 4'b0110;
        DATA_WR_DONE = 4'b0111;
        ACCEL_RD = 4'b1000;
        ACCEL_RD_DONE = 4'b1001;
        ACCEL_WR = 4'b1010;
        ACCEL_WR_DONE = 4'b1011;
    } state_t;

    state_t currState, nextState;

    // Signum Table
    // {18 bits end offset, 18 bits start offset}
    reg [35:0] signumTable [8192];
    logic sigBaseAddr;
    logic [7:0] sigOffset;
    reg accelTransferDone;

    // Instr req, Data req, Accel Reqg
    reg [2:0] priorityReg;
    logic enable;
    logic instrStart, dataStart, accelStart;

    // TODO may need to be one more bit
    // counter for signals
    always_ff @(posedge accelWrBlkDone, posedge accelRdBlkDone, posedge rst) begin
        if (rst) begin
            sigOffset <= 8'b0;
            accelTransferDone <= '0;
        end else begin
            sigOffset <= sigOffset + 1;
            accelTrasnferDone <= '0;
        end
        if (&sigOffset) begin
            transferDone = 1'b1;
            // rest it back to 0
            sigOffset <= sigOffset + 1;
        end
    end

    // instr, data, accel
    assign priorityReg = {instrCacheBlkReq, (dataCacheBlkReq | dataCacheEvictReq), (accelDataRd | accelDataWr)};
    assign enable = |priorityReg;

    // Priority Enc
    always_comb begin
        if (enable) begin
            if (priorityReg[2] == 1) begin
                // request accelerator data
                accelStart = 1'b1;
            end else if (priorityReg[1] == 1) begin
                // request a data block
                dataStart = 1'b1;
            end else if (priorityReg[0] == 1) begin
                // request an instruction block
                instrStart = 1'b1;
            end else begin
                // do nothing
            end
        end
    end

    // State machine
    always_comb begin
        // Default values

        case(state) begin
            INIT: begin
                // TODO Need to load the accel sigNums from host mem
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
                    if (dataCacheBlkReq) begin
                        nextState = DATA_RD;
                    end else begin
                        nextState = DATA_WR;
                    end
                end else if (instrStart) begin
                    nextState = INSTR_RD;
                end
            end
            INSTR_RD: begin
                io_addr = instrAddr;
                op = READ;
                nextState = rd_valid ? INSTR_RD_DONE : INSTR_RD;
            end
            INSTR_RD_DONE: begin    
                instrBlock2Cache = common_data_bus_in;
                instrBlk2CacheValid = 1'b1;
                nextState = IDLE;
            end
            DATA_RD: begin
                io_addr = dataCacheAddr;
                op = READ;
                nextState = rd_valid ? DATA_RD_DONE : INSTR_RD;
            end
            DATA_RD_DONE: begin 
                dataBlock2Cache = common_data_bus_in;
                dataBlock2CacheValid = 1'b1;
                nextState = IDLE;
            end
            DATA_WR: begin
                io_addr = dataCacheAddr;
                op = WRITE;
                common_data_bus_out = dataBlock2Mem;
                nextState = tx_done ? DATA_WR_DONE : DATA_WR; 
            end
            DATA_WR_DONE: begin
                dataEvictAck = 1'b1;
                nextState = IDLE:
            end
            ACCEL_RD: begin
                io_addr = sigBaseAddr + sigOffset;
                op = READ;
                accelBlk2Buffer = common_data_bus_in;
                accelRdBlkDone = 1'b0;
                nextState = rd_valid ? ACCEL_RD_DONE : ACCEL_RD;
            end
            ACCEL_RD_DONE: begin
                accelRdBlkDone = 1'b1;
                nextState = accelTransferDone ? IDLE : ACCEL_RD;
            end
            ACCEL_WR: begin
                io_addr = sigBaseAddr + sigOffset;
                op = WRITE;
                common_data_bus_out = accelBlk2Mem;
                accelWrBlockDone = 1'b0;
                nextState = tx_done ? ACCEL_WR_DONE : ACCEL_WR;
            end
            ACCEL_WR_DONE: begin
                accelWrBlkDone = 1'b1;
                nextState = accelTransferDone ? IDLE : ACCEL_WR;
            end
            default: begin
            end
        end

    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            currState <= INIT;
        end else begin
            currState <= nextState;
        end

endmodule