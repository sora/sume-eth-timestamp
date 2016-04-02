set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]


# FPGA_SYSCLK
set_property VCCAUX_IO DONTCARE [get_ports FPGA_SYSCLK_P]
set_property IOSTANDARD DIFF_SSTL15 [get_ports FPGA_SYSCLK_P]
set_property IOSTANDARD DIFF_SSTL15 [get_ports FPGA_SYSCLK_N]
set_property PACKAGE_PIN H19 [get_ports FPGA_SYSCLK_P]
set_property PACKAGE_PIN G18 [get_ports FPGA_SYSCLK_N]
create_clock -period 5.000 -name sys_clk_pin -waveform {0.000 2.500} -add [get_ports FPGA_SYSCLK_P]


# SFP/QTH Transceiver clock (Must be set to value provided by Si5324, currently set to 156.25 MHz)
set_property PACKAGE_PIN E10 [get_ports SFP_CLK_P]
set_property PACKAGE_PIN E9 [get_ports SFP_CLK_N]
create_clock -period 6.400 -name SFP_CLK_P -add [get_ports SFP_CLK_P]

#SFP Transceivers

#set_property LOC GTHE2_CHANNEL_X1Y39 [get_cells ten_gig_eth_pcs_pma_inst0/inst/ten_gig_eth_pcs_pma_block_i/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_gth_10gbaser_i/gthe2_i]
set_property LOC GTHE2_CHANNEL_X1Y39 [get_cells axi_10g_ethernet_0_ins/inst/ten_gig_eth_pcs_pma/inst/ten_gig_eth_pcs_pma_block_i/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_gth_10gbaser_i/gthe2_i]
set_property PACKAGE_PIN B3 [get_ports ETH1_RX_N]
set_property PACKAGE_PIN A5 [get_ports ETH1_TX_N]
set_property PACKAGE_PIN A6 [get_ports ETH1_TX_P]
set_property PACKAGE_PIN B4 [get_ports ETH1_RX_P]

# SFP ETH1 Misc.
set_property PACKAGE_PIN G13 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[0]}]
set_property PACKAGE_PIN L15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]
set_property PACKAGE_PIN AL22 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[2]}]
set_property PACKAGE_PIN BA20 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[3]}]
set_property PACKAGE_PIN AY18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[4]}]
set_property PACKAGE_PIN AY17 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[5]}]
set_property PACKAGE_PIN P31 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[6]}]
set_property PACKAGE_PIN K32 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[7]}]

set_property PACKAGE_PIN M18 [get_ports ETH1_TX_DISABLE]
set_property IOSTANDARD LVCMOS15 [get_ports ETH1_TX_DISABLE]

set_property PACKAGE_PIN L17 [get_ports ETH1_RX_LOS]
set_property IOSTANDARD LVCMOS15 [get_ports ETH1_RX_LOS]

set_property PACKAGE_PIN M19 [get_ports ETH1_TX_FAULT]
set_property IOSTANDARD LVCMOS15 [get_ports ETH1_TX_FAULT]

set_property SLEW SLOW [get_ports I2C_FPGA_SCL]
set_property DRIVE 16 [get_ports I2C_FPGA_SCL]
set_property PACKAGE_PIN AK24 [get_ports I2C_FPGA_SCL]
set_property PULLUP true [get_ports I2C_FPGA_SCL]
set_property IOSTANDARD LVCMOS18 [get_ports I2C_FPGA_SCL]

set_property SLEW SLOW [get_ports I2C_FPGA_SDA]
set_property DRIVE 16 [get_ports I2C_FPGA_SDA]
set_property PACKAGE_PIN AK25 [get_ports I2C_FPGA_SDA]
set_property PULLUP true [get_ports I2C_FPGA_SDA]
set_property IOSTANDARD LVCMOS18 [get_ports I2C_FPGA_SDA]

#set_property SLEW SLOW [get_ports { i2c_mux_rst }]
#set_property DRIVE 16 [get_ports { i2c_mux_rst }]
#set_property PACKAGE_PIN AM39 [get_ports { i2c_mux_rst }]
#set_property IOSTANDARD LVCMOS15 [get_ports { i2c_mux_rst }]

#set_property SLEW SLOW [get_ports { si5324_rst }]
#set_property DRIVE 16 [get_ports { si5324_rst }]
#set_property PACKAGE_PIN BA29 [get_ports { si5324_rst }]
#set_property IOSTANDARD LVCMOS18 [get_ports { si5324_rst }]

set_property PACKAGE_PIN AM29 [get_ports SFP_CLK_ALARM_B]
set_property IOSTANDARD LVCMOS18 [get_ports SFP_CLK_ALARM_B]

set_property IOSTANDARD LVDS [get_ports SFP_REC_CLK_N]

set_property PACKAGE_PIN AW32 [get_ports SFP_REC_CLK_P]
set_property PACKAGE_PIN AW33 [get_ports SFP_REC_CLK_N]
set_property IOSTANDARD LVDS [get_ports SFP_REC_CLK_P]

# Else
#set_false_path -from [get_clocks sys_clk_pin] -to [get_clocks SFP_CLK_P]

