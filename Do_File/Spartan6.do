vlib work
vlog Spartan6-DSP48A1.v reg_mux.v Spartan6_tb.v
vsim -voptargs=+acc work.DSP48A1_tb
add wave *
run -all
add wave -position insertpoint  \
sim:/DSP48A1_tb/dut/A_OUT \
sim:/DSP48A1_tb/dut/B_in \
sim:/DSP48A1_tb/dut/B_OUT \
sim:/DSP48A1_tb/dut/D_OUT \
sim:/DSP48A1_tb/dut/C_OUT \
sim:/DSP48A1_tb/dut/pre_out \
sim:/DSP48A1_tb/dut/mux_opmode4_out \
sim:/DSP48A1_tb/dut/OPMODE_OUT \
sim:/DSP48A1_tb/dut/ACOUT \
sim:/DSP48A1_tb/dut/multiplier_out \
sim:/DSP48A1_tb/dut/X_OUT \
sim:/DSP48A1_tb/dut/Z_OUT \
sim:/DSP48A1_tb/dut/carry_in_cascade_out \
sim:/DSP48A1_tb/dut/post_out \
sim:/DSP48A1_tb/dut/CIN \
sim:/DSP48A1_tb/dut/carry_out_post
restart -f
run -all