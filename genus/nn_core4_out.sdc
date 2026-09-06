# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Thu Jun 11 14:22:34 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design nn_core4

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_false_path -from [get_ports res]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports res]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports update_coeff]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k1[3]}]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k1[2]}]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k1[1]}]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k1[0]}]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k2[3]}]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k2[2]}]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k2[1]}]
set_input_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {input_k2[0]}]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports finish_updating]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {a3_1[3]}]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {a3_1[2]}]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {a3_1[1]}]
set_output_delay -clock [get_clocks clk] -add_delay 2.0 [get_ports {a3_1[0]}]
set_max_fanout 20.000 [current_design]
set_max_transition 0.3 [current_design]
set_wire_load_mode "enclosed"
