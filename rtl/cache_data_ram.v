module cache_data_ram (
    input wire clk,
    input wire [5:0] index,
    input wire [127:0] write_data,
    input wire write_enable,
    output reg [127:0] read_data
);

    reg [127:0] data_mem [0:63];

    always @(posedge clk) begin
        if (write_enable) begin
            data_mem[index] <= write_data;
            read_data <= write_data;
        end
        else begin
            read_data <= data_mem[index];
        end
    end

endmodule
