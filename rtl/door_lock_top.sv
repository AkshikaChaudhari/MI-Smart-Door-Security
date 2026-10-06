module door_lock_top (

    input  logic        clk,
    input  logic        reset,

    // -----------------------------
    // Authentication inputs
    // -----------------------------
    input  logic [15:0] entered_password,
    input  logic [31:0] rfid_id,

    input  logic        pin_entered,
    input  logic        rfid_present,

    // -----------------------------
    // Security controls
    // -----------------------------
    input  logic        emergency_override,
    input  logic        door_open,

    // -----------------------------
    // Password change
    // -----------------------------
    input  logic        change_password,
    input  logic [15:0] new_password,

    // -----------------------------
    // Outputs
    // -----------------------------
    output logic        door_unlock,
    output logic        alarm,
    output logic        buzzer_out,
    output logic        servo_pwm,

    output logic        authentication_success,
    output logic [1:0]  attempt_count,
    output logic        lockout_active
);

    // =========================================================
    // INTERNAL SIGNALS
    // =========================================================

    logic [15:0] stored_password;

    logic pin_valid;
    logic rfid_valid;

    logic auth_failed;
    logic auth_success;

    logic lockout_start;
    logic lockout_done;

    logic fsm_alarm;
    logic timeout_alarm;


    // =========================================================
    // 1. PASSWORD MEMORY
    // =========================================================

    password_memory password_mem (

        .clk(clk),
        .reset(reset),

        .write_enable(change_password),
        .new_password(new_password),

        .stored_password(stored_password)
    );


    // =========================================================
    // 2. PASSWORD COMPARATOR
    // =========================================================

    password_comparator password_check (

        .entered_password(entered_password),
        .stored_password(stored_password),

        .password_valid(pin_valid)
    );


    // =========================================================
    // 3. RFID AUTHENTICATOR
    // =========================================================

    rfid_authenticator rfid_check (

        .rfid_id(rfid_id),

        .rfid_valid(rfid_valid)
    );


    // =========================================================
    // 4. AUTHENTICATION CONTROLLER
    // =========================================================

    auth_controller auth_control (

        .clk(clk),
        .reset(reset),

        .pin_valid(pin_valid),
        .rfid_valid(rfid_valid),

        .pin_entered(pin_entered),
        .rfid_present(rfid_present),

        .lockout(lockout_start),

        .auth_failed(auth_failed),
        .auth_success(auth_success)
    );


    // =========================================================
    // 5. ATTEMPT COUNTER
    // =========================================================

    attempt_counter attempts (

        .clk(clk),
        .reset(reset),

        .auth_failed(auth_failed),

        .attempt_count(attempt_count),
        .lockout(lockout_start)
    );


    // =========================================================
    // 6. LOCKOUT TIMER
    // =========================================================

    lockout_timer lock_timer (

        .clk(clk),
        .reset(reset),

        .start_lockout(lockout_start),

        .lockout_active(lockout_active),
        .lockout_done(lockout_done)
    );


    // =========================================================
    // 7. SECURITY FSM
    // =========================================================

    security_fsm security (

        .clk(clk),
        .reset(reset),

        .pin_valid(pin_valid),
        .rfid_valid(rfid_valid),

        .lockout_active(lockout_active),
        .emergency_override(emergency_override),

        .door_unlock(door_unlock),
        .alarm(fsm_alarm),
        .authentication_success(authentication_success)
    );


    // =========================================================
    // 8. DOOR OPEN TIMEOUT
    // =========================================================

    door_timeout door_timer (

        .clk(clk),
        .reset(reset),

        .door_open(door_open),

        .timeout_alarm(timeout_alarm)
    );


    // =========================================================
    // 9. SERVO PWM
    // =========================================================

    servo_pwm servo (

        .clk(clk),
        .reset(reset),

        .unlock(door_unlock),

        .pwm(servo_pwm)
    );


    // =========================================================
    // 10. FINAL ALARM
    // =========================================================

    assign alarm = fsm_alarm | timeout_alarm;


    // =========================================================
    // 11. BUZZER
    // =========================================================

    buzzer alarm_buzzer (

        .clk(clk),
        .reset(reset),

        .alarm_enable(alarm),

        .buzzer_out(buzzer_out)
    );


endmodule