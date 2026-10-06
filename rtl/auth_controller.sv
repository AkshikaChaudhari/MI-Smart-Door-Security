module auth_controller (
    input  logic clk,
    input  logic reset,

    input  logic pin_valid,
    input  logic rfid_valid,

    input  logic pin_entered,
    input  logic rfid_present,

    input  logic lockout,

    output logic auth_failed,
    output logic auth_success
);

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            auth_failed  <= 1'b0;
            auth_success <= 1'b0;
        end

        else begin

            // Default: no new event
            auth_failed  <= 1'b0;
            auth_success <= 1'b0;

            // PIN entered
            if (pin_entered && !lockout) begin

                if (!pin_valid)
                    auth_failed <= 1'b1;

            end

            // RFID presented after valid PIN
            if (rfid_present && pin_valid && !lockout) begin

                if (rfid_valid)
                    auth_success <= 1'b1;
                else
                    auth_failed <= 1'b1;

            end

        end

    end

endmodule