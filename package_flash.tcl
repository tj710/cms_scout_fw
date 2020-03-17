set flash_if   SPIx4
set flash_fmt    BIN
set flash_size   128
set board_id   0x852
# package-flash.tcl

set option 0

# for internal use only. does not do a full check on input argument
if { $argc < 1 } {
    set option 0
} elseif {[lindex $argv 0] == "build_all"} {
    set option 2
} elseif {[lindex $argv 0] == "project_only"} {
    set option 1
}

if { $option == 1 } {
    puts [pwd]
    set tclpath [pwd]/$::env(PROJECT_NAME)/
    cd $::env(PROJECT_NAME)
    open_project $::env(PROJECT_NAME).xpr
    set_property STEPS.WRITE_BITSTREAM.TCL.POST $tclpath/package_flash.tcl [get_runs impl_1]
    cd ..

} else {

    # change directory if in non-project mode
    if { $option == 2} {
        cd $::env(PROJECT_NAME)
    }
    puts "Package flash in [pwd]"
    set current_dir [pwd]
    set bitfile [exec find . -name "*.bit"]
    set tgzfile [file tail [file rootname $bitfile]]

#     if {[file exists ./Pico_Toplevel.bit]} {
#         set bitfile ./Pico_Toplevel.bit
#         set tgz_file Pico_Toplevel
#     } elseif {[file exists [file tail $current_dir].bit]} {
#         set bitfile [file tail $current_dir].bit
#         set tgz_file [file tail $current_dir]
#     } elseif {[file exists [file tail $current_dir].runs/impl_1/Pico_Toplevel.bit]} {
#         set bitfile [file tail $current_dir].runs/impl_1/Pico_Toplevel.bit
#         set tgz_file Pico_Toplevel
#     } else {
#         puts "Cannot find valid bit file"
#     }

    
    write_cfgmem -force -format $flash_fmt -size $flash_size -interface $flash_if -loadbit "up 0x0 $bitfile" pico.bin
    
    exec echo $board_id > device_id
    exec tar cfz $tgzfile.tgz device_id pico.bin
    exec rm -rf device_id pico.bin pico.prm
    exec cp $tgzfile.tgz ../

}



