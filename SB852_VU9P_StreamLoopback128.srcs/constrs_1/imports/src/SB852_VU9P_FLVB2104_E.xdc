###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -period 10.000 -name sys_clk [get_ports sys_clk_p]
set_false_path -from [get_ports sys_reset_n]

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -period 5.000 -name extra_clk [get_ports extra_clk_p]

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
set_property PACKAGE_PIN AB11 [get_ports extra_clk_p]
set_property PACKAGE_PIN AB10 [get_ports extra_clk_n]

###############################################################################
# User Physical Constraints
###############################################################################

#Pblock for PicoFramework
create_pblock pblock_PicoFramework
add_cells_to_pblock [get_pblocks pblock_PicoFramework] [get_cells -quiet [list PicoFramework]]
resize_pblock [get_pblocks pblock_PicoFramework] -add CLOCKREGION_X3Y5:CLOCKREGION_X5Y9

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
##### SYS RESET###########
set_property LOC PCIE40E4_X1Y2 [get_cells PicoFramework/core/pcie3_uscale_plus_x8/inst/pcie_4_0_pipe_inst/pcie_4_0_e4_inst] 
set_property PACKAGE_PIN AR26 [get_ports sys_reset_n]
#set_property PULLUP true [get_ports sys_reset_n]
set_property IOSTANDARD LVCMOS12 [get_ports sys_reset_n]

##### REFCLK_IBUF###########
# set_property PACKAGE_PIN_NAME MGTREFCLK1P_225 [get_ports sys_clk_p]
set_property PACKAGE_PIN AP11 [get_ports sys_clk_p]
#set_property PACKAGE_PIN_NAME MGTREFCLK1N_225 [get_ports sys_clk_n]
set_property PACKAGE_PIN AP10 [get_ports sys_clk_n]

##### PCIE X16 #############
#set_property PACKAGE_PIN_NAME MGTYRXP2_224 [get_ports {pci_exp_rxp[13]}]
set_property PACKAGE_PIN AW4 [get_ports {pci_exp_rxp[13]}]
#set_property PACKAGE_PIN_NAME MGTYRXN2_224 [get_ports {pci_exp_rxn[13]}]
set_property PACKAGE_PIN AW3 [get_ports {pci_exp_rxn[13]}]
#set_property PACKAGE_PIN_NAME MGTYRXN0_224 [get_ports {pci_exp_rxn[15]}]
set_property PACKAGE_PIN BC1 [get_ports {pci_exp_rxn[15]}]
#set_property PACKAGE_PIN_NAME MGTYTXN1_224 [get_ports {pci_exp_txn[14]}]
set_property PACKAGE_PIN BD4 [get_ports {pci_exp_txn[14]}]
#set_property PACKAGE_PIN_NAME MGTYTXP0_224 [get_ports {pci_exp_txp[15]}]
set_property PACKAGE_PIN BF5 [get_ports {pci_exp_txp[15]}]
#set_property PACKAGE_PIN_NAME MGTYTXP1_224 [get_ports {pci_exp_txp[14]}]
set_property PACKAGE_PIN BD5 [get_ports {pci_exp_txp[14]}]
#set_property PACKAGE_PIN_NAME MGTYTXN3_224 [get_ports {pci_exp_txn[12]}]
set_property PACKAGE_PIN AV6 [get_ports {pci_exp_txn[12]}]
#set_property PACKAGE_PIN_NAME MGTYRXP1_224 [get_ports {pci_exp_rxp[14]}]
set_property PACKAGE_PIN BA2 [get_ports {pci_exp_rxp[14]}]
#set_property PACKAGE_PIN_NAME MGTYRXN1_224 [get_ports {pci_exp_rxn[14]}]
set_property PACKAGE_PIN BA1 [get_ports {pci_exp_rxn[14]}]
#set_property PACKAGE_PIN_NAME MGTYTXN0_224 [get_ports {pci_exp_txn[15]}]
set_property PACKAGE_PIN BF4 [get_ports {pci_exp_txn[15]}]
#set_property PACKAGE_PIN_NAME MGTYTXN2_224 [get_ports {pci_exp_txn[13]}]
set_property PACKAGE_PIN BB4 [get_ports {pci_exp_txn[13]}]
#set_property PACKAGE_PIN_NAME MGTYRXN3_224 [get_ports {pci_exp_rxn[12]}]
set_property PACKAGE_PIN AV1 [get_ports {pci_exp_rxn[12]}]
#set_property PACKAGE_PIN_NAME MGTYTXP3_224 [get_ports {pci_exp_txp[12]}]
set_property PACKAGE_PIN AV7 [get_ports {pci_exp_txp[12]}]
#set_property PACKAGE_PIN_NAME MGTYRXP3_224 [get_ports {pci_exp_rxp[12]}]
set_property PACKAGE_PIN AV2 [get_ports {pci_exp_rxp[12]}]
#set_property PACKAGE_PIN_NAME MGTYTXP2_224 [get_ports {pci_exp_txp[13]}]
set_property PACKAGE_PIN BB5 [get_ports {pci_exp_txp[13]}]
#set_property PACKAGE_PIN_NAME MGTYRXP0_224 [get_ports {pci_exp_rxp[15]}]
set_property PACKAGE_PIN BC2 [get_ports {pci_exp_rxp[15]}]
#set_property PACKAGE_PIN_NAME MGTYTXN2_225 [get_ports {pci_exp_txn[9]}]
set_property PACKAGE_PIN AR8 [get_ports {pci_exp_txn[9]}]
#set_property PACKAGE_PIN_NAME MGTYTXP0_225 [get_ports {pci_exp_txp[11]}]
set_property PACKAGE_PIN AU9 [get_ports {pci_exp_txp[11]}]
#set_property PACKAGE_PIN_NAME MGTYTXN3_225 [get_ports {pci_exp_txn[8]}]
set_property PACKAGE_PIN AP6 [get_ports {pci_exp_txn[8]}]
#set_property PACKAGE_PIN_NAME MGTYRXP0_225 [get_ports {pci_exp_rxp[11]}]
set_property PACKAGE_PIN AU4 [get_ports {pci_exp_rxp[11]}]
#set_property PACKAGE_PIN_NAME MGTYRXN0_225 [get_ports {pci_exp_rxn[11]}]
set_property PACKAGE_PIN AU3 [get_ports {pci_exp_rxn[11]}]
#set_property PACKAGE_PIN_NAME MGTYRXN1_225 [get_ports {pci_exp_rxn[10]}]
set_property PACKAGE_PIN AT1 [get_ports {pci_exp_rxn[10]}]
#set_property PACKAGE_PIN_NAME MGTYTXN0_225 [get_ports {pci_exp_txn[11]}]
set_property PACKAGE_PIN AU8 [get_ports {pci_exp_txn[11]}]
#set_property PACKAGE_PIN_NAME MGTYRXP3_225 [get_ports {pci_exp_rxp[8]}]
set_property PACKAGE_PIN AP2 [get_ports {pci_exp_rxp[8]}]
#set_property PACKAGE_PIN_NAME MGTYRXN2_225 [get_ports {pci_exp_rxn[9]}]
set_property PACKAGE_PIN AR3 [get_ports {pci_exp_rxn[9]}]
#set_property PACKAGE_PIN_NAME MGTYRXP2_225 [get_ports {pci_exp_rxp[9]}]
set_property PACKAGE_PIN AR4 [get_ports {pci_exp_rxp[9]}]
#set_property PACKAGE_PIN_NAME MGTYTXP2_225 [get_ports {pci_exp_txp[9]}]
set_property PACKAGE_PIN AR9 [get_ports {pci_exp_txp[9]}]
#set_property PACKAGE_PIN_NAME MGTYTXN1_225 [get_ports {pci_exp_txn[10]}]
set_property PACKAGE_PIN AT6 [get_ports {pci_exp_txn[10]}]
#set_property PACKAGE_PIN_NAME MGTYRXN3_225 [get_ports {pci_exp_rxn[8]}]
set_property PACKAGE_PIN AP1 [get_ports {pci_exp_rxn[8]}]
#set_property PACKAGE_PIN_NAME MGTYTXP1_225 [get_ports {pci_exp_txp[10]}]
set_property PACKAGE_PIN AT7 [get_ports {pci_exp_txp[10]}]
#set_property PACKAGE_PIN_NAME MGTYRXP1_225 [get_ports {pci_exp_rxp[10]}]
set_property PACKAGE_PIN AT2 [get_ports {pci_exp_rxp[10]}]
#set_property PACKAGE_PIN_NAME MGTYTXP3_225 [get_ports {pci_exp_txp[8]}]
set_property PACKAGE_PIN AP7 [get_ports {pci_exp_txp[8]}]
#set_property PACKAGE_PIN_NAME MGTYRXN1_226 [get_ports {pci_exp_rxn[6]}]
set_property PACKAGE_PIN AM1 [get_ports {pci_exp_rxn[6]}]
#set_property PACKAGE_PIN_NAME MGTYTXP2_226 [get_ports {pci_exp_txp[5]}]
set_property PACKAGE_PIN AL9 [get_ports {pci_exp_txp[5]}]
#set_property PACKAGE_PIN_NAME MGTYTXP1_226 [get_ports {pci_exp_txp[6]}]
set_property PACKAGE_PIN AM7 [get_ports {pci_exp_txp[6]}]
#set_property PACKAGE_PIN_NAME MGTYTXN1_226 [get_ports {pci_exp_txn[6]}]
set_property PACKAGE_PIN AM6 [get_ports {pci_exp_txn[6]}]
#set_property PACKAGE_PIN_NAME MGTYTXN0_226 [get_ports {pci_exp_txn[7]}]
set_property PACKAGE_PIN AN8 [get_ports {pci_exp_txn[7]}]
#set_property PACKAGE_PIN_NAME MGTYRXN0_226 [get_ports {pci_exp_rxn[7]}]
set_property PACKAGE_PIN AN3 [get_ports {pci_exp_rxn[7]}]
#set_property PACKAGE_PIN_NAME MGTYTXN2_226 [get_ports {pci_exp_txn[5]}]
set_property PACKAGE_PIN AL8 [get_ports {pci_exp_txn[5]}]
#set_property PACKAGE_PIN_NAME MGTYTXN3_226 [get_ports {pci_exp_txn[4]}]
set_property PACKAGE_PIN AK6 [get_ports {pci_exp_txn[4]}]
#set_property PACKAGE_PIN_NAME MGTYRXP3_226 [get_ports {pci_exp_rxp[4]}]
set_property PACKAGE_PIN AK2 [get_ports {pci_exp_rxp[4]}]
#set_property PACKAGE_PIN_NAME MGTYRXP2_226 [get_ports {pci_exp_rxp[5]}]
set_property PACKAGE_PIN AL4 [get_ports {pci_exp_rxp[5]}]
#set_property PACKAGE_PIN_NAME MGTYRXP1_226 [get_ports {pci_exp_rxp[6]}]
set_property PACKAGE_PIN AM2 [get_ports {pci_exp_rxp[6]}]
#set_property PACKAGE_PIN_NAME MGTYTXP0_226 [get_ports {pci_exp_txp[7]}]
set_property PACKAGE_PIN AN9 [get_ports {pci_exp_txp[7]}]
#set_property PACKAGE_PIN_NAME MGTYRXP0_226 [get_ports {pci_exp_rxp[7]}]
set_property PACKAGE_PIN AN4 [get_ports {pci_exp_rxp[7]}]
#set_property PACKAGE_PIN_NAME MGTYRXN3_226 [get_ports {pci_exp_rxn[4]}]
set_property PACKAGE_PIN AK1 [get_ports {pci_exp_rxn[4]}]
#set_property PACKAGE_PIN_NAME MGTYTXP3_226 [get_ports {pci_exp_txp[4]}]
set_property PACKAGE_PIN AK7 [get_ports {pci_exp_txp[4]}]
#set_property PACKAGE_PIN_NAME MGTYRXN2_226 [get_ports {pci_exp_rxn[5]}]
set_property PACKAGE_PIN AL3 [get_ports {pci_exp_rxn[5]}]
#set_property PACKAGE_PIN_NAME MGTYTXN0_227 [get_ports {pci_exp_txn[3]}]
set_property PACKAGE_PIN AJ8 [get_ports {pci_exp_txn[3]}]
#set_property PACKAGE_PIN_NAME MGTYRXP0_227 [get_ports {pci_exp_rxp[3]}]
set_property PACKAGE_PIN AJ4 [get_ports {pci_exp_rxp[3]}]
#set_property PACKAGE_PIN_NAME MGTYRXP2_227 [get_ports {pci_exp_rxp[1]}]
set_property PACKAGE_PIN AG4 [get_ports {pci_exp_rxp[1]}]
#set_property PACKAGE_PIN_NAME MGTYTXP0_227 [get_ports {pci_exp_txp[3]}]
set_property PACKAGE_PIN AJ9 [get_ports {pci_exp_txp[3]}]
#set_property PACKAGE_PIN_NAME MGTYRXN3_227 [get_ports {pci_exp_rxn[0]}]
set_property PACKAGE_PIN AF1 [get_ports {pci_exp_rxn[0]}]
#set_property PACKAGE_PIN_NAME MGTYTXN1_227 [get_ports {pci_exp_txn[2]}]
set_property PACKAGE_PIN AH6 [get_ports {pci_exp_txn[2]}]
#set_property PACKAGE_PIN_NAME MGTYTXP1_227 [get_ports {pci_exp_txp[2]}]
set_property PACKAGE_PIN AH7 [get_ports {pci_exp_txp[2]}]
#set_property PACKAGE_PIN_NAME MGTYRXP1_227 [get_ports {pci_exp_rxp[2]}]
set_property PACKAGE_PIN AH2 [get_ports {pci_exp_rxp[2]}]
#set_property PACKAGE_PIN_NAME MGTYRXN2_227 [get_ports {pci_exp_rxn[1]}]
set_property PACKAGE_PIN AG3 [get_ports {pci_exp_rxn[1]}]
#set_property PACKAGE_PIN_NAME MGTYTXP3_227 [get_ports {pci_exp_txp[0]}]
set_property PACKAGE_PIN AF7 [get_ports {pci_exp_txp[0]}]
#set_property PACKAGE_PIN_NAME MGTYRXN0_227 [get_ports {pci_exp_rxn[3]}]
set_property PACKAGE_PIN AJ3 [get_ports {pci_exp_rxn[3]}]
#set_property PACKAGE_PIN_NAME MGTYTXP2_227 [get_ports {pci_exp_txp[1]}]
set_property PACKAGE_PIN AG9 [get_ports {pci_exp_txp[1]}]
#set_property PACKAGE_PIN_NAME MGTYTXN2_227 [get_ports {pci_exp_txn[1]}]
set_property PACKAGE_PIN AG8 [get_ports {pci_exp_txn[1]}]
#set_property PACKAGE_PIN_NAME MGTYRXP3_227 [get_ports {pci_exp_rxp[0]}]
set_property PACKAGE_PIN AF2 [get_ports {pci_exp_rxp[0]}]
#set_property PACKAGE_PIN_NAME MGTYTXN3_227 [get_ports {pci_exp_txn[0]}]
set_property PACKAGE_PIN AF6 [get_ports {pci_exp_txn[0]}]
#set_property PACKAGE_PIN_NAME MGTYRXN1_227 [get_ports {pci_exp_rxn[2]}]
set_property PACKAGE_PIN AH1 [get_ports {pci_exp_rxn[2]}]

##### I2C Pins ###########
set_property PACKAGE_PIN BF15 [get_ports {i2c_scl}]
set_property IOSTANDARD LVCMOS18 [get_ports {i2c_scl}]
set_property SLEW SLOW  [get_ports {i2c_scl}]

set_property PACKAGE_PIN BE15 [get_ports {i2c_sda}]
set_property IOSTANDARD LVCMOS18 [get_ports {i2c_sda}]
set_property SLEW SLOW  [get_ports {i2c_sda}]


###############################################################################
# Flash Programming Settings: Uncomment as required by your design
# Items below between < > must be updated with correct values to work properly.
###############################################################################

# these are some general configuration settings
# in the future, these should probably be in their own XDC file
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 102.0 [current_design]
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]
# this is just a dummy code that we want to be able to read when we load up the FPGA
#set_property BITSTREAM.CONFIG.USERID 0xCAFE0850 [current_design]
#
# SPI Flash Programming
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
# Example PROM Generation command that should be executed from the Tcl Console
# write_cfgmem -force -format MCS -size 1024 -interface SPIx4 -loadbit "up 0x0 <inputBitfile.bit>" <outputMCSfile.mcs>

