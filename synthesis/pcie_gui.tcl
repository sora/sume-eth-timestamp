# PlanAhead Launch Script
set design_top top
set sim_top board
set device xc7vx690t-3-ffg1761
set proj_dir runs 

create_project -name ${design_top} -force -dir "./${proj_dir}" -part ${device}

# Project Settings

set_property top ${design_top} [current_fileset]
set_property verilog_define {{USE_VIVADO=1}} [current_fileset]

#add_files -fileset constrs_1 -norecurse ../constraints/xilinx_pcie3_7x_ep_x8g3_VC709.xdc
#set_property used_in_synthesis true [get_files ../constraints/xilinx_pcie3_7x_ep_x8g3_VC709.xdc]
#add_files -fileset constrs_1 -norecurse ../constraints/k7_conn_pcie.xdc
#set_property used_in_synthesis true [get_files ../constraints/k7_conn_pcie.xdc]
#set impl_const ../constraints/vc709.xdc
#add_files -fileset constrs_1 -norecurse ./${impl_const}
#set_property used_in_synthesis true [get_files ./${impl_const}]
add_files -fileset constrs_1 -norecurse ../constraints/sume.xdc
set_property used_in_synthesis true [get_files ../constraints/sume.xdc]


# Project Design Files from IP Catalog (comment out IPs using legacy Coregen cores)
#import_ip -files {../ip_catalog/pcie3_7x_0.xci} -name pcie3_7x_0

# Other Custom logic sources/rtl files
# read_verilog 
# read_verilog -sv 
# read_vhdl 
#read_verilog "../rtl/top.v"
#read_verilog "../rtl/pcie/support/pcie3_7x_0_pipe_clock.v"
#read_verilog "../rtl/pcie/support/pcie3_7x_0_support.v"
#read_verilog "../rtl/pcie/pcie_app_7vx.v"
#read_verilog "../rtl/pcie/PIO.v"
#read_verilog "../rtl/pcie/PIO_EP.v"
#read_verilog "../rtl/pcie/PIO_EP_MEM_ACCESS.v"
#read_verilog "../rtl/pcie/PIO_RX_ENGINE.v"
#read_verilog "../rtl/pcie/PIO_TO_CTRL.v"
#read_verilog "../rtl/pcie/PIO_TX_ENGINE.v"
#read_verilog "../rtl/biosrom.v"
#read_verilog "../rtl/pcie/EP_MEM.v"
#read_verilog "../rtl/pcie/PIO_INTR_CTRL.v"

import_ip -files {../ip_catalog/axi_10g_ethernet_0/axi_10g_ethernet_0.xci} -name axi_10g_ethernet_0
import_ip -files {../ip_catalog/axi_10g_ethernet_1/axi_10g_ethernet_1.xci} -name axi_10g_ethernet_1
import_ip -files {../ip_catalog/si5324_regs_rom/si5324_regs_rom.xcix} -name si5324_regs_rom
import_ip -files {../ip_catalog/pcie2eth_fifo/pcie2eth_fifo.xci} -name pcie2eth_fifo

read_verilog -sv ../cores/include/utils_pkg.sv
read_verilog -sv ../cores/include/ethernet_pkg.sv
read_verilog -sv ../cores/include/ip_pkg.sv
read_verilog -sv ../cores/include/udp_pkg.sv
read_verilog -sv ../cores/include/endian_pkg.sv

read_verilog ../rtl/SFP_CLK_INIT_rtl/i2c/trunk/rtl/verilog/i2c_master_bit_ctrl.v
read_vhdl ../rtl/SFP_CLK_INIT_rtl/pkg_clk_init_engine.vhd
read_verilog ../rtl/SFP_CLK_INIT_rtl/i2c/trunk/rtl/verilog/i2c_master_byte_ctrl.v
read_vhdl ../rtl/SFP_CLK_INIT_rtl/clk_init_engine.vhd
read_verilog ../rtl/SFP_CLK_INIT_rtl/i2c/trunk/rtl/verilog/i2c_master_top.v
read_verilog -sv ../rtl/eth_send.sv
read_verilog ../rtl/pcs_pma_conf.v
read_verilog ../rtl/eth_mac_conf.v
read_vhdl ../rtl/SFP_CLK_INIT_rtl/sfp_refclk_init.vhd
read_verilog -sv ../rtl/top.sv

# read coe






# NGC files
#read_edif "../ip_cores/dma/netlist/eval/dma_back_end_axi.ngc"

#Setting Rodin Sythesis options
set_property flow {Vivado Synthesis 2015} [get_runs synth_1]
set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]

set_property flow {Vivado Implementation 2015} [get_runs impl_1]

####################
# Set up Simulations
# Get the current working directory
#set CurrWrkDir [pwd]
#
#if [info exists env(MODELSIM)] {
#  puts "MODELSIM env pointing to ini exists..."
#} elseif {[file exists $CurrWrkDir/modelsim.ini] == 1} {
#  set env(MODELSIM) $CurrWrkDir/modelsim.ini
#  puts "Setting \$MODELSIM to modelsim.ini"
#} else {
#  puts "\n\nERROR! modelsim.ini not found!"
#  exit
#}

#set_property target_simulator ModelSim [current_project]
#set_property -name modelsim.vlog_more_options -value +acc -objects [get_filesets sim_1]
#set_property -name modelsim.vsim_more_options -value {+notimingchecks -do "../../../../wave.do; run -all" +TESTNAME=basic_test -GSIM_COLLISION_CHECK=NONE } -objects [get_filesets sim_1]
#set_property compxlib.compiled_library_dir {} [current_project]
#
#set_property include_dirs { ../testbench ../testbench/dsport ../include } [get_filesets sim_1]
#
