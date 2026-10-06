module fsm_testbench;

    logic clk;
    logic reset;

    logic pin_valid;
    logic rfid_valid;
    logic lockout_active;
    logic emergency_override;

    logic door_unlock;
    logic alarm;
    logic authentication_success;

    security_fsm fsm (
        .clk(clk),
        .reset(reset),
        .pin_valid(pin_valid),
        .rfid_valid(rfid_valid),
        .lockout_active(lockout_active),
        .emergency_override(emergency_override),
        .door_unlock(door_unlock),
        .alarm(alarm),
        .authentication_success(authentication_success)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        pin_valid = 0;
        rfid_valid = 0;
        lockout_active = 0;
        emergency_override = 0;

        // Reset
        #12;
        reset = 0;

        // =====================================
        // PIN AUTHENTICATION
        // =====================================

        // First clock: LOCKED -> PIN_AUTH
        @(posedge clk);
        #1;

        // Now provide valid PIN
        pin_valid = 1;

        // Second clock: PIN_AUTH -> RFID_AUTH
        @(posedge clk);
        #1;

        pin_valid = 0;

        $display("After correct PIN:");
        $display("Door Unlock: %b", door_unlock);
        $display("Alarm: %b", alarm);

        // =====================================
        // RFID AUTHENTICATION
        // =====================================

        // Provide valid RFID
        rfid_valid = 1;

        // RFID_AUTH -> UNLOCKED
        @(posedge clk);
        #1;

        rfid_valid = 0;

        // Check UNLOCKED state
        @(posedge clk);
        #1;

        $display("");
        $display("Correct PIN + RFID:");
        $display("Door Unlock: %b", door_unlock);
        $display("Alarm: %b", alarm);
        $display("Authentication Success: %b",
                 authentication_success);

        // =====================================
        // RESET
        // =====================================

        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;

        // =====================================
        // WRONG RFID TEST
        // =====================================

        // LOCKED -> PIN_AUTH
        @(posedge clk);
        #1;

        // Correct PIN
        pin_valid = 1;

        // PIN_AUTH -> RFID_AUTH
        @(posedge clk);
        #1;

        pin_valid = 0;

        // RFID is WRONG
        rfid_valid = 0;

        // RFID_AUTH -> ALARM
        @(posedge clk);
        #1;

        $display("");
        $display("Wrong RFID:");
        $display("Door Unlock: %b", door_unlock);
        $display("Alarm: %b", alarm);

        #10;

        $finish;

    end

endmodule