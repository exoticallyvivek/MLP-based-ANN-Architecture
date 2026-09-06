#!/bin/bash
#==============================================================
# incisive_sim.sh — RTL simulation with Cadence Incisive (irun)
# Run: bash incisive_sim.sh
# Output: waves in simvision, console log in sim.log
#==============================================================

irun \
  +define+SIMULATION \
  -timescale 1ns/1ps \
  -access +rwc \
  -input sim_commands.tcl \
  nn_core4_tb.v \
  nn_core4.v \
  forward4.v \
  backward4.v \
  z2_4.v \
  mem4.v \
  dadz4.v \
  delta3_4.v \
  delta2_4.v \
  dw4.v \
  dw_adder4.v \
  db_adder4.v \
  delay1_4.v \
  w_reg4.v \
  b_reg4.v \
  k1_rom4.v \
  k2_rom4.v \
  t1_rom4.v \
  sel_k4.v \
  counter4.v \
  selector4.v \
  gen_din_sel4.v \
  -top nn_core4_tb \
  2>&1 | tee sim.log
