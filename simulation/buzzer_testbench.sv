module buzzer_testbench;

    logic clk;
    logic reset;
    logic alarm_enable;

    logic buzzer_out;


    buzzer #(
        .TOGGLE_COUNT(5)
    ) dut (
        .clk(clk),
        .reset(reset),
        .alarm_enable(alarm_enable),
        .buzzer_out(buzzer_out)
    );


    // Clock
    always #5 clk = ~clk;


    initial begin

        clk = 0;
        reset = 1;
        alarm_enable = 0;

        #12;

        reset = 0;

        $display("Buzzer OFF test");

        #20;

        $display("Buzzer ON test");

        alarm_enable = 1;


        // Observe buzzer for several cycles
        repeat (20) begin
            @(posedge clk);
            #1;

            $display(
                "Time=%0t | Alarm=%b | Buzzer=%b",
                $time,
                alarm_enable,
                buzzer_out
            );
        end


        $display("Buzzer OFF");

        alarm_enable = 0;

        repeat (5) begin
            @(posedge clk);
            #1;

            $display(
                "Time=%0t | Alarm=%b | Buzzer=%b",
                $time,
                alarm_enable,
                buzzer_out
            );
        end


        $finish;

    end

endmodule