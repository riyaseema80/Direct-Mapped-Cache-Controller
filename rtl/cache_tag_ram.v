
module cache_tag_ram (
    input wire clk,
    input wire [5:0] index,
    input wire [21:0] write_tag,
    input wire write_enable,
    output reg [21:0] read_tag
);

    reg [21:0] tag_mem [0:63];

    always @(posedge clk) begin
        if (write_enable) begin
            tag_mem[index] <= write_tag;
        end

        read_tag <= tag_mem[index];
    end

endmodule
