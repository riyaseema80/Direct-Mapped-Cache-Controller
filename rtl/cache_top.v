
module cache_top (
    input wire clk,
    input wire reset,

    input wire cpu_req,
    input wire cpu_write,
    input wire [31:0] cpu_address,
    input wire [127:0] cpu_write_data,

    output wire [127:0] cpu_read_data,
    output wire cpu_ready,
    output wire cache_miss
);

    // Address decoder signals
    wire [21:0] tag;
    wire [5:0] index;
    wire [3:0] offset;

    // Cache RAM signals
    wire [127:0] cache_data_out;
    wire [21:0] stored_tag;
    wire valid_bit;

    wire cache_hit;

    // Controller signals
    wire cache_data_we;
    wire cache_tag_we;
    wire cache_valid_we;
    wire mem_read_en;
    wire mem_write_en;

    // Main memory signals
    wire [127:0] mem_read_data;
    wire mem_ready;

    // Data written into cache
    wire [127:0] cache_write_data;
    wire [21:0] cache_write_tag;

    // Decode CPU address
    address_decoder decoder (
        .address(cpu_address),
        .tag(tag),
        .index(index),
        .offset(offset)
    );

    // Cache data RAM
    cache_data_ram data_ram (
        .clk(clk),
        .index(index),
        .write_data(cache_write_data),
        .write_enable(cache_data_we),
        .read_data(cache_data_out)
    );

    // Cache tag RAM
    cache_tag_ram tag_ram (
        .clk(clk),
        .index(index),
        .write_tag(cache_write_tag),
        .write_enable(cache_tag_we),
        .read_tag(stored_tag)
    );

    // Cache valid-bit RAM
    cache_valid_ram valid_ram (
        .clk(clk),
        .index(index),
        .write_valid(1'b1),
        .write_enable(cache_valid_we),
        .read_valid(valid_bit)
    );

    // Tag comparison
    tag_comparator comparator (
        .requested_tag(tag),
        .stored_tag(stored_tag),
        .valid_bit(valid_bit),
        .hit(cache_hit)
    );

    // Cache controller
    cache_controller controller (
        .clk(clk),
        .reset(reset),
        .cpu_req(cpu_req),
        .cpu_write(cpu_write),
        .cache_hit(cache_hit),
        .mem_ready(mem_ready),
        .cache_data_we(cache_data_we),
        .cache_tag_we(cache_tag_we),
        .cache_valid_we(cache_valid_we),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .cpu_ready(cpu_ready),
        .cache_miss(cache_miss)
    );

    // Select data for cache refill or CPU write
    assign cache_write_data =
       cache_tag_we ? mem_read_data : cpu_write_data;

    assign cache_write_tag = tag;

    // Main memory
    main_memory memory (
        .clk(clk),
        .block_address(cpu_address[31:4]),
        .read_enable(mem_read_en),
        .write_enable(mem_write_en),
        .write_data(cpu_write_data),
        .read_data(mem_read_data),
        .mem_ready(mem_ready)
    );

        // CPU receives memory data during refill,
        // otherwise receives data from cache
        assign cpu_read_data = cache_data_out;

endmodule
