interface pcie_axis_master #(
	parameter C_DATA_WIDTH = 64,               // RX/TX interface data width
	parameter KEEP_WIDTH   = C_DATA_WIDTH / 8, // TSTRB width
	parameter TCQ          = 1
);
	bit [C_DATA_WIDTH-1:0] tdata;
	bit [KEEP_WIDTH-1:0]   tkeep;
	bit                    tlast;
	bit                    tvalid;
	bit [21:0]             tuser;
	bit                    tready;

	modport rx (
		input  tdata, tkeep, tlast, tvalid, tuser,
		output tready
	);
endinterface :pcie_axis_master
