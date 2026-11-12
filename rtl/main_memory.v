
module main_memory (
    input wire clk,
    input wire [27:0] block_address,
    input wire read_enable,
    input wire write_enable,
    input wire [127:0] write_data,
    output reg [127:0] read_data,
    output reg mem_ready
);

    reg [127:0] memory [0:255];
    integer i;

    // Initialize main memory
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 128'h0;
        end
        mem_ready = 0;
        read_data = 128'h0;
    end

    // Read and write operations
    always @(posedge clk) begin
        mem_ready <= 0;

        if (write_enable) begin
            memory[block_address[7:0]] <= write_data;
            mem_ready <= 1;
        end

        if (read_enable) begin
            read_data <= memory[block_address[7:0]];
            mem_ready <= 1;
        end
    end

endmodule

