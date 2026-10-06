module lockout_testbench;

    logic clk;
    logic reset;
    logic start_lockout;

    logic lockout_active;
    logic lockout_done;

    lockout_timer #(
        .LOCKOUT_CYCLES(5)
    ) timer (
        .clk(clk),
        .reset(reset),
        .start_lockout(start_lockout),
        .lockout_active(lockout_active),
        .lockout_done(lockout_done)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        start_lockout = 0;

        #10;
        reset = 0;

        // Start lockout
        #5;
        start_lockout = 1;

        #10;
        start_lockout = 0;

        $display("Lockout started -> Active: %b",
                 lockout_active);

        // Wait for timer
        #50;

        $display("Lockout finished -> Active: %b Done: %b",
                 lockout_active,
                 lockout_done);

        #10;
        $finish;

    end

endmodule