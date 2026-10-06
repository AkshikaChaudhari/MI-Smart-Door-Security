module lockout_timer #(
    parameter integer LOCKOUT_CYCLES = 5
)(
    input  logic clk,
    input  logic reset,
    input  logic start_lockout,

    output logic lockout_active,
    output logic lockout_done
);

    integer count;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            count <= 0;
            lockout_active <= 1'b0;
            lockout_done <= 1'b0;
        end

        else begin
            lockout_done <= 1'b0;

            // Start lockout
            if (start_lockout && !lockout_active) begin
                count <= LOCKOUT_CYCLES;
                lockout_active <= 1'b1;
            end

            // Count down
            else if (lockout_active) begin

                if (count > 1) begin
                    count <= count - 1;
                end

                else begin
                    count <= 0;
                    lockout_active <= 1'b0;
                    lockout_done <= 1'b1;
                end

            end
        end

    end

endmodule