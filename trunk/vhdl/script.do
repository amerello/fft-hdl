vsim -t 10ns -voptargs=+acc work.user_logic;
add wave sim:/user_logic/bus2ip_clk;
add wave sim:/user_logic/fwd_inv_we;
add wave sim:/user_logic/rfd;
add wave sim:/user_logic/start;
add wave sim:/user_logic/fwd_inv;
add wave sim:/user_logic/dv;
add wave sim:/user_logic/unload;
add wave sim:/user_logic/done;
add wave sim:/user_logic/busy;
add wave sim:/user_logic/edone;
add wave -format Analog-Step -height 74 -max 127 -min -128.0 sim:/user_logic/xn_re;
add wave sim:/user_logic/xn_im;
add wave sim:/user_logic/xn_index;
add wave sim:/user_logic/xk_re;
add wave sim:/user_logic/xk_im;
add wave sim:/user_logic/xk_index;
add wave sim:/user_logic/p3;
add wave -format Analog-Step -radix unsigned -height 74 -max 166156 -min 0 sim:/user_logic/x_out;
add wave -radix unsigned sim:/user_logic/delay(27);
add wave -radix unsigned sim:/user_logic/datos_fin(2);
force -freeze sim:/user_logic/bus2ip_clk 1 0, 0 {10 ns} -r 20;
run 350000ns;
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {270700 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {213810 ns} {357170 ns}