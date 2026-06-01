vlib work
vcom ../src/rtl/isa_pkg.vhd
vcom ../src/rtl/instr_reg.vhd
vcom ../src/rtl/status_reg.vhd
vcom ../src/rtl/register_file.vhd
vcom ../src/rtl/alu.vhd
vcom ../src/rtl/control_unit.vhd
vcom ../src/rtl/cpu_top.vhd
vcom ../tb/tb_alu.vhd
vcom ../tb/tb_register_file.vhd

vsim work.tb_alu
run -all

vsim work.tb_register_file
run -all
