module door_timeout #(
    parameter integer TIMEOUT_CYCLES = 5
)(
    input  logic clk,
    input  logic reset,
    input  logic door_open,

    output logic timeout_alarm
);

    integer count;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            count <= 0;
            timeout_alarm <= 1'b0;
        end

        else begin

            // Door is closed → reset timer
            if (!door_open) begin
                count <= 0;
                timeout_alarm <= 1'b0;
            end

            // Door is open → start counting
            else begin

                if (count < TIMEOUT_CYCLES) begin
                    count <= count + 1;
                end

                else begin
                    timeout_alarm <= 1'b1;
                end

            end

        end

    end

endmodule