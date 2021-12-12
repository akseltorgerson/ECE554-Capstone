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
        
    end

    always #5 clk = ~clk;

endmodule