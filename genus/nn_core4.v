`timescale 1ns/1ps
//==============================================================
// nn_core4.v  —  2-2-1 Backprop MLP, 4-bit Q1.3
// Scaled from Kyushu NN_CORE.v (LSI 2018)
//
// Format : 4-bit signed Q1.3
//   value = integer / 8
//   range : -1.0 to +0.875, res = 0.125
//
// Network : 2 inputs -> 2 hidden -> 1 output
// Training: (0.75,0.75)->0.875  (0.75,0.5)->0  (0.5,0.75)->0  (0.5,0.5)->0
// N=13 clocks per sample, M=1000 epochs
//==============================================================
module nn_core4(
    input             clk,
    input             res,           // high active
    input             update_coeff,  // 1=use internal ROM, 0=use external k
    input  signed [3:0] input_k1,
    input  signed [3:0] input_k2,
    output              finish_updating,
    output signed [3:0] a3_1         // final network output
);

    // Internal wires
    wire              din;
    wire              select_initial;

    wire signed [3:0] t1;
    wire signed [3:0] k1, k2;

    // w3 layer (hidden->output)
    wire signed [3:0] w3_11, w3_21;

    // a2 layer outputs
    wire [3:0] a2_1, a2_2;

    // Weight update signals (from backward to forward)
    wire signed [3:0] cap_dw2_11, cap_dw2_21;
    wire signed [3:0] cap_dw2_12, cap_dw2_22;
    wire signed [3:0] cap_dw3_11, cap_dw3_21;
    wire signed [3:0] cap_db2_1,  cap_db2_2;
    wire signed [3:0] cap_db3_1;

    // Pipeline delay wires — top level delays before backward
    // a2: 2 delays (same as original)
    wire signed [3:0] tmp_a2_1, tmp2_a2_1;
    wire signed [3:0] tmp_a2_2, tmp2_a2_2;
    // k: 4 delays
    wire signed [3:0] tmp_k1, tmp2_k1, tmp3_k1, tmp4_k1;
    wire signed [3:0] tmp_k2, tmp2_k2, tmp3_k2, tmp4_k2;
    // t: 4 delays
    wire signed [3:0] tmp_t1, tmp2_t1, tmp3_t1, tmp4_t1;

    // Control
    gen_din_sel4 GDS(.clk(clk),.res(res),.din(din),.select_initial(select_initial));

    // Forward pass
    forward4 FWD(
        .clk(clk), .reset(res), .din(din), .select_initial(select_initial),
        .update_coeff(update_coeff),
        .input_k1(input_k1), .input_k2(input_k2),
        .cap_dw2_11(cap_dw2_11), .cap_dw2_21(cap_dw2_21),
        .cap_dw2_12(cap_dw2_12), .cap_dw2_22(cap_dw2_22),
        .cap_dw3_11(cap_dw3_11), .cap_dw3_21(cap_dw3_21),
        .cap_db2_1(cap_db2_1),   .cap_db2_2(cap_db2_2),
        .cap_db3_1(cap_db3_1),
        .w3_11(w3_11), .w3_21(w3_21),
        .a2_1(a2_1),  .a2_2(a2_2),
        .a3_1(a3_1),
        .k1_out(k1), .k2_out(k2), .t1_out(t1),
        .finish_updating(finish_updating)
    );

    // Top-level pipeline delays: a2 x2
    delay1_4 DA2_1 (.clk(clk),.res(res),.in(a2_1),.out(tmp_a2_1));
    delay1_4 DA2_2 (.clk(clk),.res(res),.in(a2_2),.out(tmp_a2_2));
    delay1_4 DA2_3 (.clk(clk),.res(res),.in(tmp_a2_1),.out(tmp2_a2_1));
    delay1_4 DA2_4 (.clk(clk),.res(res),.in(tmp_a2_2),.out(tmp2_a2_2));

    // Top-level pipeline delays: k x4
    delay1_4 DK1_1(.clk(clk),.res(res),.in(k1),.out(tmp_k1));
    delay1_4 DK1_2(.clk(clk),.res(res),.in(tmp_k1),.out(tmp2_k1));
    delay1_4 DK1_3(.clk(clk),.res(res),.in(tmp2_k1),.out(tmp3_k1));
    delay1_4 DK1_4(.clk(clk),.res(res),.in(tmp3_k1),.out(tmp4_k1));
    delay1_4 DK2_1(.clk(clk),.res(res),.in(k2),.out(tmp_k2));
    delay1_4 DK2_2(.clk(clk),.res(res),.in(tmp_k2),.out(tmp2_k2));
    delay1_4 DK2_3(.clk(clk),.res(res),.in(tmp2_k2),.out(tmp3_k2));
    delay1_4 DK2_4(.clk(clk),.res(res),.in(tmp3_k2),.out(tmp4_k2));

    // Top-level pipeline delays: t x4
    delay1_4 DT1_1(.clk(clk),.res(res),.in(t1),.out(tmp_t1));
    delay1_4 DT1_2(.clk(clk),.res(res),.in(tmp_t1),.out(tmp2_t1));
    delay1_4 DT1_3(.clk(clk),.res(res),.in(tmp2_t1),.out(tmp3_t1));
    delay1_4 DT1_4(.clk(clk),.res(res),.in(tmp3_t1),.out(tmp4_t1));

    // Backward pass
    backward4 BWD(
        .clk(clk), .res(res),
        .a3_1(a3_1),
        .a2_1(tmp2_a2_1), .a2_2(tmp2_a2_2),
        .k1(tmp4_k1),     .k2(tmp4_k2),
        .t1(tmp4_t1),
        .w3_11(w3_11),    .w3_21(w3_21),
        .cap_dw3_11(cap_dw3_11), .cap_dw3_21(cap_dw3_21),
        .cap_dw2_11(cap_dw2_11), .cap_dw2_21(cap_dw2_21),
        .cap_dw2_12(cap_dw2_12), .cap_dw2_22(cap_dw2_22),
        .cap_db3_1(cap_db3_1),
        .cap_db2_1(cap_db2_1), .cap_db2_2(cap_db2_2)
    );

endmodule
