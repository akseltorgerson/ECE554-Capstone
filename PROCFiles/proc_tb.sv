module proc_tb();

    //Inputs to processor
    logic clk;
    logic rst;
    logic [511:0] common_data_bus_in;
    logic tx_done;
    logic rd_valid;
    //Outputs of the processor
    logic [1:0] op_actual, op_expected;
    logic [511:0] common_data_bus_out_actual, common_data_bus_out_expected;
    logic [31:0] io_addr_actual, io_addr_expected;
    logic [63:0] cv_value_actual, cv_value_expected;

    //Probably want some memory here
    
    proc iProcessor(.clk(clk),
                    .rst(rst),
                    .common_data_bus_in(common_data_bus_in),
                    .tx_done(tx_done),
                    .rd_valid(rd_valid),
                    //Outputs
                    .op(op_actual),
                    .common_data_bus_out(common_data_bus_out_actual),
                    .io_addr(io_addr_actual),
                    .cv_value(cv_value_actual));

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        //Expected outputs
        op_expected = 2'b0;
        common_data_bus_out_expected = 512'b0;
        io_addr_expected = 32'b0;
        cv_value_expected = 64'b0;
        //Input stimulus
        common_data_bus_in = 512'b0;
        tx_done = 1'b0;
        rd_valid = 1'b0;

        //RESET
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        //START TESTING

        //wait some clk cycles
        repeat(10) begin
            @(posedge clk);
        end

        $stop();
    end

    always #5 clk = ~clk;

endmodule