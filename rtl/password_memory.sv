module password_memory (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_enable,
    input  logic [15:0] new_password,
    output logic [15:0] stored_password
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            stored_password <= 16'h1234;
        else if (write_enable)
            stored_password <= new_password;
    end

endmodule