module security_fsm (
    input  logic clk,
    input  logic reset,

    input  logic pin_valid,
    input  logic rfid_valid,

    input  logic lockout_active,
    input  logic emergency_override,

    output logic door_unlock,
    output logic alarm,
    output logic authentication_success
);

    typedef enum logic [2:0] {
        LOCKED,
        PIN_AUTH,
        RFID_AUTH,
        UNLOCKED,
        ALARM
    } state_t;

    state_t current_state, next_state;

    // State register
    always_ff @(posedge clk or posedge reset) begin

        if (reset)
            current_state <= LOCKED;

        else
            current_state <= next_state;

    end

    // Next-state logic
    always_comb begin

        next_state = current_state;

        case (current_state)

            LOCKED: begin

                if (emergency_override)
                    next_state = UNLOCKED;

                else if (lockout_active)
                    next_state = ALARM;

                else
                    next_state = PIN_AUTH;

            end

            PIN_AUTH: begin

                if (pin_valid)
                    next_state = RFID_AUTH;

                else
                    next_state = LOCKED;

            end

            RFID_AUTH: begin

                if (rfid_valid)
                    next_state = UNLOCKED;

                else
                    next_state = ALARM;

            end

            UNLOCKED: begin

                next_state = UNLOCKED;
            end

            ALARM: begin

                if (emergency_override)
                    next_state = UNLOCKED;

                else
                    next_state = ALARM;
            end

            default:
                next_state = LOCKED;

        endcase

    end

    // Output logic
    always_comb begin

        door_unlock = 1'b0;
        alarm = 1'b0;
        authentication_success = 1'b0;

        case (current_state)

            UNLOCKED: begin
                door_unlock = 1'b1;
                authentication_success = 1'b1;
            end

            ALARM: begin
                alarm = 1'b1;
            end

            default: begin
                door_unlock = 1'b0;
                alarm = 1'b0;
            end

        endcase

    end

endmodule