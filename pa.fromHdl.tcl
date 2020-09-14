
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name SEG7_Display -dir "/home/daniel/Xilinx/SEG7_Display/planAhead_run_4" -part xc3s50atq144-4
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "DisplayNumber.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {DisplayNumber.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top DisplayNumber $srcset
add_files [list {DisplayNumber.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s50atq144-4
