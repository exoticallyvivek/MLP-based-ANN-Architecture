`timescale 1ns/1ps
// k2_rom4.v — k2 training data ROM, 4-bit Q1.3
// Patterns: k2 = [0.75, 0.5, 0.75, 0.5] for addr 0..3
module k2_rom4(input clk, input din, input [3:0] addr, output reg signed [3:0] k_out);
    always @(posedge clk)
        if (din) begin
            case (addr)
                4'd0: k_out <= 4'sb0110;  // 0.750
                4'd1: k_out <= 4'sb0100;  // 0.500
                4'd2: k_out <= 4'sb0110;  // 0.750
                4'd3: k_out <= 4'sb0100;  // 0.500
                default: k_out <= 4'sb0000;
            endcase
        end
endmodule
