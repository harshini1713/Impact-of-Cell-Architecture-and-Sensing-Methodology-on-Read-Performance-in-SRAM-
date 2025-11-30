*********************************************************************************
************************************************************************************
********************************For Ref Gen******************************
************************************************************************************


**********************************************************************************

.lib '../FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp

************************************************************************************
********************************All values in SI units******************************
************************************************************************************

.param T_start=200p
.param T_end=2ns
.param T_rf= 160p

.param lambda='11n'
.param w_n='3*lambda'
.param w_p='3*lambda'

************************************************************************************

*****for read**********

.param I_cellbl = 3.8u

*************************

.param I_ref = 2.3u

.param bias= 0.0

.param pvdd= 0.8
*Change to 0.8 and 0.4 for near memory
.param Vread= 0.4

**************************Reference Current Generation*******************************
************************************************************************************
************************************************************************************
************************************************************************************

R1 vrefgen grefgen 'Vread/(I_ref)'

Vrefgen vrefgen 0 'Vread'
Vrefgnd grefgen 0 0

************************************************************************************
************************************************************************************
************************************************************************************
************************************************************************************
************************************************************************************
***                           Netlist                              *****************
************************************************************************************

.subckt inverter_stage in out gnd vdd w_n='w_n' w_p='w_n'
XMp_inverter out in vdd vdd pfet1 w='w_p'
XMn_inverter out in 0 0 nfet1 w='w_n'
.ends

v_bias n_bias 0 'bias'

XMp_current_source n_tail sen_enbb n_vdd n_vdd pfet1 w='w_p'

*******************BL current****************

I_cell n_cell_ 0 PWL (0 0 'T_start' 0 'T_start+T_rf' 'I_cellbl' 'T_end' 'I_cellbl' 'T_end+T_rf' 0)
V_cell_I n_cell n_cell_ 0
XMp_miror_in n_cell n_cell n_vdd n_vdd pfet1 w='w_p'
Xnbl n_vdd sen_enb n_cell n_vdd pfet1 w='w_p'

*******************Ref current****************

I_ref n_ref_ 0 PWL (0 0 'T_start' 0 'T_start+T_rf' 'I_ref' 'T_end' 'I_ref' 'T_end+T_rf' 0)
V_ref_I n_ref n_ref_ 0
XMp_miror_in_ref n_ref n_ref n_vddr n_vddr pfet1 w='w_p'
Xnref n_vddr sen_enb n_ref n_vddr pfet1 w='w_p'


*****************first sense amp*****************

XMp_left_amp1 n_common n_cell n_tail n_vdd pfet1 w='w_p'
XMp_right_amp1 n_sense n_ref n_tail n_vdd pfet1 w='w_p'

XMn_left_amp1 n_common n_common ns_left 0 nfet1 w='w_n'
XMn_right_amp1 n_sense n_common ns_right 0 nfet1 w='0.9*w_n'

v_left_branch1 ns_left ns 0
v_right_branch1 ns_right ns 0

V_tail_I1 ns 0 0

*************************************************

Xinv_1bl n_sense n_output_ 0 n_vdd inverter_stage w_n='w_n' w_p='w_n'
Xinv_2bl n_output_ n_output_final 0 n_vdd inverter_stage w_n='w_n' w_p='w_n'

**********************************************************************************************
************************************************************************************
************************************************************************************
************************************************************************************
************************************************************************************
************************************************************************************

**************************************PULSE and voltage GENERATION****************************
.param v1=pvdd
.param v2=0
.param T_d=2n
.param T_r=100p
.param T_f=100p
.param T_duty=8n
.param T_period=70n

V_vdd n_vdd 0 'pvdd'
V_vddr n_vddr 0 'pvdd'
V_vdd1 n_vdd1 0 'pvdd'

*****************************************

Vsenenb sen_enb_l 0 pwl 0 0 'T_start' 0 'T_start+T_rf' 'pvdd' 'T_end' 'pvdd' 'T_end+T_rf' 0
Xinvv1 sen_enb_l sen_enbb gnd n_vdd1 inverter_stage w_n='w_n' w_p='w_n'
Xinvv2 sen_enbb sen_enb gnd n_vdd1 inverter_stage w_n='w_n' w_p='w_n' 


**********************************************************************************
.OPTION POST
.option lis_new
.option ingold
.OPTION CO=132
.option method=BDF
.option nowarn
.op
**********************************************************************************
***********************************************************************************

**********************************************************************
***                           Analysis                             ***
**********************************************************************
.param step_t=1p
.param stop_t='2*T_end'

.TRAN step_t stop_t

***Tox=1.25nm****
*.alter Tox=1.25nm
*.param T_end=600p
*.param w_n=300n
*.param w_p=400n


*********************************************************************
.meas tran start   WHEN v(sen_enb)='0.05*pvdd' rise=1
.meas tran finish   WHEN v(n_output_final)='0.95*pvdd' rise=1
*.meas tran finish param = 4.46e-10
.meas SA_time param = 'finish - start'


.meas tran energy_vdd integ par('(i(V_vdd)*v(n_vdd,0))') from='start' to='finish'
.meas tran energy_vdd_ref integ par('(i(V_vddr)*v(n_vddr,0))') from='start' to='finish'
.meas tran energy_vdd_refgen integ par('(i(Vrefgen)*v(vrefgen,0))') from='start' to='finish'
.meas tran energy_cell param =  'Vread*(I_cellbl + I_ref )*SA_time'
.meas total_energy_SA param= 'abs(energy_vdd)+abs(energy_vdd_ref)+abs(energy_vdd_refgen)+abs(energy_cell)'
**************************
**************************
*.meas tot_time param = 'start + SA_time + 19.7p'
*.meas check param = 'tot_time - start'
*comp_time = 19.7
*read_time = comp_time
*.meas tran energy_w_cm integ par('(i(V_vdd)*v(n_vdd,0))') from='start' to='tot_time'
**************************
.end

