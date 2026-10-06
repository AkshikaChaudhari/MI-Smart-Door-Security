module attempt_testbench;

    logic clk;
    logic reset;
    logic auth_failed;

    logic [1:0] attempt_count;
    logic lockout;

    attempt_counter counter (
        .clk(clk),
        .reset(reset),
        .auth_failed(auth_failed),
        .attempt_count(attempt_count),
        .lockout(lockout)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        auth_failed = 0;

        #10;
        reset = 0;

        // Wrong attempt 1
        #5;
        auth_failed = 1;
        #10;
        auth_failed = 0;

        $display("Attempt 1 -> Count: %d Lockout: %b",
                 attempt_count, lockout);

        // Wrong attempt 2
        #5;
        auth_failed = 1;
        #10;
        auth_failed = 0;

        $display("Attempt 2 -> Count: %d Lockout: %b",
                 attempt_count, lockout);

        // Wrong attempt 3
        #5;
        auth_failed = 1;
        #10;
        auth_failed = 0;

        $display("Attempt 3 -> Count: %d Lockout: %b",
                 attempt_count, lockout);

        #10;
        $finish;

    end

endmodule