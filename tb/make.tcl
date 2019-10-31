vlib work
vlog -sv -f ./files
vopt +acc tb_sorting_network -o tb_sorting_network_opt
vsim tb_sorting_network_opt
#do wave.do
run -all
