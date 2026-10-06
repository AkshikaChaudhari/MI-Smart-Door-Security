module password_comparator (
    input  logic [15:0] entered_password,
    input  logic [15:0] stored_password,
    output logic        password_valid
);

    always_comb begin
        password_valid =
            (entered_password == stored_password);
    end

endmodule