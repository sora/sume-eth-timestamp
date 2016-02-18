module biosrom (
	input  bit clk,
	input  bit en,
	input  bit [8:0] addr,
	output bit [31:0] data
);

reg [31:0] rom [0:511];

initial begin
	$readmemh("cores/biosrom/rtl/biosrom.d32", rom, 0, 511);
end

always_ff @(posedge clk) begin
	if (en)
		data <= rom[ addr ];
end

endmodule
