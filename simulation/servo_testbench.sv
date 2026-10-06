module servo_testbench;

    logic clk;
    logic reset;
    logic unlock;
    logic pwm;

    servo_pwm #(
        .PERIOD(100),
        .LOCKED_PULSE(10),
        .UNLOCKED_PULSE(20)
    ) servo (
        .clk(clk),
        .reset(reset),
        .unlock(unlock),
        .pwm(pwm)
    );

    always #1 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        unlock = 0;

        #5;
        reset = 0;

        $display("Servo LOCKED");
        #100;

        unlock = 1;

        $display("Servo UNLOCKED");
        #100;

        unlock = 0;

        $display("Servo LOCKED again");
        #100;

        $finish;

    end

endmodule