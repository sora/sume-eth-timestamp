`timescale 1ns / 1ps

module eth_mac_conf #(
	parameter SRC_MAC = 48'h001122334455
)(
	output wire [79:0] mac_tx_configuration_vector,
	output wire [79:0] mac_rx_configuration_vector
);

    //Tx Configuration
    assign mac_tx_configuration_vector [79:32] = SRC_MAC;  
    assign mac_tx_configuration_vector [30:16] = 1518;
    assign mac_tx_configuration_vector [14] = 0; 
    assign mac_tx_configuration_vector [10] = 0; 
    assign mac_tx_configuration_vector [9] = 0;            
    assign mac_tx_configuration_vector [8] = 0;            
    assign mac_tx_configuration_vector [7] = 0;            
    assign mac_tx_configuration_vector [5] = 0;             
    assign mac_tx_configuration_vector [4] = 1;             
    assign mac_tx_configuration_vector [3] = 0;             
    assign mac_tx_configuration_vector [2] = 1;            
    assign mac_tx_configuration_vector [1] = 1;             
    assign mac_tx_configuration_vector [0] = 0;
    
    //Tx Configuration
    assign mac_rx_configuration_vector [79:32] = SRC_MAC; 
    assign mac_rx_configuration_vector [30:16] = 1518;     
    assign mac_rx_configuration_vector [14] = 0;           
    assign mac_rx_configuration_vector [10] = 0;           
    assign mac_rx_configuration_vector [9] = 1;             
    assign mac_rx_configuration_vector [8] = 1;            
    assign mac_rx_configuration_vector [7] = 0;             
    assign mac_rx_configuration_vector [5] = 0;            
    assign mac_rx_configuration_vector [4] = 1;            
    assign mac_rx_configuration_vector [3] = 0;             
    assign mac_rx_configuration_vector [2] = 1;
    assign mac_rx_configuration_vector [1] = 1;
    assign mac_rx_configuration_vector [0] = 0;

    //Unused bits to 0
    assign mac_tx_configuration_vector [31] = 1'b0;
    assign mac_tx_configuration_vector [15] = 1'b0;
    assign mac_tx_configuration_vector [13:11] = 3'b0;
    assign mac_tx_configuration_vector [6] = 1'b0; 

    assign mac_rx_configuration_vector [31] = 1'b0;
    assign mac_rx_configuration_vector [15] = 1'b0;
    assign mac_rx_configuration_vector [13:11] = 3'b0;
    assign mac_rx_configuration_vector [6] = 1'b0; 

endmodule

