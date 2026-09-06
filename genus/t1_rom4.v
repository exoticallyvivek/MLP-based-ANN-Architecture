`timescale 1ns/1ps
// t1_rom4.v — target ROM, 4-bit Q1.3
// Targets: t1 = [0.875, 0, 0, 0]  (AND-like: high only when both k1,k2 high)
// 0.875 = int 7 = 4'b0111 ; 0.0 = 4'b0000
module t1_rom4(input clk, input din, input [3:0] addr, output reg signed [3:0] t_out);
    always @(posedge clk)
        if (din) begin
            case (addr)
                4'd0: t_out <= 4'sb0111;  // 0.875 (target "true")
                default: t_out <= 4'sb0000;  // 0.0
            endcase
        end
endmodule
