`timescale 1ns/1ps
//==============================================================
// z2_4.v  —  2-input MAC + saturate, 4-bit Q1.3
// Clean: combinational logic first, ONE registered output
// No blocking/continuous race condition
// Latency: 1 clock
//==============================================================
module z2_4(
    input              clk, reset,
    input  signed [3:0] x1, x2, w1, w2, b,
    output reg [3:0] z
);
    // ---- combinational ----
    wire signed [7:0] net1 = x1 * w1;   // Q2.6
    wire signed [7:0] net2 = x2 * w2;   // Q2.6

    // extract Q1.3 portion (>>3) and sign-extend to 6 bits
    wire signed [5:0] p1 = {{2{net1[6]}}, net1[6:3]};
    wire signed [5:0] p2 = {{2{net2[6]}}, net2[6:3]};
    wire signed [5:0] bc = {{2{b[3]}},    b};

    wire signed [5:0] s  = p1 + p2 + bc;

    // saturation: clamp to 4-bit Q1.3 range [-1.0 .. +0.875]
    wire sat_hi = (s > 6'sd7);    // > +0.875
    wire sat_lo = (s < -6'sd8);   // < -1.0
    wire signed [3:0] z_comb = sat_hi ? 4'sb0111 :
                               sat_lo ? 4'sb1000 : s[3:0];

    // ---- register ----
    always @(posedge clk)
        z <= reset ? 4'sd0 : z_comb;
endmodule
