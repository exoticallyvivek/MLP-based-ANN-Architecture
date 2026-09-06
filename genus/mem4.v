`timescale 1ns/1ps
//==============================================================
// mem4.v  —  16x4-bit Sigmoid LUT ROM
// SYNTHESIS : empty body = black box. Genus skips. You hand-design in Virtuoso.
// SIMULATION: ifdef SIMULATION adds behavioral model.
// Incisive : irun +define+SIMULATION ...
// Genus    : genus (no +define) — sees empty module = black box
//==============================================================
module mem4 (
    input        CLK,
    input        DIN,
    input  [3:0] ADDR,
    output [3:0] DOUT
);
`ifdef SIMULATION
    reg [3:0] lut_out;
    always @(*) case (ADDR)
        4'd0,4'd1,4'd2,4'd15 : lut_out = 4'd4;
        4'd3,4'd4,4'd5       : lut_out = 4'd5;
        4'd6,4'd7            : lut_out = 4'd6;
        4'd8,4'd9            : lut_out = 4'd2;
        default              : lut_out = 4'd3;
    endcase
    reg [3:0] ff = 4'd4;
    always @(posedge CLK) if (DIN) ff <= lut_out;
    assign DOUT = ff;
`endif
// NO else body — Genus sees empty module = automatic black box
endmodule
