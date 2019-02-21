onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sync_fifo_tb/DUT/clk
add wave -noupdate /sync_fifo_tb/DUT/rst_n
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/data_in
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/rd_pointer
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/wr_pointer
add wave -noupdate /sync_fifo_tb/DUT/rd_en
add wave -noupdate /sync_fifo_tb/DUT/wr_en
add wave -noupdate /sync_fifo_tb/DUT/empty
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/ram_q
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/data_out
add wave -noupdate /sync_fifo_tb/DUT/full
add wave -noupdate /sync_fifo_tb/DUT/afull
add wave -noupdate /sync_fifo_tb/DUT/aempty
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/uw
add wave -noupdate /sync_fifo_tb/DUT/sclr
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/word_cnt
add wave -noupdate /sync_fifo_tb/DUT/genblk2/use_buffer
add wave -noupdate -radix unsigned /sync_fifo_tb/DUT/genblk2/word_buffer
add wave -noupdate /sync_fifo_tb/DUT/genblk2/use_buffer_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2014410 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 262
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1904050 ps} {3017560 ps}
