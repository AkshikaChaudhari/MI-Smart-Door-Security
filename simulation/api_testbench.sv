module api_testbench;

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


    // DUT
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


    // Clock
    always #5 clk = ~clk;

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


    // Receive PIN from Node.js
    if ($value$plusargs("PIN=%h", entered_password)) begin
        $display("PIN ARGUMENT RECEIVED");
    end
    else begin
        $display("PIN ARGUMENT NOT RECEIVED");
    end


    // Receive RFID from Node.js
    if ($value$plusargs("RFID=%h", rfid_id)) begin
        $display("RFID ARGUMENT RECEIVED");
    end
    else begin
        $display("RFID ARGUMENT NOT RECEIVED");
    end


    $display("INPUT PIN  = %h", entered_password);
    $display("INPUT RFID = %h", rfid_id);


    // Reset
    #12;
    reset = 0;

    // Enter PIN
    pin_entered = 1;

    @(posedge clk);
    #1;

    pin_entered = 0;

    @(posedge clk);
    #1;

    // Present RFID
    rfid_present = 1;

    @(posedge clk);
    #1;

    rfid_present = 0;

    @(posedge clk);
    #1;


    $display("");
    $display("RESULT");
    $display("DOOR_UNLOCK=%b", door_unlock);
    $display("ALARM=%b", alarm);
    $display("AUTH_SUCCESS=%b", authentication_success);
    $display("ATTEMPTS=%d", attempt_count);
    $display("LOCKOUT=%b", lockout_active);
    $display("BUZZER=%b", buzzer_out);
    $display("SERVO=%b", servo_pwm);

    $finish;

end

endmodule