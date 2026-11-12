`timescale 1ns/1ps

module cache_tb;

    reg clk;
    reg reset;
    reg cpu_req;
    reg cpu_write;
    reg [31:0] cpu_address;
    reg [127:0] cpu_write_data;

    wire [127:0] cpu_read_data;
    wire cpu_ready;
    wire cache_miss;

    integer miss_count;
    integer hit_count;
    integer read_hit_count;
    integer read_miss_count;
    integer last_latency;
    integer hit_latency;
    integer miss_latency;
    integer pass_count;
    integer fail_count;
    integer i;
    integer h0;
    integer m0;

    real miss_rate;
    real amat;

    reg        rand_write;
    reg [31:0] rand_addr;

    // Reference model of the direct-mapped cache (64 blocks)
    reg        model_valid [0:63];
    reg [21:0] model_tag   [0:63];

    // DUT: Direct-Mapped Cache
    cache_top uut (
        .clk(clk),
        .reset(reset),
        .cpu_req(cpu_req),
        .cpu_write(cpu_write),
        .cpu_address(cpu_address),
        .cpu_write_data(cpu_write_data),
        .cpu_read_data(cpu_read_data),
        .cpu_ready(cpu_ready),
        .cache_miss(cache_miss)
    );

    // Clock generation
    always #5 clk = ~clk;


    // Task to send CPU request (also checks hit/miss against reference model)
    task send_request;
        input write_operation;
        input [31:0] address;
        input [127:0] write_data;

        integer cycles;
        reg completed;
        reg saw_miss;
        reg exp_hit;
        reg [5:0] idx;
        reg [21:0] tg;

        begin
            idx = address[9:4];
            tg  = address[31:10];
            exp_hit = model_valid[idx] && (model_tag[idx] == tg);

            @(negedge clk);

            cpu_req = 1;
            cpu_write = write_operation;
            cpu_address = address;
            cpu_write_data = write_data;

            completed = 0;
            saw_miss = 0;

            for (cycles = 0; cycles < 30 && !completed; cycles = cycles + 1) begin
                @(posedge clk);
                #1;

                if (cache_miss)
                    saw_miss = 1;

                if (cpu_ready)
                    completed = 1;
            end

            last_latency = cycles;

            @(negedge clk);
            cpu_req = 0;
            cpu_write = 0;

            if (completed) begin
                if (saw_miss) begin
                    miss_count = miss_count + 1;
                    $display("CACHE MISS: Address = %h, Latency = %0d cycles", address, last_latency);
                end
                else begin
                    hit_count = hit_count + 1;
                    $display("CACHE HIT: Address = %h, Latency = %0d cycles", address, last_latency);
                end

                $display("CPU Read Data = %h", cpu_read_data);

                // Read-only statistics for AMAT
                if (!write_operation) begin
                    if (saw_miss) begin
                        read_miss_count = read_miss_count + 1;
                        miss_latency = last_latency;
                    end
                    else begin
                        read_hit_count = read_hit_count + 1;
                        hit_latency = last_latency;
                    end
                end

                // Compare DUT behaviour with reference model
                if (saw_miss == exp_hit) begin
                    fail_count = fail_count + 1;
                    $display("FAIL: hit/miss differs from reference model at address %h", address);
                end
                else begin
                    pass_count = pass_count + 1;
                end

                // Update reference model (write-through, no-write-allocate)
                if (!write_operation && !exp_hit) begin
                    model_valid[idx] = 1'b1;
                    model_tag[idx]   = tg;
                end
            end
            else begin
                fail_count = fail_count + 1;
                $display("ERROR: Request timed out at address %h", address);
            end

            repeat (2) @(negedge clk);
        end
    endtask

    // Main test sequence
    initial begin

        $dumpfile("cache_wave.vcd");
        $dumpvars(0, cache_tb);

        clk = 0;
        reset = 1;
        cpu_req = 0;
        cpu_write = 0;
        cpu_address = 0;
        cpu_write_data = 0;

        miss_count = 0;
        hit_count = 0;
        read_hit_count = 0;
        read_miss_count = 0;
        last_latency = 0;
        hit_latency = 0;
        miss_latency = 0;
        pass_count = 0;
        fail_count = 0;

        for (i = 0; i < 64; i = i + 1) begin
            model_valid[i] = 1'b0;
            model_tag[i]   = 22'd0;
        end

        $display("--------------------------------");
        $display("DIRECT MAPPED CACHE TEST START");
        $display("--------------------------------");

        // Reset
        repeat (2) @(negedge clk);
        reset = 0;

        // ================= DIRECTED TESTS =================

        // Test 1: First read - expected miss
        $display("\nTEST 1: First read");
        send_request(0, 32'h00000010, 128'h0);

        // Test 2: Same address - expected hit
        $display("\nTEST 2: Repeated read");
        send_request(0, 32'h00000010, 128'h0);

        // Test 3: Write miss (no-write-allocate, goes to memory only)
        $display("\nTEST 3: Write request");
        send_request(1, 32'h00000020,
                     128'h123456789ABCDEF0123456789ABCDEF0);

        // Test 4: Read the previously written address
        $display("\nTEST 4: Read after write");
        send_request(0, 32'h00000020, 128'h0);

        if (cpu_read_data === 128'h123456789ABCDEF0123456789ABCDEF0) begin
            $display("PASS: Written data read correctly");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Written data mismatch");
            fail_count = fail_count + 1;
        end

        // Test 5: Write hit on an already cached address
        $display("\nTEST 5: Write hit");
        send_request(1, 32'h00000010,
                     128'hAAAAAAAA11111111BBBBBBBB22222222);

        // Test 6: Read after write hit
        $display("\nTEST 6: Verify updated data");
        send_request(0, 32'h00000010, 128'h0);

        if (cpu_read_data === 128'hAAAAAAAA11111111BBBBBBBB22222222) begin
            $display("PASS: Write hit verified");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Write hit data mismatch");
            fail_count = fail_count + 1;
        end

        // Test 7: Address conflict
        $display("\nTEST 7: Address conflict");
        send_request(0, 32'h00000410, 128'h0);

        // Test 8: Repeat conflicting address
        $display("\nTEST 8: Repeat conflicting address");
        send_request(0, 32'h00000410, 128'h0);

        // Test 9: Access original address again
        $display("\nTEST 9: Access original address");
        send_request(0, 32'h00000010, 128'h0);

        // ================= TRACE 1: SEQUENTIAL =================
        $display("\n=== TRACE 1: SEQUENTIAL (16 consecutive words) ===");
        h0 = hit_count;
        m0 = miss_count;
        for (i = 0; i < 16; i = i + 1)
            send_request(0, 32'h00000100 + (i * 4), 128'h0);
        $display("Sequential trace: hits = %0d, misses = %0d (expected 12 hits, 4 misses)",
                 hit_count - h0, miss_count - m0);

        // ================= TRACE 2: CONFLICT =================
        $display("\n=== TRACE 2: CONFLICT (0x30 and 0x430 alternate) ===");
        h0 = hit_count;
        m0 = miss_count;
        for (i = 0; i < 6; i = i + 1) begin
            if (i % 2 == 0)
                send_request(0, 32'h00000030, 128'h0);
            else
                send_request(0, 32'h00000430, 128'h0);
        end
        $display("Conflict trace: hits = %0d, misses = %0d (expected all misses)",
                 hit_count - h0, miss_count - m0);

        // ================= TRACE 3: RANDOM =================
        $display("\n=== TRACE 3: RANDOM (20 accesses, ~25%% writes) ===");
        h0 = hit_count;
        m0 = miss_count;
        for (i = 0; i < 20; i = i + 1) begin
            rand_addr  = $random;
            rand_addr  = rand_addr & 32'h000007F0;
            rand_write = (($random & 3) == 0);
            send_request(rand_write, rand_addr,
                         {$random, $random, $random, $random});
        end
        $display("Random trace: hits = %0d, misses = %0d",
                 hit_count - h0, miss_count - m0);

        // ================= FINAL REPORT =================
        miss_rate = (read_miss_count * 1.0) / (read_hit_count + read_miss_count);
        amat = hit_latency + miss_rate * (miss_latency - hit_latency);

        $display("\n--------------------------------");
        $display("TEST SUMMARY");
        $display("Total hits   = %0d", hit_count);
        $display("Total misses = %0d", miss_count);
        $display("Read hits    = %0d", read_hit_count);
        $display("Read misses  = %0d", read_miss_count);
        $display("Hit latency  = %0d cycles", hit_latency);
        $display("Miss latency = %0d cycles", miss_latency);
        $display("Read miss rate = %f", miss_rate);
        $display("AMAT = %f cycles", amat);
        $display("Checks passed = %0d, failed = %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL CHECKS PASSED");
        else
            $display("SOME CHECKS FAILED");
        $display("--------------------------------");

        #20;
        $finish;
    end

endmodule