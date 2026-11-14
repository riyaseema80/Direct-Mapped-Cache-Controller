// Cache Tag RAM:
 // Stores the 22-bit tag for each of the 64 cache lines.
 // Read and write operations are performed on the rising edge of the clock.
 //
 // Inputs:
 // clk          - Clock signal.
 // index [5:0]  - Selects one of the 64 cache lines.
 // write_tag [21:0] - Tag value to be stored.
 // write_enable - Enables writing into the selected tag entry.
 //
 // Output:
 // read_tag [21:0] - Tag read from the selected cache line.
 
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
