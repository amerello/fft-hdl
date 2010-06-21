onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /user_logic/bus2ip_clk
add wave -noupdate -format Logic /user_logic/fwd_inv_we
add wave -noupdate -format Logic /user_logic/rfd
add wave -noupdate -format Logic /user_logic/start
add wave -noupdate -format Logic /user_logic/fwd_inv
add wave -noupdate -format Logic /user_logic/dv
add wave -noupdate -format Logic /user_logic/unload
add wave -noupdate -format Logic /user_logic/done
add wave -noupdate -format Logic /user_logic/busy
add wave -noupdate -format Logic /user_logic/edone
add wave -noupdate -format Analog-Step -height 74 -max 126.99999999999997 -min -128.0 /user_logic/xn_re
add wave -noupdate -format Literal /user_logic/xn_im
add wave -noupdate -format Literal /user_logic/xn_index
add wave -noupdate -format Literal /user_logic/xk_re
add wave -noupdate -format Literal /user_logic/xk_im
add wave -noupdate -format Literal /user_logic/xk_index
add wave -noupdate -format Literal /user_logic/p3
add wave -noupdate -format Analog-Step -height 74 -max 21323.0 /user_logic/x_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {84 us}
