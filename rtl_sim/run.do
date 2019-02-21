vlib work
vlog +acc ../rtl/sync_fifo.sv
vlog +acc ./sync_fifo_tb.sv
vsim -t 10ps -lib  work sync_fifo_tb
view objects
view wave
do {wave.do}
log -r *
run -all
