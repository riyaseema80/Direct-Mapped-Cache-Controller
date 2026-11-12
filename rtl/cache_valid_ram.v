
module cache_valid_ram (
    input wire clk,
    input wire [5:0] index,
    input wire write_valid,
    input wire write_enable,
    output reg read_valid
);

    reg valid_mem [0:63];

    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            valid_mem[i] = 1'b0;
        end
    end

    always @(posedge clk) begin
        if (write_enable) begin
            valid_mem[index] <= write_valid;
        end

        read_valid <= valid_mem[index];
    end

endmodule
