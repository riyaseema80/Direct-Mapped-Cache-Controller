// Tag Comparator:
 // Compares the requested tag with the stored cache tag.
 // A cache hit occurs only when both tags match and valid_bit is 1.
 //
 // Inputs:
 // requested_tag [21:0] - Tag requested by the CPU.
 // stored_tag    [21:0] - Tag currently stored in the cache.
 // valid_bit            - Indicates whether the cache line contains valid data.
 //
 // Output:
 // hit                  - 1 when tags match and valid_bit is 1; otherwise 0.

module tag_comparator (
    input wire [21:0] requested_tag,
    input wire [21:0] stored_tag,
    input wire valid_bit,
    output wire hit
);

    assign hit = (requested_tag == stored_tag) && valid_bit;

endmodule
