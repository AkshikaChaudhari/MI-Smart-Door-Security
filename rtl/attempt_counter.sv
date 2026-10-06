module attempt_counter (
    input  logic       clk,
    input  logic       reset,
    input  logic       auth_failed,

    output logic [1:0] attempt_count,
    output logic       lockout
);

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            attempt_count <= 2'd0;
            lockout       <= 1'b0;
        end

        else if (auth_failed) begin

            if (attempt_count < 2'd3) begin
                attempt_count <= attempt_count + 1'b1;
            end

            if (attempt_count >= 2'd2) begin
                lockout <= 1'b1;
            end

        end

    end

endmodule