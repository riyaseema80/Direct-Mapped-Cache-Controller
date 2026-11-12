module tag_comparator (
    input wire [21:0] requested_tag,
    input wire [21:0] stored_tag,
    input wire valid_bit,
    output wire hit
);

    assign hit = (requested_tag == stored_tag) && valid_bit;

endmodule
