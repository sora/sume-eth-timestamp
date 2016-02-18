`timescale 1ns / 100ps
`default_nettype none

import xgmii_pkg::*;

module txfifo (
	input bit clk,
	input bit rst,
	input xgmii_t xgmii_txi,
	output xgmii_t xgmii_txo
);

xgmii_t xgmii_reg1, xgmii_reg2;

// Ethernet FCS
bit crc_en;
always_comb begin
	crc_en = 1'b0;
	if (xgmii_reg1.ctrl[0] == 1'b1 && xgmii_reg1.data[0] == XGMII_START) begin
		crc_en = 1'b1;
	end
end

bit data_last;
always_comb begin
	data_last = 1'b0;
	if ((xgmii_txi.ctrl[0] == 1'b1 && xgmii_txi.data[0] == XGMII_TERM) ||
	    (xgmii_txi.ctrl[1] == 1'b1 && xgmii_txi.data[1] == XGMII_TERM) ||
	    (xgmii_txi.ctrl[2] == 1'b1 && xgmii_txi.data[2] == XGMII_TERM) ||
	    (xgmii_txi.ctrl[3] == 1'b1 && xgmii_txi.data[3] == XGMII_TERM) ||
	    (xgmii_txi.ctrl[4] == 1'b1 && xgmii_txi.data[4] == XGMII_TERM) ||
	    (xgmii_txi.ctrl[5] == 1'b1 && xgmii_txi.data[5] == XGMII_TERM) ||
	    (xgmii_txi.ctrl[6] == 1'b1 && xgmii_txi.data[6] == XGMII_TERM) ||
	    (xgmii_txi.ctrl[4] == 1'b1 && xgmii_txi.data[7] == XGMII_TERM)) begin
		data_last = 1'b1;
	end
end

bit [31:0] crc64_out;
eth_fcs_gen eth_fcs_gen0 (
	.rst(crc_en),
	.clk(clk),
	.crc_en(~crc_en),
	.xgmii_ctrl(xgmii_txi.ctrl),
	.xgmii_data(xgmii_reg1.data),
	.data_last(data_last),
	.fcs(crc64_out)
);

always_ff @(posedge clk) begin
	if (rst) begin
		xgmii_reg1 <= '{default: 0};
		xgmii_reg2 <= '{default: 0};
		xgmii_txo <= '{default: 0};
	end else begin
		xgmii_reg1 <= xgmii_txi;
		xgmii_reg2 <= xgmii_reg1;
		xgmii_txo <= xgmii_reg2;

		// 60
		if (xgmii_reg1.ctrl[0] == 1'b1 && xgmii_reg1.data[0] == XGMII_TERM) begin
			xgmii_txo.data <= {crc64_out, xgmii_reg2.data[3:0]};
		end
		// 61
		if (xgmii_reg1.ctrl[1] == 1'b1 && xgmii_reg1.data[1] == XGMII_TERM) begin
			xgmii_reg2.data <= {xgmii_reg1.data[7:1], crc64_out[31:24]};
			xgmii_txo.data <= {crc64_out[23:0], xgmii_reg2.data[4:0]};
		end
		// 62
		if (xgmii_reg1.ctrl[2] == 1'b1 && xgmii_reg1.data[2] == XGMII_TERM) begin
			xgmii_reg2.data <= {xgmii_reg1.data[7:2], crc64_out[31:16]};
			xgmii_txo.data <= {crc64_out[15:0], xgmii_reg2.data[5:0]};
		end
		// 63
		if (xgmii_reg1.ctrl[3] == 1'b1 && xgmii_reg1.data[3] == XGMII_TERM) begin
			xgmii_reg2.data <= {xgmii_reg1.data[7:3], crc64_out[31:8]};
			xgmii_txo.data <= {crc64_out[7:0], xgmii_reg2.data[6:0]};
		end
		// 64
		if (xgmii_reg1.ctrl[4] == 1'b1 && xgmii_reg1.data[4] == XGMII_TERM) begin
			xgmii_reg2.data <= {xgmii_reg1.data[7:4], crc64_out};
		end

		// 65
		if (xgmii_reg2.ctrl[5] == 1'b1 && xgmii_reg2.data[5] == XGMII_TERM) begin
			xgmii_txo.data <= {xgmii_reg2.data[7:5], crc64_out, xgmii_reg2.data[0]};
		end
		// 66
		if (xgmii_reg2.ctrl[6] == 1'b1 && xgmii_reg2.data[6] == XGMII_TERM) begin
			xgmii_txo.data <= {xgmii_reg2.data[7:6], crc64_out, xgmii_reg2.data[1:0]};
		end
		// 67
		if (xgmii_reg2.ctrl[7] == 1'b1 && xgmii_reg2.data[7] == XGMII_TERM) begin
			xgmii_txo.data <= {xgmii_reg2.data[7], crc64_out, xgmii_reg2.data[2:0]};
		end
	end
end

endmodule

`default_nettype wire

