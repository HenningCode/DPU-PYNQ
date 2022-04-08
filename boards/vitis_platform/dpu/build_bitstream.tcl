set overlay_name "dpu"

# open block design
open_project ./${overlay_name}/${overlay_name}.xpr
open_bd_design ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${overlay_name}/${overlay_name}.bd

# add top wrapper
make_wrapper -files [get_files ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${overlay_name}/${overlay_name}.bd] -top
add_files -norecurse ./${overlay_name}/${overlay_name}.srcs/sources_1/bd/${overlay_name}/hdl/${overlay_name}_wrapper.v
set_property top ${overlay_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1


# set platform properties
set_property platform.default_output_type "sd_card" [current_project]
set_property platform.design_intent.embedded "true" [current_project]
set_property platform.design_intent.server_managed "false" [current_project]
set_property platform.design_intent.external_host "false" [current_project]
set_property platform.design_intent.datacenter "false" [current_project]


launch_runs synth_1 -jobs 12
wait_on_run synth_1

open_run synth_1 -name synth_1

# create trigger xdc
set_property IOSTANDARD LVCMOS33 [get_ports [list {LED[1]}]]
set_property IOSTANDARD LVCMOS33 [get_ports [list {LED[0]}]]
place_ports {LED[1]} D5
place_ports {LED[0]} G8
file mkdir ./${overlay_name}/${overlay_name}.srcs/constrs_1/new
close [ open ./${overlay_name}/${overlay_name}.srcs/constrs_1/new/trigger.xdc w ]
add_files -fileset constrs_1 ./${overlay_name}/${overlay_name}.srcs/constrs_1/new/trigger.xdc
set_property target_constrs_file ./${overlay_name}/${overlay_name}.srcs/constrs_1/new/trigger.xdc [current_fileset -constrset]
save_constraints -force

close_design

# call implement
launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1
puts "Finisched impl_1"

# generate xsa
write_hw_platform -force ./${overlay_name}.xsa
validate_hw_platform ./${overlay_name}.xsa

# move and rename bitstream to final location
file copy -force ./${overlay_name}/${overlay_name}.runs/impl_1/${overlay_name}_wrapper.bit ${overlay_name}.bit

# copy hwh files
file copy -force ./${overlay_name}/${overlay_name}.gen/sources_1/bd/${overlay_name}/hw_handoff/${overlay_name}.hwh ${overlay_name}.hwh
