
module alarm_testbench;

    logic clk;
    logic reset;
    logic door_open;

    logic timeout_alarm;

    logic buzzer_out;


    door_timeout #(
        .TIMEOUT_CYCLES(5)
    ) timeout_module (
        .clk(clk),
        .reset(reset),
        .door_open(door_open),
        .timeout_alarm(timeout_alarm)
    );


    buzzer #(
        .TOGGLE_COUNT(2)
    ) buzzer_module (
        .clk(clk),
        .reset(reset),
        .alarm_enable(timeout_alarm),
        .buzzer_out(buzzer_out)
    );


    always #5 clk = ~clk;


    initial begin

        clk = 0;
        reset = 1;
        door_open = 0;

        #12;

        reset = 0;

        // Open door
        door_open = 1;

        $display("DOOR OPEN");

        repeat (12) begin

            @(posedge clk);
            #1;

            $display(
                "DOOR_OPEN=%b ALARM=%b BUZZER=%b",
                door_open,
                timeout_alarm,
                buzzer_out
            );

        end


        // Close door
        door_open = 0;

        #10;

        $display("DOOR CLOSED");

        $display(
            "DOOR_OPEN=%b ALARM=%b BUZZER=%b",
            door_open,
            timeout_alarm,
            buzzer_out
        );

        $finish;

    end

endmodule