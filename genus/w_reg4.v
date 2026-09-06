`timescale 1ns/1ps
module w_reg4 #(parameter signed [3:0] INIT=4'sb0000)(
    input clk, reset, sel_i, sel_u,
    input signed [3:0] dw,
    output reg signed [3:0] w 
);
    wire signed [3:0] delta = sel_u ? dw : 4'sd0;
    wire signed [3:0] w_new = w + delta;
    always @(posedge clk) begin
        if (reset)      w <= 4'sd0;
        else if (sel_i) w <= INIT;
        else            w <= w_new;
    end
endmodule
