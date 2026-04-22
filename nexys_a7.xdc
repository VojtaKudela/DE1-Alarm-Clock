## This file is a general .xdc for the Nexys A7-50T
## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK100MHZ}];

##Switches
set_property -dict { PACKAGE_PIN J15    IOSTANDARD LVCMOS33 } [get_ports { SW[0] }]; #IO_L24N_T3_RS0_15 Sch=sw[0]
#set_property -dict { PACKAGE_PIN L16    IOSTANDARD LVCMOS33 } [get_ports { SW[1] }]; 
#set_property -dict { PACKAGE_PIN M13    IOSTANDARD LVCMOS33 } [get_ports { SW[2] }]; 
#set_property -dict { PACKAGE_PIN R15    IOSTANDARD LVCMOS33 } [get_ports { SW[3] }]; 
#set_property -dict { PACKAGE_PIN R17    IOSTANDARD LVCMOS33 } [get_ports { SW[4] }]; 
#set_property -dict { PACKAGE_PIN T18    IOSTANDARD LVCMOS33 } [get_ports { SW[5] }]; 
#set_property -dict { PACKAGE_PIN U18    IOSTANDARD LVCMOS33 } [get_ports { SW[6] }]; 
#set_property -dict { PACKAGE_PIN R13    IOSTANDARD LVCMOS33 } [get_ports { SW[7] }]; 
#set_property -dict { PACKAGE_PIN T8     IOSTANDARD LVCMOS18 } [get_ports { SW[8] }]; 
#set_property -dict { PACKAGE_PIN U8     IOSTANDARD LVCMOS18 } [get_ports { SW[9] }]; 
#set_property -dict { PACKAGE_PIN R16    IOSTANDARD LVCMOS33 } [get_ports { SW[10] }]; 
#set_property -dict { PACKAGE_PIN T13    IOSTANDARD LVCMOS33 } [get_ports { SW[11] }]; 
#set_property -dict { PACKAGE_PIN H6     IOSTANDARD LVCMOS33 } [get_ports { SW[12] }]; 
#set_property -dict { PACKAGE_PIN U12    IOSTANDARD LVCMOS33 } [get_ports { SW[13] }]; 
#set_property -dict { PACKAGE_PIN U11    IOSTANDARD LVCMOS33 } [get_ports { SW[14] }]; 
#set_property -dict { PACKAGE_PIN V10    IOSTANDARD LVCMOS33 } [get_ports { SW[15] }]; 

## LEDs
set_property -dict { PACKAGE_PIN H17    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; #IO_L18P_T2_A24_15 Sch=led[0]
set_property -dict { PACKAGE_PIN K15    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; #IO_L24P_T3_RS1_15 Sch=led[1]
#set_property -dict { PACKAGE_PIN J13    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; 
#set_property -dict { PACKAGE_PIN N14    IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; 
#set_property -dict { PACKAGE_PIN R18    IOSTANDARD LVCMOS33 } [get_ports { LED[4] }]; 
#set_property -dict { PACKAGE_PIN V17    IOSTANDARD LVCMOS33 } [get_ports { LED[5] }]; 
#set_property -dict { PACKAGE_PIN U17    IOSTANDARD LVCMOS33 } [get_ports { LED[6] }]; 
#set_property -dict { PACKAGE_PIN U16    IOSTANDARD LVCMOS33 } [get_ports { LED[7] }]; 
#set_property -dict { PACKAGE_PIN V16    IOSTANDARD LVCMOS33 } [get_ports { LED[8] }]; 
#set_property -dict { PACKAGE_PIN T15    IOSTANDARD LVCMOS33 } [get_ports { LED[9] }]; 
#set_property -dict { PACKAGE_PIN U14    IOSTANDARD LVCMOS33 } [get_ports { LED[10] }]; 
#set_property -dict { PACKAGE_PIN T16    IOSTANDARD LVCMOS33 } [get_ports { LED[11] }]; 
#set_property -dict { PACKAGE_PIN V15    IOSTANDARD LVCMOS33 } [get_ports { LED[12] }]; 
#set_property -dict { PACKAGE_PIN V14    IOSTANDARD LVCMOS33 } [get_ports { LED[13] }]; 
#set_property -dict { PACKAGE_PIN V12    IOSTANDARD LVCMOS33 } [get_ports { LED[14] }]; 
#set_property -dict { PACKAGE_PIN V11    IOSTANDARD LVCMOS33 } [get_ports { LED[15] }]; 

##7 segment display
set_property -dict { PACKAGE_PIN T10    IOSTANDARD LVCMOS33 } [get_ports { CA }]; #IO_L24N_T3_A00_D16_14 Sch=ca
set_property -dict { PACKAGE_PIN R10    IOSTANDARD LVCMOS33 } [get_ports { CB }]; #IO_25_14 Sch=cb
set_property -dict { PACKAGE_PIN K16    IOSTANDARD LVCMOS33 } [get_ports { CC }]; #IO_25_15 Sch=cc
set_property -dict { PACKAGE_PIN K13    IOSTANDARD LVCMOS33 } [get_ports { CD }]; #IO_L17P_T2_A26_15 Sch=cd
set_property -dict { PACKAGE_PIN P15    IOSTANDARD LVCMOS33 } [get_ports { CE }]; #IO_L13P_T2_MRCC_14 Sch=ce
set_property -dict { PACKAGE_PIN T11    IOSTANDARD LVCMOS33 } [get_ports { CF }]; #IO_L19P_T3_A10_D26_14 Sch=cf
set_property -dict { PACKAGE_PIN L18    IOSTANDARD LVCMOS33 } [get_ports { CG }]; #IO_L4P_T0_D04_14 Sch=cg
set_property -dict { PACKAGE_PIN H15    IOSTANDARD LVCMOS33 } [get_ports { DP }]; #IO_L19N_T3_A21_VREF_15 Sch=dp
set_property -dict { PACKAGE_PIN J17    IOSTANDARD LVCMOS33 } [get_ports { AN[0] }]; #IO_L23P_T3_FOE_B_15 Sch=an[0]
set_property -dict { PACKAGE_PIN J18    IOSTANDARD LVCMOS33 } [get_ports { AN[1] }]; #IO_L23N_T3_FWE_B_15 Sch=an[1]
set_property -dict { PACKAGE_PIN T9     IOSTANDARD LVCMOS33 } [get_ports { AN[2] }]; #IO_L24P_T3_A01_D17_14 Sch=an[2]
set_property -dict { PACKAGE_PIN J14    IOSTANDARD LVCMOS33 } [get_ports { AN[3] }]; #IO_L19P_T3_A22_15 Sch=an[3]
set_property -dict { PACKAGE_PIN P14    IOSTANDARD LVCMOS33 } [get_ports { AN[4] }]; #IO_L8N_T1_D12_14 Sch=an[4]
set_property -dict { PACKAGE_PIN T14    IOSTANDARD LVCMOS33 } [get_ports { AN[5] }]; #IO_L14P_T2_SRCC_14 Sch=an[5]
set_property -dict { PACKAGE_PIN K2     IOSTANDARD LVCMOS33 } [get_ports { AN[6] }]; #IO_L23P_T3_35 Sch=an[6]
set_property -dict { PACKAGE_PIN U13    IOSTANDARD LVCMOS33 } [get_ports { AN[7] }]; #IO_L23N_T3_A02_D18_14 Sch=an[7]

##Buttons
set_property -dict { PACKAGE_PIN N17    IOSTANDARD LVCMOS33 } [get_ports { BTNC }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN M18    IOSTANDARD LVCMOS33 } [get_ports { BTNU }]; #IO_L4N_T0_D05_14 Sch=btnu
set_property -dict { PACKAGE_PIN P17    IOSTANDARD LVCMOS33 } [get_ports { BTNL }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17    IOSTANDARD LVCMOS33 } [get_ports { BTNR }]; #IO_L10N_T1_D15_14 Sch=btnr
set_property -dict { PACKAGE_PIN P18    IOSTANDARD LVCMOS33 } [get_ports { BTND }]; #IO_L9N_T1_DQS_D13_14 Sch=btnd

##PWM Audio Amplifier
set_property -dict { PACKAGE_PIN A11    IOSTANDARD LVCMOS33 } [get_ports { AUD_PWM }]; #IO_L4N_T0_15 Sch=aud_pwm
#set_property -dict { PACKAGE_PIN D12    IOSTANDARD LVCMOS33 } [get_ports { AUD_SD }]; #IO_L6P_T0_15 Sch=aud_sd