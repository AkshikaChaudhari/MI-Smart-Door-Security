module top_testbench;

    logic clk;
    logic reset;

    logic [15:0] entered_password;
    logic [31:0] rfid_id;

    logic pin_entered;
    logic rfid_present;

    logic emergency_override;
    logic door_open;

    logic change_password;
    logic [15:0] new_password;

    logic door_unlock;
    logic alarm;
    logic buzzer_out;
    logic servo_pwm;

    logic authentication_success;
    logic [1:0] attempt_count;
    logic lockout_active;


    // =====================================================
    // DUT
    // =====================================================

    door_lock_top dut (

        .clk(clk),
        .reset(reset),

        .entered_password(entered_password),
        .rfid_id(rfid_id),

        .pin_entered(pin_entered),
        .rfid_present(rfid_present),

        .emergency_override(emergency_override),
        .door_open(door_open),

        .change_password(change_password),
        .new_password(new_password),

        .door_unlock(door_unlock),
        .alarm(alarm),
        .buzzer_out(buzzer_out),
        .servo_pwm(servo_pwm),

        .authentication_success(authentication_success),
        .attempt_count(attempt_count),
        .lockout_active(lockout_active)
    );


    // =====================================================
    // CLOCK
    // =====================================================

    always #5 clk = ~clk;


    // =====================================================
    // TEST
    // =====================================================

    initial begin

        clk = 0;
        reset = 1;

        entered_password = 16'h0000;
        rfid_id = 32'h00000000;

        pin_entered = 0;
        rfid_present = 0;

        emergency_override = 0;
        door_open = 0;

        change_password = 0;
        new_password = 16'h0000;


        // =================================================
        // RESET
        // =================================================

        #12;
        reset = 0;

        $display("");
        $display("====================================");
        $display(" DIGITAL DOOR LOCK SYSTEM TEST");
        $display("====================================");


        // =================================================
        // TEST 1: CORRECT PIN + RFID
        // =================================================

        $display("");
        $display("TEST 1: Correct PIN + RFID");

        entered_password = 16'h1234;

        // Enter PIN
        pin_entered = 1;

        @(posedge clk);
        #1;

        pin_entered = 0;

        // Give FSM time to enter RFID state
        @(posedge clk);
        #1;

        // Present RFID
        rfid_id = 32'hA1B2C3D4;
        rfid_present = 1;

        @(posedge clk);
        #1;

        rfid_present = 0;

        @(posedge clk);
        #1;

        $display("Door Unlock : %b", door_unlock);
        $display("Alarm       : %b", alarm);
        $display("Success     : %b", authentication_success);


        // =================================================
        // RESET
        // =================================================

        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;


        // =================================================
        // TEST 2: WRONG PIN
        // =================================================

        $display("");
        $display("TEST 2: Wrong PIN");

        entered_password = 16'h9999;

        pin_entered = 1;

        @(posedge clk);
        #1;

        pin_entered = 0;

        @(posedge clk);
        #1;

        $display("Attempt Count: %d", attempt_count);
        $display("Lockout      : %b", lockout_active);


        // =================================================
        // TEST 3: WRONG PIN AGAIN
        // =================================================

        $display("");
        $display("TEST 3: Wrong PIN Again");

        pin_entered = 1;

        @(posedge clk);
        #1;

        pin_entered = 0;

        @(posedge clk);
        #1;

        $display("Attempt Count: %d", attempt_count);
        $display("Lockout      : %b", lockout_active);


        // =================================================
        // TEST 4: THIRD WRONG PIN
        // =================================================

        $display("");
        $display("TEST 4: Third Wrong PIN");

        pin_entered = 1;

        @(posedge clk);
        #1;

        pin_entered = 0;

        @(posedge clk);
        #1;

        $display("Attempt Count: %d", attempt_count);
        $display("Lockout      : %b", lockout_active);
        $display("Alarm        : %b", alarm);


        // =================================================
        // TEST 5: EMERGENCY OVERRIDE
        // =================================================

        $display("");
        $display("TEST 5: Emergency Override");

        emergency_override = 1;

        @(posedge clk);
        #1;

        $display("Door Unlock : %b", door_unlock);
        $display("Alarm       : %b", alarm);

        emergency_override = 0;


        // =================================================
        // TEST 6: DOOR OPEN TIMEOUT
        // =================================================

        $display("");
        $display("TEST 6: Door Open Timeout");

        door_open = 1;

        #70;

        $display("Door Open   : %b", door_open);
        $display("Alarm       : %b", alarm);

        door_open = 0;

        #10;

        $display("Door Closed");
        $display("Alarm       : %b", alarm);


        // =================================================
        // FINISH
        // =================================================

        $display("");
        $display("====================================");
        $display(" TEST COMPLETED");
        $display("====================================");

        $finish;

    end

endmodule