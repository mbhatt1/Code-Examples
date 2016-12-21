onerror {quit -f}
vlib work
vlog -work work cpu.vo
vlog -work work cpu.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.cpu_vlg_vec_tst
vcd file -direction cpu.msim.vcd
vcd add -internal cpu_vlg_vec_tst/*
vcd add -internal cpu_vlg_vec_tst/i1/*
add wave /*
run -all
