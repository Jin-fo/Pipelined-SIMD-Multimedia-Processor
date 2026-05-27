## Basys 3 FPGA Constraint File
## Generated from pin assignment table

## ============================================================
## 7-Segment Display - Segments (active low)
## ============================================================
set_property PACKAGE_PIN W7  [get_ports {reg_seven[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_seven[0]}]

set_property PACKAGE_PIN W6  [get_ports {reg_seven[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_seven[1]}]

set_property PACKAGE_PIN U8  [get_ports {reg_seven[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_seven[2]}]

set_property PACKAGE_PIN V8  [get_ports {reg_seven[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_seven[3]}]

set_property PACKAGE_PIN U5  [get_ports {reg_seven[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_seven[4]}]

set_property PACKAGE_PIN V5  [get_ports {reg_seven[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_seven[5]}]

set_property PACKAGE_PIN U7  [get_ports {reg_seven[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_seven[6]}]

# =============================================================
# 7-Segment Display - Anode Controls (active low)
# =============================================================
set_property PACKAGE_PIN U2   [get_ports {led_ctrl[0]}]   ;# AN0
set_property PACKAGE_PIN U4   [get_ports {led_ctrl[1]}]   ;# AN1
set_property PACKAGE_PIN V4   [get_ports {led_ctrl[2]}]   ;# AN2
set_property PACKAGE_PIN W4   [get_ports {led_ctrl[3]}]   ;# AN3

set_property IOSTANDARD LVCMOS33 [get_ports {led_ctrl[*]}]

## ============================================================
## Inputs - reg_pos (8-bit)
## ============================================================
set_property PACKAGE_PIN W13 [get_ports {reg_pos[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[7]}]

set_property PACKAGE_PIN W14 [get_ports {reg_pos[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[6]}]

set_property PACKAGE_PIN V15 [get_ports {reg_pos[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[5]}]

set_property PACKAGE_PIN W15 [get_ports {reg_pos[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[4]}]

set_property PACKAGE_PIN W17 [get_ports {reg_pos[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[3]}]

set_property PACKAGE_PIN W16 [get_ports {reg_pos[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[2]}]

set_property PACKAGE_PIN V16 [get_ports {reg_pos[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[1]}]

set_property PACKAGE_PIN V17 [get_ports {reg_pos[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_pos[0]}]

## ============================================================
## Outputs - reg_value (16-bit)
## ============================================================
set_property PACKAGE_PIN L1 [get_ports {reg_value[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[15]}]

set_property PACKAGE_PIN P1 [get_ports {reg_value[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[14]}]

set_property PACKAGE_PIN N3 [get_ports {reg_value[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[13]}]

set_property PACKAGE_PIN P3 [get_ports {reg_value[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[12]}]

set_property PACKAGE_PIN U3 [get_ports {reg_value[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[11]}]

set_property PACKAGE_PIN W3 [get_ports {reg_value[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[10]}]

set_property PACKAGE_PIN V3 [get_ports {reg_value[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[9]}]

set_property PACKAGE_PIN V13 [get_ports {reg_value[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[8]}]

set_property PACKAGE_PIN V14 [get_ports {reg_value[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[7]}]

set_property PACKAGE_PIN U14 [get_ports {reg_value[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[6]}]

set_property PACKAGE_PIN U15 [get_ports {reg_value[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[5]}]

set_property PACKAGE_PIN W18 [get_ports {reg_value[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[4]}]

set_property PACKAGE_PIN V19 [get_ports {reg_value[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[3]}]

set_property PACKAGE_PIN U19 [get_ports {reg_value[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[2]}]

set_property PACKAGE_PIN E19 [get_ports {reg_value[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[1]}]

set_property PACKAGE_PIN U16 [get_ports {reg_value[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_value[0]}]

## ============================================================
## Scalar Ports
## ============================================================
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN T1 [get_ports enable]
set_property IOSTANDARD LVCMOS33 [get_ports enable]

set_property PACKAGE_PIN U18 [get_ports reg_tog]
set_property IOSTANDARD LVCMOS33 [get_ports reg_tog]

set_property PACKAGE_PIN R2 [get_ports reset_bar]
set_property IOSTANDARD LVCMOS33 [get_ports reset_bar]

## ============================================================
## Clock Constraint (100 MHz onboard clock on W5)
## ============================================================
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

