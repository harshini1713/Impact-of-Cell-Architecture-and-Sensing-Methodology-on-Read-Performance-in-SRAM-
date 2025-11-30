********************************************************************************
*** Differential Current-Sense Amplifier Subcircuit
********************************************************************************
*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp

.subckt sense_amp BL BLB SAEN OUT VDD VSS

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

* Reference current generator
R1 vrefgen grefgen 'Vread/(I_ref)'
Vrefgen vrefgen 0 'Vread'
Vrefgnd grefgen 0 0

* Tail PFET current source
XMp_current_source n_tail SAEN VDD VDD pfet1 w='w_p'

* Input branches from BL and BLB
XMp_left_amp1 n_common BL n_tail VDD pfet1 w='w_p'
XMp_right_amp1 n_sense BLB n_tail VDD pfet1 w='w_p'

XMn_left_amp1 n_common n_common ns_left 0 nfet1 w='w_n'
XMn_right_amp1 n_sense n_common ns_right 0 nfet1 w='0.9*w_n'

v_left_branch1 ns_left ns 0
v_right_branch1 ns_right ns 0
V_tail_I1 ns 0 0

********************************************************************************
* Simple CMOS inverter stage
********************************************************************************
.subckt inverter_stage in out vss vdd
XMp out in vdd vdd pfet1 w='w_p'
XMn out in vss vss nfet1 w='w_n'
.ends inverter_stage


* Output inverter chain
Xinv_1bl n_sense n_output_ 0 VDD inverter_stage w_n='w_n' w_p='w_p'
Xinv_2bl n_output_ OUT 0 VDD inverter_stage w_n='w_n' w_p='w_p'

.ends sense_amp

