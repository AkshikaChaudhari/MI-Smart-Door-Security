module testbench;

    logic clk;
    logic reset;

    logic [15:0] new_password;
    logic write_enable;
    logic [15:0] stored_password;

    logic [15:0] entered_password;
    logic password_valid;

    logic [31:0] rfid_id;
    logic rfid_valid;


    password_memory memory (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .new_password(new_password),
        .stored_password(stored_password)
    );


    password_comparator comparator (
        .entered_password(entered_password),
        .stored_password(stored_password),
        .password_valid(password_valid)
    );


    rfid_authenticator rfid (
        .rfid_id(rfid_id),
        .rfid_valid(rfid_valid)
    );


    always #5 clk = ~clk;


    initial begin

        clk = 0;
        reset = 1;

        new_password = 0;
        write_enable = 0;
        entered_password = 16'h1234;
        rfid_id = 32'hA1B2C3D4;

        #10;
        reset = 0;

        #5;

        $display("Stored PIN : %h", stored_password);
        $display("Entered PIN: %h", entered_password);
        $display("PIN Valid  : %b", password_valid);

        $display("RFID Valid : %b", rfid_valid);

        #10;

        // Wrong PIN
        entered_password = 16'h9999;

        #5;

        $display("Wrong PIN  : %b", password_valid);

        // Wrong RFID
        rfid_id = 32'hFFFFFFFF;

        #5;

        $display("Wrong RFID : %b", rfid_valid);

        $finish;

    end

endmodule