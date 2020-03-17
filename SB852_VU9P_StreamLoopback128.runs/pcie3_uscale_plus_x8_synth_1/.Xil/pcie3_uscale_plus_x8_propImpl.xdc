set_property SRC_FILE_INFO {cfile:/home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/pcie3_uscale_plus_x8/ip_0/synth/pcie3_uscale_plus_x8_gt.xdc rfile:../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/pcie3_uscale_plus_x8/ip_0/synth/pcie3_uscale_plus_x8_gt.xdc id:1 order:EARLY scoped_inst:inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst} [current_design]
set_property SRC_FILE_INFO {cfile:/home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/pcie3_uscale_plus_x8/source/ip_pcie4_uscale_plus_x1y2.xdc rfile:../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/pcie3_uscale_plus_x8/source/ip_pcie4_uscale_plus_x1y2.xdc id:2 order:EARLY scoped_inst:inst} [current_design]
current_instance inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y28 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[31].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:77 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y29 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[31].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:97 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y30 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[31].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:117 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y31 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[31].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:137 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y32 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[32].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:157 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y33 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[32].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:177 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y34 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[32].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:197 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC GTYE4_CHANNEL_X1Y35 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[32].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]
set_property src_info {type:SCOPED_XDC file:1 line:213 export:INPUT save:INPUT read:READ} [current_design]
create_waiver -internal -quiet -user gtwizard_ultrascale -tags 1025417 -type METHODOLOGY -id TIMING-3 -description "added waiver for CPLL CAL local BUFG_GT usecase"  -scope -objects [get_pins -filter {REF_PIN_NAME=~*O} -of_objects [get_cells -hierarchical -filter {NAME =~ *gen_cpll_cal_inst[*].*bufg_gt_*xoutclkmon_inst}]]
current_instance
current_instance inst
set_property src_info {type:SCOPED_XDC file:2 line:117 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC PCIE40E4_X1Y2 [get_cells pcie_4_0_pipe_inst/pcie_4_0_e4_inst]
current_instance
set_property src_info {type:SCOPED_XDC file:2 line:127 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 1 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[2]}]]
set_property src_info {type:SCOPED_XDC file:2 line:128 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[1]}]]
set_property src_info {type:SCOPED_XDC file:2 line:129 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 1 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKSEL[0]}]]
set_property src_info {type:SCOPED_XDC file:2 line:132 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXRATE[0]}]]
set_property src_info {type:SCOPED_XDC file:2 line:133 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/RXRATE[0]}]]
set_property src_info {type:SCOPED_XDC file:2 line:134 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 1 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXRATE[1]}]]
set_property src_info {type:SCOPED_XDC file:2 line:135 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 1 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/RXRATE[1]}]]
set_property src_info {type:SCOPED_XDC file:2 line:136 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXRATE[2]}]]
set_property src_info {type:SCOPED_XDC file:2 line:137 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins [list {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]} {inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/pcie3_uscale_plus_x8_gt_i/inst/gen_gtwizard_gtye4_top.pcie3_uscale_plus_x8_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/RXRATE[2]}]]
current_instance inst
set_property src_info {type:SCOPED_XDC file:2 line:148 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins {gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/DIV[0]}]
set_property src_info {type:SCOPED_XDC file:2 line:149 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins {gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/DIV[1]}]
set_property src_info {type:SCOPED_XDC file:2 line:150 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins {gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/DIV[2]}]