`timescale 1ns / 1ps

module top (
	input  logic FPGA_SYSCLK_N,
	input  logic FPGA_SYSCLK_P,
	input  logic SFP_CLK_P,
	input  logic SFP_CLK_N,
	output logic SFP_REC_CLK_P,
	output logic SFP_REC_CLK_N,

	input  logic ETH1_TX_P,
	input  logic ETH1_TX_N,
	output logic ETH1_RX_P,
	output logic ETH1_RX_N,

	inout logic I2C_FPGA_SCL,
	inout logic I2C_FPGA_SDA,

	input logic SFP_CLK_ALARM_B,

	input  logic ETH1_TX_FAULT,
	input  logic ETH1_RX_LOS,
	output logic ETH1_TX_DISABLE,

	// ETH1_LED[1:0], ETH2_LED[1:0], ETH3_LED[1:0], ETH4_LED[1:0]
	output logic [7:0] led
);

logic refclk200;
IBUFDS #(
	.CAPACITANCE("DONT_CARE"),
	.DIFF_TERM("FALSE"),
	.IBUF_DELAY_VALUE("0"),
	.IFD_DELAY_VALUE("AUTO"),
	.IOSTANDARD("DEFAULT")
) ibufds_fpga_sysclk (
	.O(clk200),
	.I(FPGA_SYSCLK_P),
	.IB(FPGA_SYSCLK_N)
);

logic clk100, clk156;
logic [1:0] clock_divide;
always_ff @(posedge clk200)
	clock_divide <= clock_divide + 2'b1;
BUFG buffer_clk100 (
	.I(clock_divide[0]),
	.O(clk100)
);

// sys_rst
logic sys_rst;
logic [13:0] cold_counter;
logic cold_reset;
always_ff @(posedge clk200) begin
	if (cold_counter[13] != 1'd1) begin
		cold_reset <= 1'b1;
		cold_counter <= cold_counter + 14'd1;
	end else
		cold_reset <= 1'b0;
end
always_comb sys_rst = cold_reset;


// sfp_refclk_init
sfp_refclk_init sfp_refclk_init0 (
	.CLK(clk100),
	.RST(sys_rst),
	.*
);

// pcs_pma_conf
logic [535:0] pcs_pma_configuration_vector;
pcs_pma_conf pcs_pma_conf0(.*);

// eth_mac_conf
logic [79:0] mac_tx_configuration_vector;
logic [79:0] mac_rx_configuration_vector;
eth_mac_conf eth_mac_conf0(.*);

// 10 subsystem
wire txusrclk_out;
wire txusrclk2_out;
wire gttxreset_out;
wire gtrxreset_out;
wire txuserrdy_out;
wire areset_datapathclk_out;
wire reset_counter_done_out;
wire qplllock_out;
wire qplloutclk_out;
wire qplloutrefclk_out;

wire s_axis_tx_tvalid;
wire s_axis_tx_tready;
wire [63:0] s_axis_tx_tdata;
wire [7:0] s_axis_tx_tkeep;
wire s_axis_tx_tlast;
wire s_axis_tx_tuser = 1'b0;

wire [447:0] pcs_pma_status_vector;
wire [1:0] mac_status_vector;
wire [7:0] pcspma_status;
wire rx_statistics_valid;
wire tx_statistics_valid;

// eth_send
eth_send eth_send0 (
//	.clk156(clk200),
	.clk156(clk156),
	.reset(sys_rst),
	.*
);

wire        m_axis_tx_tvalid;
wire        m_axis_tx_tready;
wire [63:0] m_axis_tx_tdata;
wire [ 7:0] m_axis_tx_tkeep;
wire        m_axis_tx_tlast;
wire        m_axis_tx_tuser;

//pcie2eth_fifo pcie2eth_fifo0 (
//	.s_aresetn(~sys_rst),

//	// data in (pcie)
//	.s_aclk(clk200),
//	.s_axis_tvalid(s_axis_tx_tvalid),
//	.s_axis_tready(s_axis_tx_tready),
//	.s_axis_tdata (s_axis_tx_tdata),
//	.s_axis_tkeep (s_axis_tx_tkeep),
//	.s_axis_tlast (s_axis_tx_tlast),
//	.s_axis_tuser (s_axis_tx_tuser),

//	// data out(eth)
//	.m_aclk(clk156),
//	.m_axis_tvalid(m_axis_tx_tvalid),
//	.m_axis_tready(m_axis_tx_tready),
//	.m_axis_tdata (m_axis_tx_tdata),
//	.m_axis_tkeep (m_axis_tx_tkeep),
//	.m_axis_tlast (m_axis_tx_tlast),
//	.m_axis_tuser (m_axis_tx_tuser),
//	.*
//);

axi_10g_ethernet_0 axi_10g_ethernet_0_ins (
	.coreclk_out(clk156),
	.refclk_n(SFP_CLK_N),
	.refclk_p(SFP_CLK_P),
	.dclk(clk156),
	.reset(sys_rst),
	.rx_statistics_vector(),
	.rxn(ETH1_TX_N),
	.rxp(ETH1_TX_P),
	.s_axis_pause_tdata(16'b0),
	.s_axis_pause_tvalid(1'b0),
	.signal_detect(!ETH1_RX_LOS),
	.tx_disable(ETH1_TX_DISABLE),
	.tx_fault(ETH1_TX_FAULT),
	.tx_ifg_delay(8'd8),
	.tx_statistics_vector(),
	.txn(ETH1_RX_N),
	.txp(ETH1_RX_P),

	.rxrecclk_out(),
	.resetdone_out(),

	// eth tx
//	.s_axis_tx_tready(m_axis_tx_tready),
//	.s_axis_tx_tdata (m_axis_tx_tdata),
//	.s_axis_tx_tkeep (m_axis_tx_tkeep),
//	.s_axis_tx_tlast (m_axis_tx_tlast),
//	.s_axis_tx_tvalid(m_axis_tx_tvalid),
//	.s_axis_tx_tuser (m_axis_tx_tuser),
	
	// eth rx
	.m_axis_rx_tdata(),
	.m_axis_rx_tkeep(),
	.m_axis_rx_tlast(),
	.m_axis_rx_tuser(),
	.m_axis_rx_tvalid(),

	.sim_speedup_control(1'b0),
	.rx_axis_aresetn(1'b1),
	.tx_axis_aresetn(1'b1),

	.*
);

logic [27:0] led_count;
always_ff @(posedge clk156) begin
	if (sys_rst) begin
		led_count <= 28'd0;
		led <= 8'd0;
	end else begin
		led_count <= led_count + 28'd1;
		led[6:0] <= 7'b011_0011;
		if (led_count[27] == 1'b1) begin
			led[7] = ~led[7];
		end
	end
end

endmodule

