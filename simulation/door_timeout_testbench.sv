module door_timeout_testbench;

    logic clk;
    logic reset;
    logic door_open;

    logic timeout_alarm;

    door_timeout #(
        .TIMEOUT_CYCLES(5)
    ) timer (
        .clk(clk),
        .reset(reset),
        .door_open(door_open),
        .timeout_alarm(timeout_alarm)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        door_open = 0;

        // Reset
        #10;
        reset = 0;

        // Open door
        door_open = 1;

        $display("Door opened");

        // Wait for timeout
        #60;

        $display("After timeout:");
        $display("Door Open: %b", door_open);
        $display("Timeout Alarm: %b", timeout_alarm);

        // Close door
        door_open = 0;

        #10;

        $display("");
        $display("Door closed:");
        $display("Timeout Alarm: %b", timeout_alarm);

        $finish;

    end

endmodule