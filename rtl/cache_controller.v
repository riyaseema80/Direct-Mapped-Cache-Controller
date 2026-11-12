
module cache_controller (
    input wire clk,
    input wire reset,
    input wire cpu_req,
    input wire cpu_write,
    input wire cache_hit,
    input wire mem_ready,

    output reg cache_data_we,
    output reg cache_tag_we,
    output reg cache_valid_we,
    output reg mem_read_en,
    output reg mem_write_en,
    output reg cpu_ready,
    output reg cache_miss
);

    parameter IDLE       = 4'd0,
              LOOKUP     = 4'd1,
              CHECK      = 4'd2,
              HIT        = 4'd3,
              MISS       = 4'd4,
              WAIT_MEM   = 4'd5,
              REFILL     = 4'd6,
              RELOAD     = 4'd7,
              COMPLETE   = 4'd8,
              WRITE_WAIT = 4'd9,
              WRITE_DONE = 4'd10,
              HIT_DONE   = 4'd11;

    reg [3:0] state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;

        case (state)

            IDLE:
                if (cpu_req)
                    next_state = LOOKUP;

            LOOKUP:
                next_state = CHECK;

            CHECK: begin
                if (cache_hit)
                    next_state = HIT;
                else if (cpu_write)
                    next_state = WRITE_WAIT;
                else
                    next_state = MISS;
            end

            HIT:
                next_state = HIT_DONE;

            HIT_DONE:
                next_state = IDLE;

            MISS:
                next_state = WAIT_MEM;

            WAIT_MEM:
                if (mem_ready)
                    next_state = REFILL;

            REFILL:
                next_state = RELOAD;

            RELOAD:
                next_state = COMPLETE;

            COMPLETE:
                next_state = IDLE;

            WRITE_WAIT:
                next_state = WRITE_DONE;

            WRITE_DONE:
                next_state = IDLE;

            default:
                next_state = IDLE;

        endcase
    end

    always @(*) begin
        cache_data_we  = 0;
        cache_tag_we   = 0;
        cache_valid_we = 0;
        mem_read_en    = 0;
        mem_write_en   = 0;
        cpu_ready      = 0;
        cache_miss     = 0;

        case (state)

            HIT: begin
                if (cpu_write) begin
                    cache_data_we = 1;
                    mem_write_en = 1;
                end
            end

            HIT_DONE: begin
                cpu_ready = 1;
            end

            MISS: begin
                cache_miss = 1;
                mem_read_en = 1;
            end

            WAIT_MEM: begin
                cache_miss = 1;
            end

            REFILL: begin
                cache_data_we = 1;
                cache_tag_we = 1;
                cache_valid_we = 1;
            end

            COMPLETE: begin
                cpu_ready = 1;
            end

            WRITE_WAIT: begin
                mem_write_en = 1;
                cache_miss = 1;
            end

            WRITE_DONE: begin
                cpu_ready = 1;
            end

            default: begin
            end

        endcase
    end

endmodule



