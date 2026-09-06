set DESIGN_NAME nn_core4
set_db lib_search_path {/home/install/FOUNDRY/digital/90nm/dig/lib}
set_db init_hdl_search_path ./
set_db library {slow.lib fast.lib}
set_db auto_ungroup none

# Define MMMC library sets and delay corners
create_library_set -name slow_lib -timing {slow.lib}
create_library_set -name fast_lib -timing {fast.lib}
create_timing_condition -name slow_tc -library_sets {slow_lib}
create_timing_condition -name fast_tc -library_sets {fast_lib}
create_delay_corner -name slow_corner -timing_condition slow_tc
create_delay_corner -name fast_corner -timing_condition fast_tc

# Read RTL source files
read_hdl -language v2001 {
    gen_din_sel4.v counter4.v selector4.v sel_k4.v delay1_4.v
    w_reg4.v b_reg4.v k1_rom4.v k2_rom4.v t1_rom4.v
    z2_4.v dadz4.v delta3_4.v delta2_4.v dw4.v
    dw_adder4.v db_adder4.v mem4.v forward4.v backward4.v nn_core4.v
}

# Elaborate top-level design
elaborate $DESIGN_NAME
check_design -unresolved
check_design -multiple_driver

# Create constraint modes and analysis views
create_constraint_mode -name func_mode -sdc_files {nn_core4.sdc}
create_analysis_view -name setup_view \
    -constraint_mode func_mode \
    -delay_corner slow_corner
create_analysis_view -name hold_view \
    -constraint_mode func_mode \
    -delay_corner fast_corner
set_analysis_view -setup {setup_view} -hold {hold_view}

# Initialize timing and load constraints
init_design

# =======================================================================
# FOOLPROOF CELL WHITELISTING (2-Input, X1 Drive Strength Only)
# =======================================================================

# 1. Disable EVERYTHING in the libraries first
set_db [get_db lib_cells *] .dont_use true

# 2. Re-enable ONLY our specific 8 target cells
set_db [get_db lib_cells *INVX1] .dont_use false
set_db [get_db lib_cells *NAND2X1] .dont_use false
set_db [get_db lib_cells *NOR2X1] .dont_use false
set_db [get_db lib_cells *AND2X1] .dont_use false
set_db [get_db lib_cells *OR2X1] .dont_use false
set_db [get_db lib_cells *XOR2X1] .dont_use false
set_db [get_db lib_cells *MX2X1] .dont_use false
set_db [get_db lib_cells *DFFQX1] .dont_use false

# 3. Enable Tie cells if your design requires logic 0/1 constants
# (Uncomment the lines below if synthesis fails complaining about missing tie cells)
# set_db [get_db lib_cells *TIEHI*] .dont_use false
# set_db [get_db lib_cells *TIELO*] .dont_use false

# =======================================================================

# Optimization Effort Settings
set_db syn_global_effort high
set_db syn_generic_effort high
set_db syn_map_effort    high

# Enable interactive constraint mode for global SDC attributes
set_interactive_constraint_modes {func_mode}
set_max_fanout    20 [current_design]
set_max_transition 0.3 [current_design]

# Run Synthesis
redirect compile.log { syn_gen; syn_map; syn_opt }

# Export design database
write_db ${DESIGN_NAME}_post_syn.db

# Generate Analysis Reports
report_qor                 > ${DESIGN_NAME}_qor.rep
report_timing -max_paths 10   > ${DESIGN_NAME}_timing.rep
report_area                   > ${DESIGN_NAME}_area.rep
report_power                  > ${DESIGN_NAME}_power.rep
report_gates                  > ${DESIGN_NAME}_gates.rep

# Write output netlists and constraints
write_hdl                   > ${DESIGN_NAME}_netlist.v
write_hdl -generic         > ${DESIGN_NAME}.cdl
write_sdc -view setup_view > ${DESIGN_NAME}_out.sdc

puts "DONE"
