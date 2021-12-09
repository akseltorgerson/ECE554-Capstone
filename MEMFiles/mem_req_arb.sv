module mem_req_arb(

    localparam WORD_SIZE = 32;
	localparam CL_SIZE_WIDTH = 512;
	localparam ADDR_BITCOUNT = 64;

    input clk;
    input rst;

    // Instr Cache Interface
    input instrCacheBlkReq;             // cacheMiss    
    input instrCacheAddr;               // instrAddr
    output [511:0] instrBlock2Cache;    // blkIn
    output instrBlk2CacheValid;         // mcDataValid

    // Data Cache Interface
    input dataCacheBlkReq;              // cacheMiss
    input dataCacheAddr;                // aluResult
    input dataCacheEvictReq;            // cacheEvict
    input [511:0] dataBlock2Mem;        // mcDataOut
    output dataEvictAck;                // evictDone
    output dataBlk2MemValid;            // mcDataValid
    output [511:0] dataBlock2Cache;     // mcDataIn

    // FT Accelerator Buffer Interface
    input accelDataRd;                  // lets MC know we want to read a sig chunk from host
    input accelDataWr;                  // lets the MC know we want to write a sig chunk to host
    input [511:0] ftBlock2Mem;          // the block we want to write to mem
    input [17:0] sigNum;                // the signal number that corresponds to the signal data
    output ftDataValid;                 // lets the A buffer know the data is valid
    output [511:0] ftBlk2Buffer;        // block of data going to the buffer

    // Mem Controller interface
    output [1:0] op;
    output [WORD_SIZE-1:0] common_data_bus_write_out;
    input [WORD_SIZE-1:0] common_data_bus_read_in;
    input ready;
    input tx_done;
    input rd_valid;

);

    // state enum
    typedef enum reg[2:0] {
        INIT = 3'b000;
        IDLE = 3'b001;
        INSTR_RD = 3'b010;
        DATA_RD = 3'b011;
        DATA_WR = 3'b100;
        ACCEL_RD = 3'b101;
        ACCEL_WR = 3'b110;
        UNUSED = 3'b111;
    } state_t;

    state_t currState, nextState;

    // Signum Table
    // {18 bits end offset, 18 bits start offset}
    reg [35:0] signumTable [8192];    

    // Instr req, Data req, Accel Reqg
    reg [2:0] priorityReg;
    logic enable;
    logic instrStart, dataStart, accelStart;

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
                // Need to load the accel sigNums from host mem
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

            end
            DATA_RD: begin

            end
            DATA_WR: begin

            end
            ACCEL_RD: begin

            end
            ACCEL_WR: begin

            end
            default: begin
            end
        end

    end

    always_ff @(posedge clk)

endmodule