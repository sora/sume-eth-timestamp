`timescale 1ns / 100ps
`default_nettype none

import xgmii_pkg::*;
import utils_pkg::*;

module eth_fcs_gen (
	input bit clk,
	input bit rst,
	input bit crc_en,
	input xgmii_ctrl_t xgmii_ctrl,
	input xgmii_data_t xgmii_data,
	input bit data_last,
	output bit [31:0] fcs
);

bit [31:0] c = 32'hFFFFFFFF;
wire [63:0] d = bit_reverse64(xgmii_data);

bit [31:0] next0, next1, next2, next3, next4, next5, next6, next7;
crc32_d8  crc8  (.data_in(d[63:56]), .crc_state(c), .crc_next(next0));
crc32_d16 crc16 (.data_in(d[63:48]), .crc_state(c), .crc_next(next1));
crc32_d24 crc24 (.data_in(d[63:40]), .crc_state(c), .crc_next(next2));
crc32_d32 crc32 (.data_in(d[63:32]), .crc_state(c), .crc_next(next3));
crc32_d40 crc40 (.data_in(d[63:24]), .crc_state(c), .crc_next(next4));
crc32_d48 crc48 (.data_in(d[63:16]), .crc_state(c), .crc_next(next5));
crc32_d56 crc56 (.data_in(d[63: 8]), .crc_state(c), .crc_next(next6));
crc32_d64 crc64 (.data_in(d[63: 0]), .crc_state(c), .crc_next(next7));

byte xgmii_ctrl_next;
bit xgmii_next;
always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		c <= 32'hffffffff;
		xgmii_ctrl_next <= 8'b0;
		xgmii_next <= 1'b0;
	end else begin
		xgmii_ctrl_next <= xgmii_ctrl;

		if (crc_en) begin
			if (data_last) begin

				if (xgmii_ctrl == 8'b1110_0000 ||
				    xgmii_ctrl == 8'b1100_0000 ||
				    xgmii_ctrl == 8'b1000_0000) begin
					xgmii_next <= 1'b1;
				end

				case (xgmii_ctrl)
					8'b1111_1111: c <= next3;
					8'b1111_1110: c <= next4;
					8'b1111_1100: c <= next5;
					8'b1111_1000: c <= next6;
					8'b1111_0000: c <= next7;
					default: c <= next7;
				endcase
			end else if (xgmii_next) begin
				xgmii_next <= 1'b0;
				case (xgmii_ctrl_next)
					8'b1110_0000: c <= next0;
					8'b1100_0000: c <= next1;
					8'b1000_0000: c <= next2;
					default: c <= 32'b0;
				endcase
			end else begin
				c <= next7;
			end
		end else begin
			c <= 32'hffffffff;
		end
	end
end
always_comb fcs = ~{ bit_reverse32(c) };

`ifdef SIMULATION
wire [31:0] next0_debug = ~{
	next0[00], next0[01], next0[02], next0[03], next0[04], next0[05], next0[06], next0[07],
	next0[08], next0[09], next0[10], next0[11], next0[12], next0[13], next0[14], next0[15],
	next0[16], next0[17], next0[18], next0[19], next0[20], next0[21], next0[22], next0[23],
	next0[24], next0[25], next0[26], next0[27], next0[28], next0[29], next0[30], next0[31]
};
wire [31:0] next1_debug = ~{
	next1[00], next1[01], next1[02], next1[03], next1[04], next1[05], next1[06], next1[07],
	next1[08], next1[09], next1[10], next1[11], next1[12], next1[13], next1[14], next1[15],
	next1[16], next1[17], next1[18], next1[19], next1[20], next1[21], next1[22], next1[23],
	next1[24], next1[25], next1[26], next1[27], next1[28], next1[29], next1[30], next1[31]
};
wire [31:0] next2_debug = ~{
	next2[00], next2[01], next2[02], next2[03], next2[04], next2[05], next2[06], next2[07],
	next2[08], next2[09], next2[10], next2[11], next2[12], next2[13], next2[14], next2[15],
	next2[16], next2[17], next2[18], next2[19], next2[20], next2[21], next2[22], next2[23],
	next2[24], next2[25], next2[26], next2[27], next2[28], next2[29], next2[30], next2[31]
};
wire [31:0] next3_debug = ~{
	next3[00], next3[01], next3[02], next3[03], next3[04], next3[05], next3[06], next3[07],
	next3[08], next3[09], next3[10], next3[11], next3[12], next3[13], next3[14], next3[15],
	next3[16], next3[17], next3[18], next3[19], next3[20], next3[21], next3[22], next3[23],
	next3[24], next3[25], next3[26], next3[27], next3[28], next3[29], next3[30], next3[31]
};
wire [31:0] next4_debug = ~{
	next4[00], next4[01], next4[02], next4[03], next4[04], next4[05], next4[06], next4[07],
	next4[08], next4[09], next4[10], next4[11], next4[12], next4[13], next4[14], next4[15],
	next4[16], next4[17], next4[18], next4[19], next4[20], next4[21], next4[22], next4[23],
	next4[24], next4[25], next4[26], next4[27], next4[28], next4[29], next4[30], next4[31]
};
wire [31:0] next5_debug = ~{
	next5[00], next5[01], next5[02], next5[03], next5[04], next5[05], next5[06], next5[07],
	next5[08], next5[09], next5[10], next5[11], next5[12], next5[13], next5[14], next5[15],
	next5[16], next5[17], next5[18], next5[19], next5[20], next5[21], next5[22], next5[23],
	next5[24], next5[25], next5[26], next5[27], next5[28], next5[29], next5[30], next5[31]
};
wire [31:0] next6_debug = ~{
	next6[00], next6[01], next6[02], next6[03], next6[04], next6[05], next6[06], next6[07],
	next6[08], next6[09], next6[10], next6[11], next6[12], next6[13], next6[14], next6[15],
	next6[16], next6[17], next6[18], next6[19], next6[20], next6[21], next6[22], next6[23],
	next6[24], next6[25], next6[26], next6[27], next6[28], next6[29], next6[30], next6[31]
};
wire [31:0] next7_debug = ~{
	next7[00], next7[01], next7[02], next7[03], next7[04], next7[05], next7[06], next7[07],
	next7[08], next7[09], next7[10], next7[11], next7[12], next7[13], next7[14], next7[15],
	next7[16], next7[17], next7[18], next7[19], next7[20], next7[21], next7[22], next7[23],
	next7[24], next7[25], next7[26], next7[27], next7[28], next7[29], next7[30], next7[31]
};

/* verilator lint_off UNUSED */
wire [31:0] debug = next0_debug ^ next1_debug ^ next2_debug ^ next3_debug ^ next4_debug ^ next5_debug ^ next6_debug ^ next7_debug;
`endif

endmodule

`default_nettype wire
