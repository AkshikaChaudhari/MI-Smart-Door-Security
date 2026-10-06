module buzzer #(
    parameter integer TOGGLE_COUNT = 25
)(
    input  logic clk,
    input  logic reset,
    input  logic alarm_enable,

    output logic buzzer_out
);

    integer count;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            count <= 0;
            buzzer_out <= 1'b0;
        end

        else if (!alarm_enable) begin
            count <= 0;
            buzzer_out <= 1'b0;
        end

        else begin

            if (count >= TOGGLE_COUNT - 1) begin
                count <= 0;
                buzzer_out <= ~buzzer_out;
            end
            else begin
                count <= count + 1;
            end

        end

    end

endmodule