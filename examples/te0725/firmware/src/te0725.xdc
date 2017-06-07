create_clock -period 10.000 -name SYS_CLK -waveform {0.000 5.000}

#
# Clock 100 MHz
#
set_property PACKAGE_PIN P17 [get_ports SYS_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports SYS_CLK]

#
# On-board Green LED
#
set_property PACKAGE_PIN M16 [get_ports LED]
set_property IOSTANDARD LVCMOS33 [get_ports LED]


#
# UART in 2x6 XMOD connector
#
set_property IOSTANDARD LVCMOS33 [get_ports UART_RX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TX]
set_property PACKAGE_PIN M18 [get_ports UART_RX]
set_property PACKAGE_PIN L18 [get_ports UART_TX]
set_property PULLUP true [get_ports UART_RX]


#
# I²C EEPROM
#

#
# SPI
#


#
# HyperRAM
#
#
set_property IOSTANDARD LVCMOS18 [get_ports H1_*]
#
set_property PACKAGE_PIN E17 [get_ports {H1_D[0]}]
set_property PACKAGE_PIN B17 [get_ports {H1_D[1]}]
set_property PACKAGE_PIN F18 [get_ports {H1_D[2]}]
set_property PACKAGE_PIN F16 [get_ports {H1_D[3]}]
set_property PACKAGE_PIN G17 [get_ports {H1_D[4]}]
set_property PACKAGE_PIN D18 [get_ports {H1_D[5]}]
set_property PACKAGE_PIN B18 [get_ports {H1_D[6]}]
set_property PACKAGE_PIN A16 [get_ports {H1_D[7]}]

set_property PACKAGE_PIN A13 [get_ports H1_CLK_P]
set_property PACKAGE_PIN A14 [get_ports H1_CLK_N]

set_property PACKAGE_PIN E18 [get_ports H1_RWDS]
set_property PACKAGE_PIN J17 [get_ports H1_RESET_N]
set_property PACKAGE_PIN A18 [get_ports H1_CS]


#
#  J1 Header, Bank 35
#
set_property IOSTANDARD LVCMOS33 [get_ports USER_RESET]
# J1_Pin[0]
set_property PACKAGE_PIN K1 [get_ports USER_RESET]

#set_property IOSTANDARD LVCMOS33 [get_ports {j1_tri_io[*]}]
#
# set_property PACKAGE_PIN K1 [get_ports {j1_tri_io[0]}]
#set_property PACKAGE_PIN K2 [get_ports {j1_tri_io[1]}]
#set_property PACKAGE_PIN G2 [get_ports {j1_tri_io[2]}]
#set_property PACKAGE_PIN H2 [get_ports {j1_tri_io[3]}]
#set_property PACKAGE_PIN F3 [get_ports {j1_tri_io[4]}]
#set_property PACKAGE_PIN F4 [get_ports {j1_tri_io[5]}]
#set_property PACKAGE_PIN D3 [get_ports {j1_tri_io[6]}]
#set_property PACKAGE_PIN E3 [get_ports {j1_tri_io[7]}]
#set_property PACKAGE_PIN J3 [get_ports {j1_tri_io[8]}]
#set_property PACKAGE_PIN J2 [get_ports {j1_tri_io[9]}]
#set_property PACKAGE_PIN G1 [get_ports {j1_tri_io[10]}]
#set_property PACKAGE_PIN H1 [get_ports {j1_tri_io[11]}]
#set_property PACKAGE_PIN E1 [get_ports {j1_tri_io[12]}]
#set_property PACKAGE_PIN F1 [get_ports {j1_tri_io[13]}]
#set_property PACKAGE_PIN D2 [get_ports {j1_tri_io[14]}]
#set_property PACKAGE_PIN E2 [get_ports {j1_tri_io[15]}]
#set_property PACKAGE_PIN C2 [get_ports {j1_tri_io[16]}]
#set_property PACKAGE_PIN C1 [get_ports {j1_tri_io[17]}]
#set_property PACKAGE_PIN A1 [get_ports {j1_tri_io[18]}]
#set_property PACKAGE_PIN B1 [get_ports {j1_tri_io[19]}]
#set_property PACKAGE_PIN B3 [get_ports {j1_tri_io[20]}]
#set_property PACKAGE_PIN B2 [get_ports {j1_tri_io[21]}]
#set_property PACKAGE_PIN A3 [get_ports {j1_tri_io[22]}]
#set_property PACKAGE_PIN A4 [get_ports {j1_tri_io[23]}]
#set_property PACKAGE_PIN D4 [get_ports {j1_tri_io[24]}]
#set_property PACKAGE_PIN D5 [get_ports {j1_tri_io[25]}]
#set_property PACKAGE_PIN A5 [get_ports {j1_tri_io[26]}]
#set_property PACKAGE_PIN A6 [get_ports {j1_tri_io[27]}]
#set_property PACKAGE_PIN B6 [get_ports {j1_tri_io[28]}]
#set_property PACKAGE_PIN B7 [get_ports {j1_tri_io[29]}]
#set_property PACKAGE_PIN B4 [get_ports {j1_tri_io[30]}]
#set_property PACKAGE_PIN C4 [get_ports {j1_tri_io[31]}]
#set_property PACKAGE_PIN C5 [get_ports {j1_tri_io[32]}]
#set_property PACKAGE_PIN C6 [get_ports {j1_tri_io[33]}]
#set_property PACKAGE_PIN E5 [get_ports {j1_tri_io[34]}]
#set_property PACKAGE_PIN E6 [get_ports {j1_tri_io[35]}]
#set_property PACKAGE_PIN D7 [get_ports {j1_tri_io[36]}]
#set_property PACKAGE_PIN E7 [get_ports {j1_tri_io[37]}]
#set_property PACKAGE_PIN G6 [get_ports {j1_tri_io[38]}]
#set_property PACKAGE_PIN F6 [get_ports {j1_tri_io[39]}]
#set_property PACKAGE_PIN C7 [get_ports {j1_tri_io[40]}]
#set_property PACKAGE_PIN D8 [get_ports {j1_tri_io[41]}]
#
#set_property PULLUP true [get_ports {j1_tri_io[*]}]



#
# J2 Header, Bank 34
#
#
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LED[*]}]
# J2_Pin[0]
set_property PACKAGE_PIN T8 [get_ports {GPIO_LED[0]}]
# J2_Pin[2]
set_property PACKAGE_PIN V9 [get_ports {GPIO_LED[1]}]
# J2_Pin[4]
set_property PACKAGE_PIN N6 [get_ports {GPIO_LED[2]}]
# J2_Pin[6]
set_property PACKAGE_PIN U6 [get_ports {GPIO_LED[3]}]


set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIP[*]}]
# J2_Pin[8]
set_property PACKAGE_PIN V6 [get_ports {GPIO_DIP[0]}]
# J2_Pin[10]
set_property PACKAGE_PIN T6 [get_ports {GPIO_DIP[1]}]
# J2_Pin[12]
set_property PACKAGE_PIN V4 [get_ports {GPIO_DIP[2]}]
# J2_Pin[14]
set_property PACKAGE_PIN R6 [get_ports {GPIO_DIP[3]}]

#set_property IOSTANDARD LVCMOS33 [get_ports {j2_tri_io[*]}]
#set_property PULLUP true [get_ports {j2_tri_io[*]}]
#
#
#
#set_property PACKAGE_PIN T8 [get_ports {j2_tri_io[0]}]
#set_property PACKAGE_PIN R8 [get_ports {j2_tri_io[1]}]
#set_property PACKAGE_PIN V9 [get_ports {j2_tri_io[2]}]
#set_property PACKAGE_PIN U9 [get_ports {j2_tri_io[3]}]
#set_property PACKAGE_PIN N6 [get_ports {j2_tri_io[4]}]
#set_property PACKAGE_PIN M6 [get_ports {j2_tri_io[5]}]
#set_property PACKAGE_PIN U6 [get_ports {j2_tri_io[6]}]
#set_property PACKAGE_PIN U7 [get_ports {j2_tri_io[7]}]
#set_property PACKAGE_PIN V6 [get_ports {j2_tri_io[8]}]
#set_property PACKAGE_PIN V7 [get_ports {j2_tri_io[9]}]
#set_property PACKAGE_PIN T6 [get_ports {j2_tri_io[10]}]
#set_property PACKAGE_PIN R7 [get_ports {j2_tri_io[11]}]
#set_property PACKAGE_PIN V4 [get_ports {j2_tri_io[12]}]
#set_property PACKAGE_PIN V5 [get_ports {j2_tri_io[13]}]
#set_property PACKAGE_PIN R6 [get_ports {j2_tri_io[14]}]
#set_property PACKAGE_PIN R5 [get_ports {j2_tri_io[15]}]
#set_property PACKAGE_PIN U3 [get_ports {j2_tri_io[16]}]
#set_property PACKAGE_PIN U4 [get_ports {j2_tri_io[17]}]
#set_property PACKAGE_PIN V2 [get_ports {j2_tri_io[18]}]
#set_property PACKAGE_PIN U2 [get_ports {j2_tri_io[19]}]
#set_property PACKAGE_PIN V1 [get_ports {j2_tri_io[20]}]
#set_property PACKAGE_PIN U1 [get_ports {j2_tri_io[21]}]
#set_property PACKAGE_PIN N5 [get_ports {j2_tri_io[22]}]
#set_property PACKAGE_PIN P5 [get_ports {j2_tri_io[23]}]
#set_property PACKAGE_PIN T5 [get_ports {j2_tri_io[24]}]
#set_property PACKAGE_PIN T4 [get_ports {j2_tri_io[25]}]
#set_property PACKAGE_PIN T3 [get_ports {j2_tri_io[26]}]
#set_property PACKAGE_PIN R3 [get_ports {j2_tri_io[27]}]
#set_property PACKAGE_PIN P4 [get_ports {j2_tri_io[28]}]
#set_property PACKAGE_PIN P3 [get_ports {j2_tri_io[29]}]
#set_property PACKAGE_PIN N4 [get_ports {j2_tri_io[30]}]
#set_property PACKAGE_PIN M4 [get_ports {j2_tri_io[31]}]
#set_property PACKAGE_PIN T1 [get_ports {j2_tri_io[32]}]
#set_property PACKAGE_PIN R1 [get_ports {j2_tri_io[33]}]
#set_property PACKAGE_PIN R2 [get_ports {j2_tri_io[34]}]
#set_property PACKAGE_PIN P2 [get_ports {j2_tri_io[35]}]
#set_property PACKAGE_PIN N1 [get_ports {j2_tri_io[36]}]
#set_property PACKAGE_PIN N2 [get_ports {j2_tri_io[37]}]
#set_property PACKAGE_PIN M1 [get_ports {j2_tri_io[38]}]
#set_property PACKAGE_PIN L1 [get_ports {j2_tri_io[39]}]


#set_property PACKAGE_PIN A10 [get_ports {LVDS_P[0]}]
#set_property IOSTANDARD LVDS_25 [get_ports {LVDS_P[0]}]

#set_property PACKAGE_PIN C11 [get_ports {LVDS_clk_p[0]}]
#set_property IOSTANDARD LVDS_25 [get_ports {LVDS_clk_p[0]}]



set_operating_conditions -airflow 0
set_operating_conditions -board_layers 4to7
set_operating_conditions -heatsink none
set_operating_conditions -board small
set_switching_activity -default_toggle_rate 20.000
create_clock -period 10.000 -name SYS_CLK_1 -waveform {0.000 5.000} [get_ports SYS_CLK]
