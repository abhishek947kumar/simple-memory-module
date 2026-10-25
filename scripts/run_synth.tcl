# Vivado Synthesis Runner Script
set script_dir   [file normalize [file dirname [info script]]]
set project_file [file normalize [file join $script_dir ".." "vivado_proj" "simple_memory_module.xpr"]]
set reports_dir  [file normalize [file join $script_dir ".." "reports"]]

file mkdir $reports_dir

if {![file exists $project_file]} {
    puts "===> Project file not found. Creating project first..."
    source [file join $script_dir "create_project.tcl"]
} else {
    puts "===> Opening existing project: $project_file"
    open_project $project_file
}

puts "===> Setting top module for synthesis: single_port_ram"
set_property top single_port_ram [current_fileset]
update_compile_order -fileset sources_1

puts "===> Resetting previous synthesis runs if any..."
reset_run synth_1 -quiet

puts "===> Launching Synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

puts "===> Checking synthesis run status..."
set run_status [get_property STATUS [get_runs synth_1]]
puts "===> Synthesis Status: $run_status"

if {[string match "*Complete*" $run_status]} {
    puts "===> Opening synthesized design..."
    open_run synth_1 -name synth_1
    
    set util_rpt [file join $reports_dir "utilization_synth.rpt"]
    set time_rpt [file join $reports_dir "timing_synth.rpt"]
    
    puts "===> Generating Utilization Report: $util_rpt"
    report_utilization -file $util_rpt
    
    puts "===> Generating Timing Summary: $time_rpt"
    report_timing_summary -file $time_rpt
    
    puts "=================================================="
    puts "SYNTHESIS SUMMARY REPORT:"
    report_utilization
    puts "=================================================="
} else {
    puts "===> ERROR: Synthesis failed or did not complete as expected."
}

exit
