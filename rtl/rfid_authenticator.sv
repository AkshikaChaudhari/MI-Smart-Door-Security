module rfid_authenticator (
    input  logic [31:0] rfid_id,
    output logic        rfid_valid
);

    localparam logic [31:0] AUTHORIZED_RFID = 32'hA1B2C3D4;

    always_comb begin
        rfid_valid = (rfid_id == AUTHORIZED_RFID);
    end

endmodule