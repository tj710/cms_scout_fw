# 
# Report generation script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}


start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param chipscope.maxJobs 16
  create_project -in_memory -part xcvu9p-flgb2104-2L-e
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.cache/wt [current_project]
  set_property parent.project_path /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.xpr [current_project]
  set_property ip_output_repo /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
  add_files -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.runs/synth_1/Pico_Toplevel.dcp
  read_ip -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0_vio_0/gtwizard_ultrascale_0_vio_0.xci
  read_ip -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/pcie3_uscale_plus_x8/pcie3_uscale_plus_x8.xci
  read_ip -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0/gtwizard_ultrascale_0.xci
  read_ip -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0.xci
  read_ip -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/aligner_fifo/aligner_fifo.xci
  read_ip -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/fifo_generator_1/fifo_generator_1.xci
  read_ip -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/fifo_generator_2/fifo_generator_2.xci
  add_files -quiet /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/imports/gtwizard_ultrascale_0/gtwizard_ultrascale_0.dcp
  read_xdc /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/constrs_1/imports/src/SB852_VU9P_FLVB2104_E.xdc
  read_xdc -unmanaged /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/constrs_1/imports/src/clocks.tcl
  read_xdc /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/constrs_1/imports/gtwizard_ultrascale_0_ex/imports/gtwizard_ultrascale_0_example_top.xdc
  read_xdc /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/constrs_1/imports/gtwizard_ultrascale_0_ex/gtwizard_ultrascale_0_ex.srcs/sources_1/ip/gtwizard_ultrascale_0/synth/gtwizard_ultrascale_0.xdc
  read_xdc /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/constrs_1/imports/gtwizard_ultrascale_0_ex/gtwizard_ultrascale_0_ex.srcs/sources_1/ip/gtwizard_ultrascale_0/synth/gtwizard_ultrascale_0_ooc.xdc
  link_design -top Pico_Toplevel -part xcvu9p-flgb2104-2L-e
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force Pico_Toplevel_opt.dcp
  create_report "impl_1_opt_report_drc_0" "report_drc -file Pico_Toplevel_drc_opted.rpt -pb Pico_Toplevel_drc_opted.pb -rpx Pico_Toplevel_drc_opted.rpx"
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  if { [llength [get_debug_cores -quiet] ] > 0 }  { 
    implement_debug_core 
  } 
  place_design 
  write_checkpoint -force Pico_Toplevel_placed.dcp
  create_report "impl_1_place_report_io_0" "report_io -file Pico_Toplevel_io_placed.rpt"
  create_report "impl_1_place_report_utilization_0" "report_utilization -file Pico_Toplevel_utilization_placed.rpt -pb Pico_Toplevel_utilization_placed.pb"
  create_report "impl_1_place_report_control_sets_0" "report_control_sets -verbose -file Pico_Toplevel_control_sets_placed.rpt"
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step phys_opt_design
set ACTIVE_STEP phys_opt_design
set rc [catch {
  create_msg_db phys_opt_design.pb
  phys_opt_design 
  write_checkpoint -force Pico_Toplevel_physopt.dcp
  close_msg_db -file phys_opt_design.pb
} RESULT]
if {$rc} {
  step_failed phys_opt_design
  return -code error $RESULT
} else {
  end_step phys_opt_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force Pico_Toplevel_routed.dcp
  create_report "impl_1_route_report_drc_0" "report_drc -file Pico_Toplevel_drc_routed.rpt -pb Pico_Toplevel_drc_routed.pb -rpx Pico_Toplevel_drc_routed.rpx"
  create_report "impl_1_route_report_methodology_0" "report_methodology -file Pico_Toplevel_methodology_drc_routed.rpt -pb Pico_Toplevel_methodology_drc_routed.pb -rpx Pico_Toplevel_methodology_drc_routed.rpx"
  create_report "impl_1_route_report_power_0" "report_power -file Pico_Toplevel_power_routed.rpt -pb Pico_Toplevel_power_summary_routed.pb -rpx Pico_Toplevel_power_routed.rpx"
  create_report "impl_1_route_report_route_status_0" "report_route_status -file Pico_Toplevel_route_status.rpt -pb Pico_Toplevel_route_status.pb"
  create_report "impl_1_route_report_timing_summary_0" "report_timing_summary -max_paths 10 -file Pico_Toplevel_timing_summary_routed.rpt -pb Pico_Toplevel_timing_summary_routed.pb -rpx Pico_Toplevel_timing_summary_routed.rpx -warn_on_violation "
  create_report "impl_1_route_report_incremental_reuse_0" "report_incremental_reuse -file Pico_Toplevel_incremental_reuse_routed.rpt"
  create_report "impl_1_route_report_clock_utilization_0" "report_clock_utilization -file Pico_Toplevel_clock_utilization_routed.rpt"
  create_report "impl_1_route_report_bus_skew_0" "report_bus_skew -warn_on_violation -file Pico_Toplevel_bus_skew_routed.rpt -pb Pico_Toplevel_bus_skew_routed.pb -rpx Pico_Toplevel_bus_skew_routed.rpx"
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force Pico_Toplevel_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}

start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
  catch { write_mem_info -force Pico_Toplevel.mmi }
  write_bitstream -force Pico_Toplevel.bit 
  set src_rc [catch { 
    puts "source /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/package_flash.tcl"
    source /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/package_flash.tcl
  } _RESULT] 
  if {$src_rc} { 
    send_msg_id runtcl-1 error "$_RESULT"
    send_msg_id runtcl-2 error "sourcing script /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/package_flash.tcl failed"
    return -code error
  }
  catch {write_debug_probes -quiet -force Pico_Toplevel}
  catch {file copy -force Pico_Toplevel.ltx debug_nets.ltx}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}
