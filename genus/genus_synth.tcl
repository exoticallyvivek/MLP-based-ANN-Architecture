#==============================================================
# genus_synth.tcl — Synthesis script for nn_core4 (4-bit 2-2-1 MLP)
# Target: gpdk090 standard cell library
# Run: genus -legacy_ui -f genus_synth.tcl
#==============================================================

# ---- 1. Paths (EDIT THESE for your server) ----
set LIB_PATH   "/cad/gpdk090/lib"
set RTL_PATH   "."
set OUT_PATH   "./output"
file mkdir $OUT_PATH
file mkdir ./reports

# ---- 2. Load Liberty library ----
set_db init_lib_search_path $LIB_PATH
read_libs {
    gpdk090_slow.lib
}
# If gpdk090_slow.lib not found, try alternatives:
# gpdk090tt_1.0V_25C.lib  OR  gpdk090.lib

# ---- 3. Read RTL (all files except testbench) ----
set_db init_hdl_search_path $RTL_PATH
read_hdl -language v [list \
    $RTL_PATH/gen_din_sel4.v   \
    $RTL_PATH/counter4.v       \
    $RTL_PATH/selector4.v      \
    $RTL_PATH/sel_k4.v         \
    $RTL_PATH/delay1_4.v       \
    $RTL_PATH/w_reg4.v         \
    $RTL_PATH/b_reg4.v         \
    $RTL_PATH/k1_rom4.v        \
    $RTL_PATH/k2_rom4.v        \
    $RTL_PATH/t1_rom4.v        \
    $RTL_PATH/z2_4.v           \
    $RTL_PATH/dadz4.v          \
    $RTL_PATH/delta3_4.v       \
    $RTL_PATH/delta2_4.v       \
    $RTL_PATH/dw4.v            \
    $RTL_PATH/dw_adder4.v      \
    $RTL_PATH/db_adder4.v      \
    $RTL_PATH/mem4.v           \
    $RTL_PATH/forward4.v       \
    $RTL_PATH/backward4.v      \
    $RTL_PATH/nn_core4.v       \
]

# ---- 4. Elaborate top ----
elaborate nn_core4

# ---- 5. Mark mem4 as black box (do not synthesize internals) ----
# mem4 has empty body — Genus auto-detects as black box
# Confirm with:
set_attribute [get_designs mem4] -name avoid_feedback -value true

# ---- 6. Timing constraints ----
create_clock [get_ports clk] -name clk -period 10.0
# 10ns = 100MHz. Relax to 20ns (50MHz) if timing fails:
# create_clock [get_ports clk] -name clk -period 20.0

set_input_delay  2.0 -clock clk [all_inputs]
set_output_delay 2.0 -clock clk [all_outputs]

# ---- 7. Synthesis ----
syn_generic
syn_map
syn_opt

# ---- 8. Reports ----
report_timing  > ./reports/timing.rpt
report_area    > ./reports/area.rpt
report_power   > ./reports/power.rpt
report_qor     > ./reports/qor.rpt

puts "\n=== Area Summary ==="
report_area

puts "\n=== Timing Summary ==="
report_timing -nworst 5

# ---- 9. Write outputs ----
# Gate-level Verilog netlist
write_hdl > $OUT_PATH/nn_core4_netlist.v

# SPICE/CDL for Virtuoso import
write_hdl -format spice > $OUT_PATH/nn_core4.cdl

# SDC constraints (for later OpenLane/ICC)
write_sdc > $OUT_PATH/nn_core4.sdc

puts "\n=== DONE ==="
puts "Netlist : $OUT_PATH/nn_core4_netlist.v"
puts "CDL     : $OUT_PATH/nn_core4.cdl"
puts "SDC     : $OUT_PATH/nn_core4.sdc"
