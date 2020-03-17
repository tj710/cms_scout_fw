# generated system PicoBus clock
create_generated_clock -name sys_picoclk -divide_by 60 -source [get_pins PicoFramework/app/FrameworkPicoBus/s2pb/clk_gen/clk_reg_reg/C] [get_pins PicoFramework/app/FrameworkPicoBus/s2pb/clk_gen/inst/O]
#set_clock_groups -async -group [get_clocks sys_picoclk]

# sys_picobus <-> system clock Async Crossings
set meta1_reg [list [get_cells -quiet -hier -filter {NAME =~ */meta1_reg}] \
                    [get_cells -quiet -hier -filter {NAME =~ */meta1_reg[*]}]]

set async_clk_grp [list [get_clocks sys_picoclk]]

if {[llength [get_clocks -quiet user_clk]]>0} {
   set async_clk_grp [concat $async_clk_grp [list [get_clocks user_clk]]]
}

if {[llength [get_clocks -quiet s_clk]]>0} {
   set async_clk_grp [concat $async_clk_grp [list [get_clocks s_clk]]]
}

if {[llength [get_clocks -quiet  txoutclk_out[3]]]>0} {
   set async_clk_grp [concat $async_clk_grp [list [get_clocks  txoutclk_out[3]]]]
}

if {[llength [get_clocks -quiet *TXOUTCLK]]>0} {
   set async_clk_grp [concat $async_clk_grp [list [get_clocks *TXOUTCLK]]]
}


set_max_delay 4.0 -from $async_clk_grp -to $meta1_reg -datapath_only
set_false_path -quiet -from $async_clk_grp -to $meta1_reg -hold

# generated user PicoBus clock
# we divide a 250 MHz stream clock by a factor of 62 down to approximately 4 MHz
if {[llength [get_pins -quiet UserWrapper/UserModule_s2pb/s2pb/clk_gen/clk_reg_reg/C]]>0} {
    create_generated_clock -name usr_picoclk -divide_by 60 -source [get_pins UserWrapper/UserModule_s2pb/s2pb/clk_gen/clk_reg_reg/C] [get_pins UserWrapper/UserModule_s2pb/s2pb/clk_gen/inst/O]
    set_clock_groups -async -group [get_clocks usr_picoclk]
}

# generated StreamToFlashCtl clock
# Divide the 250 MHz stream clock by 2 down to 125 MHz
if {[llength [get_pins -quiet UserWrapper/StreamToFlashCtl/clk_gen/clk_reg_reg/C]]>0} {
    create_generated_clock -name StreamToFlashCtl_clk -divide_by 2 -source [get_pins UserWrapper/StreamToFlashCtl/clk_gen/clk_reg_reg/C] [get_pins UserWrapper/StreamToFlashCtl/clk_gen/inst/O]
    set_clock_groups -async -group [get_clocks StreamToFlashCtl_clk]
}

