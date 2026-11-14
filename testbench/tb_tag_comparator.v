`timescale 1ns/1ps

module tb_tag_comparator;

    reg [21:0] requested_tag;
    reg [21:0] stored_tag;
    reg valid_bit;

    wire hit;
    integer errors;

    tag_comparator uut (
        .requested_tag(requested_tag),
        .stored_tag(stored_tag),
        .valid_bit(valid_bit),
        .hit(hit)
    );

    task check;
        input [21:0] req_tag;
        input [21:0] st_tag;
        input valid;
        input expected_hit;
        begin
            requested_tag = req_tag;
            stored_tag = st_tag;
            valid_bit = valid;
            #1;

            if (hit === expected_hit)
                $display("PASS: requested=%h stored=%h valid=%b hit=%b",
                         req_tag, st_tag, valid, hit);
            else begin
                $display("FAIL: requested=%h stored=%h valid=%b expected=%b got=%b",
                         req_tag, st_tag, valid, expected_hit, hit);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        // Test 1: Same tags, valid = 1
        check(22'h123456, 22'h123456, 1'b1, 1'b1);

        // Test 2: Same tags, valid = 0
        check(22'h123456, 22'h123456, 1'b0, 1'b0);

        // Test 3: Different tags, valid = 1
        check(22'h123456, 22'h654321, 1'b1, 1'b0);

        // Test 4: Different tags, valid = 0
        check(22'h123456, 22'h654321, 1'b0, 1'b0);

        // Test 5: Tags differ by only one bit
        check(22'h155555, 22'h155554, 1'b1, 1'b0);

        if (errors == 0)
            $display("ALL TAG COMPARATOR TESTS PASSED");
        else
            $display("%0d TESTS FAILED", errors);

        $finish;
    end

endmodule