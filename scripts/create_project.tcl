# Vivado Project Creation Script
# Simple Memory Module Project

set project_name "simple_memory_module"
set project_dir  [file normalize [file join [file dirname [info script]] ".." "vivado_proj"]]
set rtl_dir      [file normalize [file join [file dirname [info script]] ".." "rtl"]]
set tb_dir       [file normalize [file join [file dirname [info script]] ".." "tb"]]
set target_part  "xc7a35tcpg236-1"

puts "===> Creating Vivado Project: $project_name in $project_dir"
create_project $project_name $project_dir -part $target_part -force

# Configure project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# Add RTL Design Sources
puts "===> Adding RTL Sources..."
add_files -fileset sources_1 [glob [file join $rtl_dir "*.v"]]

# Add Simulation Testbenches
puts "===> Adding Simulation Sources..."
add_files -fileset sim_1 [glob [file join $tb_dir "*.v"]]

# Set Single-Port RAM as default top
set_property top single_port_ram [current_fileset]
set_property top tb_single_port_ram [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Update Compile Order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "===> Vivado Project successfully created and configured!"
