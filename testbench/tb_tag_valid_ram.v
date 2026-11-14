`timescale 1ns/1ps

module tb_tag_valid_ram;

    reg clk;
    reg [5:0] index;

    reg write_valid;
    reg valid_write_enable;
    wire read_valid;

    reg [21:0] write_tag;
    reg tag_write_enable;
    wire [21:0] read_tag;

    integer errors;
    integer i;

    cache_valid_ram valid_ram (
        .clk(clk),
        .index(index),
        .write_valid(write_valid),
        .write_enable(valid_write_enable),
        .read_valid(read_valid)
    );

    cache_tag_ram tag_ram (
        .clk(clk),
        .index(index),
        .write_tag(write_tag),
        .write_enable(tag_write_enable),
        .read_tag(read_tag)
    );

    always #5 clk = ~clk;

    task check_valid;
        input [5:0] addr;
        input expected;
        begin
            @(negedge clk);
            index = addr;
            @(posedge clk);
            #1;
            if (read_valid === expected)
                $display("PASS: Valid RAM index=%0d value=%b",
                         addr, read_valid);
            else begin
                $display("FAIL: Valid RAM index=%0d expected=%b got=%b",
                         addr, expected, read_valid);
                errors = errors + 1;
            end
        end
    endtask

    task check_tag;
        input [5:0] addr;
        input [21:0] expected;
        begin
            @(negedge clk);
            index = addr;
            @(posedge clk);
            #1;
            if (read_tag === expected)
                $display("PASS: Tag RAM index=%0d value=%h",
                         addr, read_tag);
            else begin
                $display("FAIL: Tag RAM index=%0d expected=%h got=%h",
                         addr, expected, read_tag);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        index = 0;
        write_valid = 0;
        valid_write_enable = 0;
        write_tag = 0;
        tag_write_enable = 0;
        errors = 0;

        // A: Check initial valid bits (all should be zero)
        for (i = 0; i < 64; i = i + 1)
            check_valid(i, 1'b0);

        // B: Write valid bit 1 at index 5
        @(negedge clk);
        index = 5;
        write_valid = 1;
        valid_write_enable = 1;
        @(posedge clk);
        #1;
        valid_write_enable = 0;

        check_valid(5, 1'b1);
        check_valid(6, 1'b0);

        // C: Writing disabled - index 7 should remain zero
        @(negedge clk);
        index = 7;
        write_valid = 1;
        valid_write_enable = 0;
        check_valid(7, 1'b0);

        // D: Clear valid bit at index 5
        @(negedge clk);
        index = 5;
        write_valid = 0;
        valid_write_enable = 1;
        @(posedge clk);
        #1;
        valid_write_enable = 0;

        check_valid(5, 1'b0);

        // E: Tag RAM write and read at index 5
        @(negedge clk);
        index = 5;
        write_tag = 22'h2AAAAA;
        tag_write_enable = 1;
        @(posedge clk);
        #1;
        tag_write_enable = 0;

        check_tag(5, 22'h2AAAAA);

        // Write a different tag at index 6
        @(negedge clk);
        index = 6;
        write_tag = 22'h155555;
        tag_write_enable = 1;
        @(posedge clk);
        #1;
        tag_write_enable = 0;

        check_tag(6, 22'h155555);

        // Index 5 must retain its previous tag
        check_tag(5, 22'h2AAAAA);

        if (errors == 0)
            $display("ALL TAG AND VALID RAM TESTS PASSED");
        else
            $display("%0d TESTS FAILED", errors);

        $finish;
    end

endmodule