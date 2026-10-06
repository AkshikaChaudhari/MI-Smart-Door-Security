module servo_pwm #(
    parameter integer PERIOD = 1000,
    parameter integer LOCKED_PULSE = 50,
    parameter integer UNLOCKED_PULSE = 100
)(
    input  logic clk,
    input  logic reset,
    input  logic unlock,

    output logic pwm
);

    integer counter;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            counter <= 0;
            pwm <= 0;
        end

        else begin

            if (counter >= PERIOD - 1)
                counter <= 0;
            else
                counter <= counter + 1;

            if (unlock) begin
                if (counter < UNLOCKED_PULSE)
                    pwm <= 1'b1;
                else
                    pwm <= 1'b0;
            end

            else begin
                if (counter < LOCKED_PULSE)
                    pwm <= 1'b1;
                else
                    pwm <= 1'b0;
            end

        end

    end

endmodule