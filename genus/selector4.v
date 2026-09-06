`timescale 1ns/1ps
// selector4.v — Pulse enable_update at clock N-1 (every N cycles)
module selector4(
    input             clk, reset, update_coeff,
    output reg        enable_update
);
    parameter N = 13;
    reg [3:0] cnt;
    always @(posedge clk) begin
        if (reset)        cnt <= 4'd0;
        else if(cnt==(N-1)) cnt <= 4'd0;
        else              cnt <= cnt + 4'd1;
    end
    always @(posedge clk) begin
        if (reset)        enable_update <= 1'b0;
        else              enable_update <= (cnt==(N-1)) & update_coeff;
    end
endmodule
