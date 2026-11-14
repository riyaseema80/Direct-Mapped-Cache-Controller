`timescale 1ns/1ps

module tb_address_decoder;

    reg  [31:0] address;
    wire [21:0] tag;
    wire [5:0] index;
    wire [3:0] offset;

    integer errors;

    address_decoder uut (
        .address(address),
        .tag(tag),
        .index(index),
        .offset(offset)
    );

    task check;
        input [31:0] addr;
        input [21:0] exp_tag;
        input [5:0] exp_index;
        input [3:0] exp_offset;
        begin
            address = addr;
            #1;

            if (tag === exp_tag &&
                index === exp_index &&
                offset === exp_offset) begin
                $display("PASS: %h -> tag=%h index=%0d offset=%h",
                         addr, tag, index, offset);
            end
            else begin
                $display("FAIL: %h -> got tag=%h index=%0d offset=%h",
                         addr, tag, index, offset);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        // Original test cases
        check(32'h00000000, 22'h0, 6'd0, 4'h0);
        check(32'h00000010, 22'h0, 6'd1, 4'h0);
        check(32'h00000410, 22'h1, 6'd1, 4'h0);

        // Additional test cases
        check(32'h000003F0, 22'h0, 6'd63, 4'h0);
        check(32'hFFFFFFFF, 22'h3FFFFF, 6'd63, 4'hF);
        check(32'h0000001C, 22'h0, 6'd1, 4'hC);

        if (errors == 0)
            $display("ALL ADDRESS DECODER TESTS PASSED");
        else
            $display("%0d TESTS FAILED", errors);

        $finish;
    end

endmodule