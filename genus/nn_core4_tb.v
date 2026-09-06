`timescale 1ns/1ps
//==============================================================
// nn_core4_tb.v — Testbench for 2-2-1 4-bit MLP
// Monitors a3_1 output after each epoch cycle
// Expected convergence: pattern (0.75,0.75)->high, rest->low
//==============================================================
module nn_core4_tb;
    reg         clk, res, update_coeff;
    reg  signed [3:0] input_k1, input_k2;
    wire signed [3:0] a3_1;
    wire              finish_updating;

    // DUT
    nn_core4 DUT(
        .clk(clk), .res(res), .update_coeff(update_coeff),
        .input_k1(input_k1), .input_k2(input_k2),
        .a3_1(a3_1), .finish_updating(finish_updating)
    );

    // 10ns clock (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    integer i;
    real a3_real;
    initial begin
        $dumpfile("nn_core4.vcd");
        $dumpvars(0, nn_core4_tb);

        // Reset
        res = 1; update_coeff = 0;
        input_k1 = 4'sb0; input_k2 = 4'sb0;
        @(posedge clk); @(posedge clk);
        res = 0;

        // Use internal ROM for training
        update_coeff = 1;

        $display("=== 4-bit 2-2-1 MLP training start ===");
        $display("Format: Q1.3  value = integer/8");
        $display("Network: 2 inputs -> 2 hidden -> 1 output");
        $display("Target: (0.75,0.75)->0.875, (0.75,0.5)->0, (0.5,0.75)->0, (0.5,0.5)->0");
        $display("---");

        // Monitor every 130 clocks (= 10 epochs * N=13)
        for (i=0; i<1000 && !finish_updating; i=i+1) begin
            repeat(130) @(posedge clk);
            a3_real = $signed(a3_1) / 8.0;
            $display("Epoch ~%0d | a3_1 raw=%0d (%0.3f) | finish=%b",
                      i*10, $signed(a3_1), a3_real, finish_updating);
        end

        // Final inference: test all 4 patterns
        update_coeff = 0;
        @(posedge clk);
        $display("---");
        $display("=== Inference (external inputs) ===");

        // Pattern (0.75, 0.75) -> expect high (~0.75)
        input_k1=4'sb0110; input_k2=4'sb0110;
        repeat(6) @(posedge clk);
        $display("k=(%0.3f,%0.3f) -> a3=%0.3f (expect ~0.750)",
                  $signed(input_k1)/8.0, $signed(input_k2)/8.0, $signed(a3_1)/8.0);

        // Pattern (0.75, 0.5) -> expect low (~0.25-0.375)
        input_k1=4'sb0110; input_k2=4'sb0100;
        repeat(6) @(posedge clk);
        $display("k=(%0.3f,%0.3f) -> a3=%0.3f (expect ~0.375)",
                  $signed(input_k1)/8.0, $signed(input_k2)/8.0, $signed(a3_1)/8.0);

        // Pattern (0.5, 0.75)
        input_k1=4'sb0100; input_k2=4'sb0110;
        repeat(6) @(posedge clk);
        $display("k=(%0.3f,%0.3f) -> a3=%0.3f (expect ~0.375)",
                  $signed(input_k1)/8.0, $signed(input_k2)/8.0, $signed(a3_1)/8.0);

        // Pattern (0.5, 0.5)
        input_k1=4'sb0100; input_k2=4'sb0100;
        repeat(6) @(posedge clk);
        $display("k=(%0.3f,%0.3f) -> a3=%0.3f (expect ~0.375)",
                  $signed(input_k1)/8.0, $signed(input_k2)/8.0, $signed(a3_1)/8.0);

        $display("=== Done ===");
        $finish;
    end

    // Watchdog
    initial begin
        #2000000;
        $display("TIMEOUT");
        $finish;
    end
endmodule
