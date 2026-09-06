# 4-bit 2-2-1 Backprop MLP — Verilog RTL
## Scaled from Kyushu/LSI-2018 NN_CORE for Virtuoso CDL flow

---

## Network
- Topology: 2 inputs → 2 hidden → 1 output
- Format: 4-bit signed Q1.3 (range -1.0 to +0.875, LSB=0.125)
- Based on: Kyushu University LSI-2018 contest reference design
- Training task: AND-like (k1=0.75,k2=0.75)→0.875 ; others→0

---

## File List

| File | Module | Function |
|---|---|---|
| nn_core4.v | nn_core4 | TOP: connects forward + backward + delays |
| forward4.v | forward4 | Forward pass (ROM→z2→sigmoid→z3→sigmoid) |
| backward4.v | backward4 | Backward pass (dadz→delta→dw→accumulate) |
| z2_4.v | z2_4 | 2-input MAC+saturate, 1-clock latency |
| mem4.v | mem4 | 16-entry sigmoid LUT (4-bit addr→4-bit out) |
| dadz4.v | dadz4 | Sigmoid derivative a*(1-a) |
| delta3_4.v | delta3_4 | Output error: (a3-t)*dadz3 |
| delta2_4.v | delta2_4 | Hidden error: (w3*delta3)*dadz2 |
| dw4.v | dw4 | Weight gradient: err*inp |
| dw_adder4.v | dw_adder4 | Gradient accumulate + sign update |
| db_adder4.v | db_adder4 | Bias gradient accumulate |
| w_reg4.v | w_reg4 | Weight register: reset/init/update |
| b_reg4.v | b_reg4 | Bias register: reset/init/update |
| delay1_4.v | delay1_4 | 1-clock pipeline register |
| counter4.v | counter4 | N=13 clk/sample, M=5000 epochs |
| selector4.v | selector4 | Generate enable_update pulse |
| gen_din_sel4.v | gen_din_sel4 | Generate din + select_initial |
| sel_k4.v | sel_k4 | MUX: ROM vs external input |
| k1_rom4.v | k1_rom4 | k1 training ROM [0.75,0.75,0.5,0.5] |
| k2_rom4.v | k2_rom4 | k2 training ROM [0.75,0.5,0.75,0.5] |
| t1_rom4.v | t1_rom4 | Target ROM [0.875,0,0,0] |
| nn_core4_tb.v | nn_core4_tb | Testbench: train + 4-pattern inference |

---

## Arithmetic Rules (Q1.3)

```
value = integer / 8
range: -1.0 (4'b1000) to +0.875 (4'b0111)

Multiply A*B → 8-bit product → extract [6:3] → Q1.3 result
Example: 0.5(4) × 0.75(6) = 24, 24>>3=3 = 0.375 ✓

Sigmoid LUT (16 entries, addr=4-bit used as unsigned 0..15):
addr 8→-1.0→0.25  addr 12→-0.5→0.375
addr 0→ 0.0→0.5   addr 4 → 0.5→0.625
addr 6→ 0.75→0.75 addr 7 → 0.875→0.75
```

---

## Initial Weights (Q1.3 integers)

```
Layer 2 (input→hidden):
  w2_11=0.125(1)  w2_21=0.375(3)   b2_1=-1.0(-8)
  w2_12=0.25(2)   w2_22=0.5(4)     b2_2=-1.0(-8)

Layer 3 (hidden→output):
  w3_11=0.625(5)  w3_21=0.875(7)   b3_1=-1.0(-8)
```

---

## Simulate

```bash
iverilog -o sim nn_core4_tb.v nn_core4.v forward4.v backward4.v \
  z2_4.v mem4.v dadz4.v delta3_4.v delta2_4.v dw4.v \
  dw_adder4.v db_adder4.v delay1_4.v w_reg4.v b_reg4.v \
  k1_rom4.v k2_rom4.v t1_rom4.v sel_k4.v counter4.v \
  selector4.v gen_din_sel4.v
vvp sim
```

---

## ⚠ 4-bit Backprop Limitation

Q1.3 gradient chain rounds to zero:
```
delta3 = (a3-t) × dadz ≈ 0.5 × 0.125 = 0.0625 → rounds to 0 (< 1 LSB)
```
Three multiplied Q1.3 values always produce < 1 LSB → no weight update.

**Industry-correct approach** (used by SISLAB paper, LSI 2018):
1. Train in MATLAB with float32 precision
2. Quantize trained weights to 4-bit Q1.3
3. Load into hardware weight ROMs
4. Hardware does FORWARD PASS only at inference time

The architecture is correct — forward pass verified working.

---

## CDL Flow → Virtuoso

```
Step 1: Genus synthesis
  read_libs gpdk090_slow.lib
  read_hdl {all .v files}
  elaborate nn_core4
  syn_generic; syn_map
  write_hdl -format spice > nn_core4.cdl

Step 2: Virtuoso Spice In
  File → Import → CDL → nn_core4.cdl
  Library = stdcel (gpdk090)

Step 3: Layout XL
  Connectivity → Generate → All From Source

Step 4: Assura DRC/LVS
```

---

## Pipeline Timing

```
Clock 0:  ROM read (k, t)
Clock 1:  z2 computed (MAC: k×w+b, saturated)
Clock 2:  a2 = sigmoid(z2) via LUT
Clock 3:  z3 computed (MAC: a2×w3+b3)
Clock 4:  a3 = sigmoid(z3) — OUTPUT VALID
Clocks 5+: backward pipeline (delta→dw→accumulate)
Clock 12: weight update (selector fires at N-1=12)
Clock 13: next sample begins
```
