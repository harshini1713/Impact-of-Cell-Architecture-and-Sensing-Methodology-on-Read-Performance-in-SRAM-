********************************************************************************
*** Differential Current-Sense Amplifier Subcircuit
********************************************************************************
*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp

.subckt sense_amp BL BLB SE Q VDD VSS

.param T_start=200p
.param T_end=2ns
.param T_rf=160p
.param lambda='11n'
.param w_n='3*lambda'
.param w_p='3*lambda'
.param Vread=0.4
.param pvdd=0.8
.param I_ref=2.3u
.param I_cellbl=3.8u


********************************************************************************
* M5: Tail Current Source (NMOS)
* In the image, M5 is an NMOS connected to Ground controlled by SE.
********************************************************************************
XMn_5 n_tail SE VSS VSS nfet1 w='w_n'

********************************************************************************
* Differential Input Pair (NMOS)
* M1: Connected to 'bit' (BL)
* M2: Connected to 'bit_bar' (BLB)
********************************************************************************
XMn_1 n_common BL n_tail VSS nfet1 w='w_n'
XMn_2 node_y   BLB n_tail VSS nfet1 w='w_n'

********************************************************************************
* Active Current Mirror Load (PMOS)
* M3: Left side, Gate connected to Drain
* M4: Right side, Gate connected to M3's Gate
********************************************************************************
* Note: M3 Drain and Gate are connected at 'n_common'
XMp_3 n_common n_common VDD VDD pfet1 w='w_p'

* Note: M4 outputs to node 'y' (node_y)
XMp_4 node_y   n_common VDD VDD pfet1 w='0.9 * w_p'

********************************************************************************
* Output Inverter Stage
* Takes the analog signal from 'y' and squares it to full logic levels at 'OUT'
********************************************************************************
Xinverter1 node_y node_x VSS VDD inverter_stage
Xinverter2 node_x Q VSS VDD inverter_stage

.ends sense_amp

********************************************************************************
* Simple CMOS inverter stage 
********************************************************************************
.subckt inverter_stage in out vss vdd
XMp out in vdd vdd pfet1 w='66n'
XMn out in vss vss nfet1 w='33n'
.ends inverter_stage
