

set_multi_cpu_usage -remote_host 8 -local_cpu 8
read_db dbs/syn_opt.db/

create_net -physical -name VPWR -power
create_net -physical -name VGND -ground

# Enable OCV (On Chip Variation)
# This takes into account process variation
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both

# Don't allow the tool to route on the two topmost metal layers
set_db design_top_routing_layer met4
set_db design_bottom_routing_layer met1

# shoot for 50% utilization
create_floorplan -stdcell_density_size {1.0 0.8 2 2 2 2}

# Ensure power pins are connected to power nets
connect_global_net VPWR -type pg_pin -pin_base_name VPWR -all
connect_global_net VPWR -type net -net_base_name VPWR -all
connect_global_net VPWR -type pg_pin -pin_base_name VPB -all
connect_global_net VGND -type pg_pin -pin_base_name VGND -all
connect_global_net VGND -type net -net_base_name VGND -all
connect_global_net VGND -type pg_pin -pin_base_name VNB -all

add_tracks

add_stripes -nets {VPWR VGND} -layer met5 -direction horizontal -width 12.1 -spacing 12.1 -number_of_sets 3 -extend_to design_boundary -create_pins 1 -start_from left -start_offset 12 -stop_offset 12 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit rdl -pad_core_ring_bottom_layer_limit li1 -block_ring_top_layer_limit rdl -block_ring_bottom_layer_limit li1 -use_wire_group 0 -snap_wire_center_to_grid none


add_stripes -nets {VPWR VGND} -layer met4 -direction vertical -width 12.1 -spacing 12.1 -number_of_sets 3 -extend_to design_boundary -create_pins 1 -start_from left -start_offset 12 -stop_offset 12 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit rdl -pad_core_ring_bottom_layer_limit li1 -block_ring_top_layer_limit rdl -block_ring_bottom_layer_limit li1 -use_wire_group 0 -snap_wire_center_to_grid none

route_special -connect core_pin \
   -block_pin_target nearest_target \
   -core_pin_target first_after_row_end \
   -allow_jogging 1 \
   -nets {VPWR VGND} \
   -allow_layer_change 1

add_well_taps -cell sky130_fd_sc_ms__tapvpwrvgnd_1 -cell_interval 50

write_db -common dbs/pnr_init.db

set_db place_global_place_io_pins true

place_opt_design
add_tieoffs
write_db -common dbs/place.db

clock_opt_design
write_db -common dbs/ccopt.db

route_opt_design
time_design -post_route
time_design -post_route -hold
opt_design -post_route
write_db -common dbs/route.db


extract_rc
opt_signoff -all -report_dir timing_report

add_fillers -base_cells { sky130_fd_sc_ms__fill_8 sky130_fd_sc_ms__fill_4 sky130_fd_sc_ms__fill_2 sky130_fd_sc_ms__fill_1 }

#Fix Pin DRC issues
#https://support.cadence.com/apex/ArticleAttachmentPortal?id=a1O0V000006AlgfUAC&pageName=ArticleContent
#https://support.cadence.com/apex/techpubDocViewerPage?xmlName=tcrcom.xml&title=Innovus%20Stylus%20Common%20UI%20Text%20Command%20Reference%20--%20create_shape%20-%20create_shape&hash=&c_version=25.11&path=TCRcom/TCRcom25.11/create_shape.html

#foreach port [get_db ports clk] {
foreach port [get_db ports] {
  puts "Pin: [get_db $port .name] ([get_db $port .direction])"
  foreach pin [get_db $port .physical_pins] {
    foreach layer_shape [get_db $pin .layer_shapes] {
      puts "  Layer: [get_db $layer_shape .layer.name] - Rects: [get_db $layer_shape .shapes.rect]"

      create_shape \
        -layer [get_db $layer_shape .layer.name] \
        -patch [get_db $layer_shape .shapes.rect] \
        -net [get_db $port .name] \
        -status routed 
    }
  }
}

write_db -common dbs/signoff.db

write_netlist -include_pg -omit_floating_ports -update_tie_connections post_pnr_lvs.vg
write_netlist -remove_power_ground post_pnr_sim.vg

# Extract LEF and LIB files for abstraction
set_analysis_view -setup {ss_150_view tt_25_view ff_m40_view ff_150_view ss_m40_view} -hold {ss_150_view tt_25_view ff_m40_view ff_150_view ss_m40_view}

write_timing_model -view ss_m40_view sram_ss_m40.lib
write_timing_model -view ss_150_view sram_ss_150.lib
write_timing_model -view tt_25_view sram_tt_25.lib
write_timing_model -view ff_m40_view sram_ff_m40.lib
write_timing_model -view ff_150_view sram_ff_150.lib

write_lef_abstract sram.lef

# Write out DRC reports
check_drc -out_file drc.rpt
check_connectivity -out_file connect.rpt -ignore_dangling_wires

set DESIGN_NAME [get_db current_design .name]
set PDK_DIR /l/sky130_release_0.1.0
set STDCELL_DIR /l/skywater-pdk/libraries/sky130_fd_sc_ms/latest/cells/

set STDCELL_GDS [glob -nocomplain -type f $STDCELL_DIR/**/*.gds]
write_stream ${DESIGN_NAME}.gds.gz \
    -map_file ./sky130_stream.mapFile \
    -lib_name DesignLib \
    -merge $STDCELL_GDS \
    -unit 1000 -mode all
