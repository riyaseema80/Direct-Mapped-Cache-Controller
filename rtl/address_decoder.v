// Address Decoder:
 // Splits a 32-bit CPU address into Tag (22 bits),
 // Index (6 bits), and Offset (4 bits).
 //
 // Inputs:
 // address [31:0] - 32-bit CPU memory address.
 //
 // Outputs:
 // tag    [21:0] - Identifies the memory block.
 // index  [5:0]  - Selects one of the 64 cache lines.
 // offset [3:0]  - Identifies the byte position within a 16-byte block.

module address_decoder (
    input wire [31:0] address,
    output wire [21:0] tag,
    output wire [5:0] index,
    output wire [3:0] offset
);

    assign tag    = address[31:10];
    assign index  = address[9:4];
    assign offset = address[3:0];

endmodule
