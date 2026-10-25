# Vivado Simulation Runner Script
set script_dir   [file normalize [file dirname [info script]]]
set project_file [file normalize [file join $script_dir ".." "vivado_proj" "simple_memory_module.xpr"]]

if {![file exists $project_file]} {
    puts "===> Project file not found. Creating project first..."
    source [file join $script_dir "create_project.tcl"]
} else {
    puts "===> Opening existing project: $project_file"
    open_project $project_file
}

puts "===> Setting up Behavioral Simulation for tb_single_port_ram..."
set_property top tb_single_port_ram [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

puts "===> Launching Behavioral Simulation..."
launch_simulation

puts "===> Behavioral Simulation completed successfully."
close_sim
exit
