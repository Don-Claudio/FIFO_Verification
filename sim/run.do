vlib work

vlog ../rtl/sync_fifo.sv
vlog ../tb/fifo_if.sv
vlog ../tb/fifo_pkg.sv
vlog ../tb/fifo_tb_top.sv

vsim -c work.fifo_tb_top -do "run -all; quit"