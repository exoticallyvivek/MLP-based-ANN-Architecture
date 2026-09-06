`timescale 1ns/1ps
// sel_k4.v — input MUX: ROM vs external
module sel_k4(
    input  signed [3:0] kin,   // external input
    input  signed [3:0] krom,  // ROM data
    input               upd,   // 1=use ROM
    output signed [3:0] k
);
    assign k = upd ? krom : kin;
endmodule
