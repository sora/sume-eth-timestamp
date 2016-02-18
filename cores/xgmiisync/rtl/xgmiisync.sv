`timescale 1ns / 100ps
`default_nettype none

import xgmii_pkg::*;

module xgmiisync (
	input  bit     sys_rst,
	input  bit     xgmii_rx_clk,
	input  xgmii_t xgmii_rxi,
	output xgmii_t xgmii_rxo
);

xgmii_t xgmii_reg;
bit quad_shift = 1'b0;

always_ff @(posedge xgmii_rx_clk) begin
	if (sys_rst) begin
		xgmii_reg  <= '{default:0};
		xgmii_rxo  <= '{default:0};
		quad_shift <= 1'b0;
	end else begin
		xgmii_reg <= xgmii_rxi;

		if (xgmii_rxi.ctrl[4] == 1'b1 && xgmii_rxi.data[4] == XGMII_START) begin
			quad_shift <= 1'b1;
		end else if (xgmii_rxi.ctrl[0] == 1'b1 && xgmii_rxi.data[0] == XGMII_START) begin
			quad_shift <= 1'b0;
		end

		if (quad_shift == 1'b0) begin
			xgmii_rxo <= xgmii_reg;
		end else begin
			xgmii_rxo.ctrl <= {xgmii_rxi.ctrl[3:0], xgmii_reg.ctrl[7:4]};
			xgmii_rxo.data <= {xgmii_rxi.data[3:0], xgmii_reg.data[7:4]};
		end
	end
end

endmodule

`default_nettype wire
