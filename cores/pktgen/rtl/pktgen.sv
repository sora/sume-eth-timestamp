import utils_pkg::*;
import endian_pkg::*;

import xgmii_pkg::*;
import ethernet_pkg::*;
import ip_pkg::*;
import udp_pkg::*;
import pktgen_pkg.sv::*;

import pbuf_pkg.sv::*;

module pktgen #(
	parameter pkt_size = 16'd68
)(
	input wire sys_rst,
	input wire xgmii_clk,

	input wire pkt_req,
	output xgmii_t xgmii_out
);


/* packet data */
union packed {
	bit [8:0][63:0] raw;     // 72B
	struct packed {
		pbhdr pb;            // 10B
		ethhdr eth;          // 14B
		iphdr ip;            // 20B
		udphdr udp;          //  8B
		pghdr pg;            // 16B
		bit [31:0] padding;  //  4B
	} pkt;
} tx_pkt;

bit [9:0] tx_counter = 10'h0, next_tx_counter = 10'h0;

/* TX logic */
enum bit { TX_IDLE, TX_DATA } tx_state = TX_IDLE, next_tx_state;
always_ff @(posedge xgmii_clk) begin
	if(sys_rst) begin
		tx_state       <= TX_DATA;
		tx_pkt.pkt.pb  <= pb_init(frame_len);
		tx_pkt.pkt.eth <= eth_init(48'hFF_FF_FF_FF_FF_FF,
		                           48'h00_00_00_00_00_01,
		                           ETH_P_IP);
		tx_pkt.pkt.ip  <= ip_init(frame_len);
		tx_pkt.pkt.udp <= udp_init(frame_len);
		tx_pkt.pkt.pg  <= pg_init();
	end else begin
		tx_state   <= next_tx_state;
		tx_counter <= next_tx_counter;
	end
end

always_comb begin
	next_tx_state = TX_IDLE;

	next_tx_counter = 10'h0;

	case (tx_state)
		TX_IDLE: begin
			if (pkt_req)
				next_tx_state = TX_DATA;
		end
		TX_DATA: begin
			next_tx_counter = tx_counter + 10'h1;
			if (tx_counter == 10'h9)
				next_tx_state = TX_IDLE;
		end
	endcase
end

always_comb begin
	crc_init = 1'b0;

	case (tx_counter)
		10'h1: begin
			xgmii_out = {8'b0000_0001, {ETH_OP_SFD, { 6{ETH_OP_PREAMBLE} },
			                             XGMII_OP_START}};
		end
		10'h2: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[8])};
		10'h3: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[7])};
		10'h4: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[6])};
		10'h5: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[5])};
		10'h6: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[4])};
		10'h7: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[3])};
		10'h8: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[2])};
		10'h9: xgmii_out = {8'b0000_0000, endian_conv64(tx_pkt.raw[1])};
		10'ha: xgmii_out = {8'b1111_0000, {{ 3{XGMII_OP_IDLE} },
		                                   XGMII_OP_TERMINATE,
		                                   { 4{8'h00} }}};
		default: xgmii_out = {8'b1111_1111, { 8{XGMII_OP_IDLE} }};
	endcase
end

endmodule
