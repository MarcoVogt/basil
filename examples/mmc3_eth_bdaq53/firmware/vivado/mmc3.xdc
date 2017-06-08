
create_clock -period 10.000 -name clkin         -add [get_ports clkin]
create_clock -period 8.000  -name rgmii_rxc     -add [get_ports rgmii_rxc]
create_clock -period 7.813  -name RX_CLK_P      -add [get_ports RX_CLK_P]
create_clock -period 8.000  -name RX_INIT_CLK_P -add [get_ports RX_INIT_CLK_P]


#set_false_path -from [get_clocks BUS_CLK_PLL]   -to [get_clocks CLK125PLLTX]
#set_false_path -from [get_clocks CLK125PLLTX]   -to [get_clocks BUS_CLK_PLL]

#set_false_path -from [get_clocks BUS_CLK_PLL]   -to [get_clocks rgmii_rxc]
#set_false_path -from [get_clocks rgmii_rxc]     -to [get_clocks BUS_CLK_PLL]

set_false_path -from [get_clocks BUS_CLK_PLL]   -to [get_clocks CLKCMDPLL]
set_false_path -from [get_clocks CLKCMDPLL]     -to [get_clocks BUS_CLK_PLL]

set_false_path -from [get_clocks BUS_CLK_PLL]   -to [get_clocks user_clk_i]
set_false_path -from [get_clocks user_clk_i]    -to [get_clocks BUS_CLK_PLL]


#Oscillator 100MHz
set_property PACKAGE_PIN AA3 [get_ports clkin]
set_property IOSTANDARD LVCMOS15 [get_ports clkin]

#Oscillator 200MHz
#set_property PACKAGE_PIN AC18 [get_ports CLK200_P]
#set_property PACKAGE_PIN AD18 [get_ports CLK200_N]
#set_property IOSTANDARD LVDS DIFF_TERM FALSE [get_ports CLK200_*]


#SITCP
set_property PACKAGE_PIN C18 [get_ports RESET_N]
set_property IOSTANDARD LVCMOS33 [get_ports RESET_N]
set_property PULLUP true [get_ports RESET_N]

set_property SLEW FAST [get_ports mdio_phy_mdc]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_phy_mdc]
set_property PACKAGE_PIN N16 [get_ports mdio_phy_mdc]

set_property SLEW FAST [get_ports mdio_phy_mdio]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_phy_mdio]
set_property PACKAGE_PIN U16 [get_ports mdio_phy_mdio]

set_property SLEW FAST [get_ports phy_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports phy_rst_n]
set_property PACKAGE_PIN M20 [get_ports phy_rst_n]

set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rxc]
set_property PACKAGE_PIN R21 [get_ports rgmii_rxc]

set_property IOSTANDARD LVCMOS33 [get_ports rgmii_rx_ctl]
set_property PACKAGE_PIN P21 [get_ports rgmii_rx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN P16 [get_ports {rgmii_rxd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[1]}]
set_property PACKAGE_PIN N17 [get_ports {rgmii_rxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN R16 [get_ports {rgmii_rxd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN R17 [get_ports {rgmii_rxd[3]}]

set_property SLEW FAST [get_ports rgmii_txc]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_txc]
set_property PACKAGE_PIN R18 [get_ports rgmii_txc]

set_property SLEW FAST [get_ports rgmii_tx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports rgmii_tx_ctl]
set_property PACKAGE_PIN P18 [get_ports rgmii_tx_ctl]

set_property SLEW FAST [get_ports {rgmii_txd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[0]}]
set_property PACKAGE_PIN N18 [get_ports {rgmii_txd[0]}]
set_property SLEW FAST [get_ports {rgmii_txd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN M19 [get_ports {rgmii_txd[1]}]
set_property SLEW FAST [get_ports {rgmii_txd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN U17 [get_ports {rgmii_txd[2]}]
set_property SLEW FAST [get_ports {rgmii_txd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[3]}]
set_property PACKAGE_PIN T17 [get_ports {rgmii_txd[3]}]


# Aurora related signals
set_property IOSTANDARD LVDS [get_ports RX_CLK_*]
set_property PACKAGE_PIN D6  [get_ports RX_CLK_P]
set_property PACKAGE_PIN D5  [get_ports RX_CLK_N]

set_property IOSTANDARD LVDS [get_ports RX_INIT_CLK_*]
set_property DIFF_TERM FALSE [get_ports RX_INIT_CLK_*]
set_property PACKAGE_PIN AC18 [get_ports RX_INIT_CLK_P]
set_property PACKAGE_PIN AD18 [get_ports RX_INIT_CLK_N]

#set_property IOSTANDARD LVDS [get_ports AURORA_RX_*]
set_property PACKAGE_PIN G4  [get_ports AURORA_RX_P[0]]
set_property PACKAGE_PIN G3  [get_ports AURORA_RX_N[0]]


# Debug LEDs
set_property PACKAGE_PIN M17 [get_ports {LED[0]}]
set_property PACKAGE_PIN L18 [get_ports {LED[1]}]
set_property PACKAGE_PIN L17 [get_ports {LED[2]}]
set_property PACKAGE_PIN K18 [get_ports {LED[3]}]
set_property PACKAGE_PIN P26 [get_ports {LED[4]}]
set_property PACKAGE_PIN M25 [get_ports {LED[5]}]
set_property PACKAGE_PIN L25 [get_ports {LED[6]}]
set_property PACKAGE_PIN P23 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports LED*]
set_property SLEW SLOW [get_ports LED*]


# CMD encoder CLK (40 pin connector, IO_2_[P,N] = IO_[2,3],  Pin[7,8], Mercury: B[84,86] = IO_B16_L16_[G12_P,F12_N])
#set_property PACKAGE_PIN G12 [get_ports CMD_CLK_P]
#set_property PACKAGE_PIN F12 [get_ports CMD_CLK_N]
# CMD encoder DATA (40 pin connector, IO_10_[P,N] = IO_[10,11], Pin[9,10], Mercury: B[72,74 = IO_B16_L7_[F9_P,F8_N])
#set_property PACKAGE_PIN F9 [get_ports CMD_DATA_P]
#set_property PACKAGE_PIN F8 [get_ports CMD_DATA_N]
#set_property IOSTANDARD LVDS [get_ports CMD_*]

# CMD encoder CLK at LEMO "TX0"
set_property PACKAGE_PIN AB21 [get_ports LEMO_TX0_CMD_CLK]
# CMD encoder CLK at LEMO "TX1"
set_property PACKAGE_PIN V23 [get_ports LEMO_TX0_CMD_DATA]
set_property IOSTANDARD LVCMOS33 [get_ports LEMO_TX0_CMD_*]
set_property SLEW FAST [get_ports LEMO_TX0_CMD_*]

