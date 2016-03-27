import endian_pkg::*;
import ethernet_pkg::*;
import ip_pkg::*;
import udp_pkg::*;

module eth_send #(
	parameter frame_len = 16'd60,

//    parameter eth_dst   = 48'hFF_FF_FF_FF_FF_FF,
	parameter eth_dst   = 48'h90_E2_BA_5D_8D_C8,
	parameter eth_src   = 48'h00_11_22_33_44_55,
	parameter eth_proto = ETH_P_IP,
	parameter ip_saddr  = {8'd192, 8'd168, 8'd1, 8'd111},
	parameter ip_daddr  = {8'd192, 8'd168, 8'd1, 8'd122},
	parameter udp_sport = 16'd3776,
	parameter udp_dport = 16'd3776
)(
	input wire clk156,
	input wire reset,

	input  wire         s_axis_tx_tready,
	output logic        s_axis_tx_tvalid,
	output logic [63:0] s_axis_tx_tdata,
	output logic [ 7:0] s_axis_tx_tkeep,
	output logic        s_axis_tx_tlast
);

/* function: ipcheck_gen() */
function [15:0] ipcheck_gen();
	bit [23:0] sum;
	sum = {8'h0, IPVERSION, 4'd5, 8'h0}
	    + {8'h0, frame_len - ETH_HDR_LEN}   // tot_len
	    + {8'h0, 16'h0}
	    + {8'h0, 16'h0}
	    + {8'h0, IPDEFTTL, IP4_PROTO_UDP}
	    + {8'h0, 16'h0}                     // checksum (zero padding)
	    + {8'h0, ip_saddr[31:16]}
	    + {8'h0, ip_saddr[15: 0]}
	    + {8'h0, ip_daddr[31:16]}
	    + {8'h0, ip_daddr[15: 0]};
	ipcheck_gen = ~( sum[15:0] + {8'h0, sum[23:16]} );
endfunction :ipcheck_gen

// tx_packet
typedef union packed {
	bit [7:0][63:0] raw;          // 64B
	struct packed {
		ethhdr eth;                // 14B
		iphdr ip;                  // 20B
		udphdr udp;                //  8B
		bit [175:0] padding;       //
	} hdr;
} packet_t;

// packet init
packet_t tx_pkt;

always_comb begin
	tx_pkt.hdr.eth.h_dest = eth_dst;
	tx_pkt.hdr.eth.h_source = eth_src;
	tx_pkt.hdr.eth.h_proto = eth_proto;

	tx_pkt.hdr.ip.version = IPVERSION;
	tx_pkt.hdr.ip.ihl = 4'd5;
	tx_pkt.hdr.ip.tos = 0;
	tx_pkt.hdr.ip.tot_len = frame_len - ETH_HDR_LEN;
	tx_pkt.hdr.ip.id = 0;
	tx_pkt.hdr.ip.frag_off = 0;
	tx_pkt.hdr.ip.ttl = IPDEFTTL;
	tx_pkt.hdr.ip.protocol = IP4_PROTO_UDP;
//	tx_pkt.hdr.ip.saddr = ip_saddr;
	tx_pkt.hdr.ip.daddr = ip_daddr;
	tx_pkt.hdr.ip.check = ipcheck_gen();

	tx_pkt.hdr.udp.source = udp_sport;
	tx_pkt.hdr.udp.dest = udp_dport;
	tx_pkt.hdr.udp.len = frame_len - ETH_HDR_LEN - IP_HDR_DEFLEN;
	tx_pkt.hdr.udp.check = 0;
end

// txcnt
logic [27:0] txcnt;
enum bit { TX_IDLE, TX_SEND } tx_state = TX_IDLE;
logic [31:0] saddr;
always_ff @(posedge clk156) begin
	if (reset) begin
		txcnt <= 0;
		tx_state <= TX_IDLE;
		saddr <= 0;
	end else begin
		case (tx_state)
			TX_IDLE: begin
				txcnt <= 0;
				if (s_axis_tx_tready) begin
					tx_state <= TX_SEND;
					saddr <= saddr + 1;
				end
			end
			TX_SEND: begin
				txcnt <= txcnt + 1;
				if (txcnt == 7)
					tx_state <= TX_IDLE;
			end
		endcase
	end
end
always_comb tx_pkt.hdr.ip.saddr = saddr;

// tdata
logic [63:0] s_axis_tx_tdata_rev;
always_comb begin
	if (tx_state == TX_SEND) begin
		case (txcnt)
			27'h0: s_axis_tx_tdata_rev = tx_pkt.raw[7];
			27'h1: s_axis_tx_tdata_rev = tx_pkt.raw[6];
			27'h2: s_axis_tx_tdata_rev = tx_pkt.raw[5];
			27'h3: s_axis_tx_tdata_rev = tx_pkt.raw[4];
			27'h4: s_axis_tx_tdata_rev = tx_pkt.raw[3];
			27'h5: s_axis_tx_tdata_rev = tx_pkt.raw[2];
			27'h6: s_axis_tx_tdata_rev = tx_pkt.raw[1];
			27'h7: s_axis_tx_tdata_rev = tx_pkt.raw[0];
			default:
				s_axis_tx_tdata_rev = 64'b0;
		endcase
	end
end
always_comb s_axis_tx_tdata = endian_conv64(s_axis_tx_tdata_rev);

// tkeep
always_comb begin
	if (tx_state == TX_SEND) begin
		case (txcnt)
			27'h0: s_axis_tx_tkeep = 8'b1111_1111;
			27'h1: s_axis_tx_tkeep = 8'b1111_1111;
			27'h2: s_axis_tx_tkeep = 8'b1111_1111;
			27'h3: s_axis_tx_tkeep = 8'b1111_1111;
			27'h4: s_axis_tx_tkeep = 8'b1111_1111;
			27'h5: s_axis_tx_tkeep = 8'b1111_1111;
			27'h6: s_axis_tx_tkeep = 8'b1111_1111;
			27'h7: s_axis_tx_tkeep = 8'b0000_1111;
			default:
				s_axis_tx_tkeep = 8'b0;
		endcase
	end
end

// tlast
always_comb s_axis_tx_tlast = (txcnt == 7);

// tvalid
always_comb s_axis_tx_tvalid = (tx_state == TX_SEND);

endmodule

