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
