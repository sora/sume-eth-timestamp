interface pcie_config;

	bit [7:0] bus_num;
	bit [4:0] device_num;
	bit [2:0] func_num;
	bit       to_turnoff;
	bit       turnoff_ok;

	modport bridge (
		input  bus_num, device_num, func_num, to_turnoff,
		output turnoff_ok
	);
	modport driver (
		input  turnoff_ok,
		output bus_num, device_num, func_num, to_turnoff
	);
endinterface :pcie_config
