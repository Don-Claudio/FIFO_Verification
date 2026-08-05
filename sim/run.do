vlib work

vlog -cover bcst ../rtl/sync_fifo.sv
vlog -cover bcst ../tb/fifo_if.sv
vlog -cover bcst ../tb/fifo_pkg.sv
vlog -cover bcst ../tb/fifo_tb_top.sv

vsim -c -coverage work.fifo_tb_top -do "run -all; coverage report -cvg -details; quit"