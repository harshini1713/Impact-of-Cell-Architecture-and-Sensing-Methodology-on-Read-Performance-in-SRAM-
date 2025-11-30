****** spice file for obtaining tranfer characteristics **********
****** spice file for obtaining tranfer characteristics ***
*** Quasi-DC simulation using the FEFET model. DC 
*** simulation not feasible with the current version
********************************************************
*** Caveat: Quasi-DC simulations are not very stable yet, 
*** especially in the subthreshold region.  
*** For quasi-DC simulation, the ramp rate of the gate 
*** input must be adjusted to proper values. Too high 
*** values (i.e. comparable to polarization switching  
*** time constant) or too low frequency may produce 
*** ambiguous results due to invalidity of the quasi-dc 
*** assumption in the former case and numerical errors 
*** due to small CdV/dt in the latter,
*** Future versions of the model will get around this
*** problem
********************************************************
*** Author: Ahmedullah Aziz, Penn State University.
********************************************************

.lib '../FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_org

.lib '../FEFET_LK_Model_ICDL_PSU/FEFET_LIB_UnEncrypted_22_mod.lib' fefet

.lib '../FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET

.hdl './efet_comsol.va'


.OPTIONS DCCAP = 1
.OPTION POST
.option lis_new
.option ingold
.OPTION method=trap
.OPTION runlvl = 6
.OPTION CO=132
.option measform=3
.OPTION MEASFILE=1 


**Device parameters
.param Lg_par = 20e-9
.param W_par = '1.5*Lg_par'


**Cap parameters
.param Len = 20e-9
.param wid = 30e-9
.param T_fe = 600e-9  *\\nm
.param press_par = 0.0

.param FET_par = -1
.param type_mod = 1

************************

.subckt inv in out vss vdd

XPEFET out in vdd vdd pfet_org w=30n
XNEFET out in vss vss nfet_org w=30n

.ends

************************
*Inverter for WBL

Xbuf_wbl1 writebl writebl_j vss_wbl vdd_wbl inv
Xbuf_wbl2 writebl_j writebl_out vss_wbl vdd_wbl inv

Vdd_wbl vdd_wbl 0 'first'
Vss_wbl vss_wbl 0 0

*Cwbl_cap writebl_out 0 '1e-16'

************************
*Inverter for WBLr1

Xbuf_wblr1 writeblr writeblr_j vss_wblr vdd_wblr inv
Xbuf_wblr2 writeblr_j writeblr_out vss_wblr vdd_wblr inv

Vdd_wblr vdd_wblr 0 'first'
Vss_wblr vss_wblr 0 0

************************
*Inverter for WBLr2

Xbuf_wblr21 writeblr2 writeblr2_j vss_wblr2 vdd_wblr2 inv
Xbuf_wblr22 writeblr2_j writeblr2_out vss_wblr2 vdd_wblr2 inv

Vdd_wblr2 vdd_wblr2 0 'first'
Vss_wblr2 vss_wblr2 0 0

************************
*Inverter for WBLr3

Xbuf_wblr31 writeblr3 writeblr3_j vss_wblr3 vdd_wblr3 inv
Xbuf_wblr32 writeblr3_j writeblr3_out vss_wblr3 vdd_wblr3 inv

Vdd_wblr3 vdd_wblr3 0 'first'
Vss_wblr3 vss_wblr3 0 0

************************
*Inverter for WBLr4

Xbuf_wblr41 writeblr4 writeblr4_j vss_wblr4 vdd_wblr4 inv
Xbuf_wblr42 writeblr4_j writeblr4_out vss_wblr4 vdd_wblr4 inv

Vdd_wblr4 vdd_wblr4 0 'first'
Vss_wblr4 vss_wblr4 0 0

************************
*Inverter for WBLr5

Xbuf_wblr51 writeblr5 writeblr5_j vss_wblr5 vdd_wblr5 inv
Xbuf_wblr52 writeblr5_j writeblr5_out vss_wblr5 vdd_wblr5 inv

Vdd_wblr5 vdd_wblr5 0 'first'
Vss_wblr5 vss_wblr5 0 0

************************
*Inverter for WBLr6

Xbuf_wblr61 writeblr6 writeblr6_j vss_wblr6 vdd_wblr6 inv
Xbuf_wblr62 writeblr6_j writeblr6_out vss_wblr6 vdd_wblr6 inv

Vdd_wblr6 vdd_wblr6 0 'first'
Vss_wblr6 vss_wblr6 0 0

************************
*Inverter for WBLr7

Xbuf_wblr71 writeblr7 writeblr7_j vss_wblr7 vdd_wblr7 inv
Xbuf_wblr72 writeblr7_j writeblr7_out vss_wblr7 vdd_wblr7 inv

Vdd_wblr7 vdd_wblr7 0 'first'
Vss_wblr7 vss_wblr7 0 0

************************
*Inverter for WBLr8

Xbuf_wblr81 writeblr8 writeblr8_j vss_wblr8 vdd_wblr8 inv
Xbuf_wblr82 writeblr8_j writeblr8_out vss_wblr8 vdd_wblr8 inv

Vdd_wblr8 vdd_wblr8 0 'first'
Vss_wblr8 vss_wblr8 0 0

************************
*Inverter for WBLr9

Xbuf_wblr91 writeblr9 writeblr9_j vss_wblr9 vdd_wblr9 inv
Xbuf_wblr92 writeblr9_j writeblr9_out vss_wblr9 vdd_wblr9 inv

Vdd_wblr9 vdd_wblr9 0 'first'
Vss_wblr9 vss_wblr9 0 0
************************
*Inverter for WBLr10

Xbuf_wblr101 writeblr10 writeblr10_j vss_wblr10 vdd_wblr10 inv
Xbuf_wblr102 writeblr10_j writeblr10_out vss_wblr10 vdd_wblr10 inv

Vdd_wblr10 vdd_wblr10 0 'first'
Vss_wblr10 vss_wblr10 0 0
************************

************************
*Inverter for WBLr11

Xbuf_wblr111 writeblr11 writeblr11_j vss_wblr11 vdd_wblr11 inv
Xbuf_wblr112 writeblr11_j writeblr11_out vss_wblr11 vdd_wblr11 inv

Vdd_wblr11 vdd_wblr11 0 'first'
Vss_wblr11 vss_wblr11 0 0
************************
*Inverter for WBLr12

Xbuf_wblr121 writeblr12 writeblr12_j vss_wblr12 vdd_wblr12 inv
Xbuf_wblr122 writeblr12_j writeblr12_out vss_wblr12 vdd_wblr12 inv

Vdd_wblr12 vdd_wblr12 0 'first'
Vss_wblr12 vss_wblr12 0 0
************************

*Inverter for WBLr13

Xbuf_wblr131 writeblr13 writeblr13_j vss_wblr13 vdd_wblr13 inv
Xbuf_wblr132 writeblr13_j writeblr13_out vss_wblr13 vdd_wblr13 inv

Vdd_wblr13 vdd_wblr13 0 'first'
Vss_wblr13 vss_wblr13 0 0
************************

*Inverter for WBLr14

Xbuf_wblr141 writeblr14 writeblr14_j vss_wblr14 vdd_wblr14 inv
Xbuf_wblr142 writeblr14_j writeblr14_out vss_wblr14 vdd_wblr14 inv

Vdd_wblr14 vdd_wblr14 0 'first'
Vss_wblr14 vss_wblr14 0 0
************************

*Inverter for WBLr15

Xbuf_wblr151 writeblr15 writeblr15_j vss_wblr15 vdd_wblr15 inv
Xbuf_wblr152 writeblr15_j writeblr15_out vss_wblr15 vdd_wblr15 inv

Vdd_wblr15 vdd_wblr15 0 'first'
Vss_wblr15 vss_wblr15 0 0
************************

*Inverter for WBLr16

Xbuf_wblr161 writeblr16 writeblr16_j vss_wblr16 vdd_wblr16 inv
Xbuf_wblr162 writeblr16_j writeblr16_out vss_wblr16 vdd_wblr16 inv

Vdd_wblr16 vdd_wblr16 0 'first'
Vss_wblr16 vss_wblr16 0 0
************************

*Inverter for WBLr17

Xbuf_wblr171 writeblr17 writeblr17_j vss_wblr17 vdd_wblr17 inv
Xbuf_wblr172 writeblr17_j writeblr17_out vss_wblr17 vdd_wblr17 inv

Vdd_wblr17 vdd_wblr17 0 'first'
Vss_wblr17 vss_wblr17 0 0
************************
*Inverter for WBLr18

Xbuf_wblr181 writeblr18 writeblr18_j vss_wblr18 vdd_wblr18 inv
Xbuf_wblr182 writeblr18_j writeblr18_out vss_wblr18 vdd_wblr18 inv

Vdd_wblr18 vdd_wblr18 0 'first'
Vss_wblr18 vss_wblr18 0 0
************************
*Inverter for WBLr19

Xbuf_wblr191 writeblr19 writeblr19_j vss_wblr19 vdd_wblr19 inv
Xbuf_wblr192 writeblr19_j writeblr19_out vss_wblr19 vdd_wblr19 inv

Vdd_wblr19 vdd_wblr19 0 'first'
Vss_wblr19 vss_wblr19 0 0
************************
*Inverter for WBLr20

Xbuf_wblr201 writeblr20 writeblr20_j vss_wblr20 vdd_wblr20 inv
Xbuf_wblr202 writeblr20_j writeblr20_out vss_wblr20 vdd_wblr20 inv

Vdd_wblr20 vdd_wblr20 0 'first'
Vss_wblr20 vss_wblr20 0 0
************************
*Inverter for WBLr21

Xbuf_wblr211 writeblr21 writeblr21_j vss_wblr21 vdd_wblr21 inv
Xbuf_wblr212 writeblr21_j writeblr21_out vss_wblr21 vdd_wblr21 inv

Vdd_wblr21 vdd_wblr21 0 'first'
Vss_wblr21 vss_wblr21 0 0
************************
*Inverter for WBLr22

Xbuf_wblr221 writeblr22 writeblr22_j vss_wblr22 vdd_wblr22 inv
Xbuf_wblr222 writeblr22_j writeblr22_out vss_wblr22 vdd_wblr22 inv

Vdd_wblr22 vdd_wblr22 0 'first'
Vss_wblr22 vss_wblr22 0 0
************************
*Inverter for WBLr23

Xbuf_wblr231 writeblr23 writeblr23_j vss_wblr23 vdd_wblr23 inv
Xbuf_wblr232 writeblr23_j writeblr23_out vss_wblr23 vdd_wblr23 inv

Vdd_wblr23 vdd_wblr23 0 'first'
Vss_wblr23 vss_wblr23 0 0
************************
*Inverter for WBLr24

Xbuf_wblr241 writeblr24 writeblr24_j vss_wblr24 vdd_wblr24 inv
Xbuf_wblr242 writeblr24_j writeblr24_out vss_wblr24 vdd_wblr24 inv

Vdd_wblr24 vdd_wblr24 0 'first'
Vss_wblr24 vss_wblr24 0 0
************************
*Inverter for WBLr25

Xbuf_wblr251 writeblr25 writeblr25_j vss_wblr25 vdd_wblr25 inv
Xbuf_wblr252 writeblr25_j writeblr25_out vss_wblr25 vdd_wblr25 inv

Vdd_wblr25 vdd_wblr25 0 'first'
Vss_wblr25 vss_wblr25 0 0
************************
*Inverter for WBLr27

Xbuf_wblr271 writeblr27 writeblr27_j vss_wblr27 vdd_wblr27 inv
Xbuf_wblr272 writeblr27_j writeblr27_out vss_wblr27 vdd_wblr27 inv

Vdd_wblr27 vdd_wblr27 0 'first'
Vss_wblr27 vss_wblr27 0 0
************************
*Inverter for WBLr26

Xbuf_wblr261 writeblr26 writeblr26_j vss_wblr26 vdd_wblr26 inv
Xbuf_wblr262 writeblr26_j writeblr26_out vss_wblr26 vdd_wblr26 inv

Vdd_wblr26 vdd_wblr26 0 'first'
Vss_wblr26 vss_wblr26 0 0
************************
*Inverter for WBLr28

Xbuf_wblr281 writeblr28 writeblr28_j vss_wblr28 vdd_wblr28 inv
Xbuf_wblr282 writeblr28_j writeblr28_out vss_wblr28 vdd_wblr28 inv

Vdd_wblr28 vdd_wblr28 0 'first'
Vss_wblr28 vss_wblr28 0 0
************************
*Inverter for WBLr29

Xbuf_wblr291 writeblr29 writeblr29_j vss_wblr29 vdd_wblr29 inv
Xbuf_wblr292 writeblr29_j writeblr29_out vss_wblr29 vdd_wblr29 inv

Vdd_wblr29 vdd_wblr29 0 'first'
Vss_wblr29 vss_wblr29 0 0
************************
*Inverter for WBLr30

Xbuf_wblr301 writeblr30 writeblr30_j vss_wblr30 vdd_wblr30 inv
Xbuf_wblr302 writeblr30_j writeblr30_out vss_wblr30 vdd_wblr30 inv

Vdd_wblr30 vdd_wblr30 0 'first'
Vss_wblr30 vss_wblr30 0 0
************************
*Inverter for WBLr31

Xbuf_wblr311 writeblr31 writeblr31_j vss_wblr31 vdd_wblr31 inv
Xbuf_wblr312 writeblr31_j writeblr31_out vss_wblr31 vdd_wblr31 inv

Vdd_wblr31 vdd_wblr31 0 'first'
Vss_wblr31 vss_wblr31 0 0
************************

*Inverter for WL

Xbuf_wl1 wordl wordl_j vss_wl vdd_wl inv
Xbuf_wl2 wordl_j wordl_out vss_wl vdd_wl inv

Vdd_wl vdd_wl 0 'first'
Vss_wl vss_wl 0 0

************************
*Inverter for PL

Xbuf_pl1 pl pl_j vss_pl vdd_pl inv
Xbuf_pl2 pl_j pl_out vss_pl vdd_pl inv

Vdd_pl vdd_pl 0 'first'
Vss_pl vss_pl 0 0

************************
.subckt NEFET Gate_ax Drain Bob_n pl press
Vnc1 Bob_n Bob_n1 0
Xax_tx Bob_n1 Gate_ax_ Bob_n_ Source nfet_norm w='30n' 
*Vg Gate_ax Gate_ax_ 0 
*C1 Bob_n1 Bob_n_ 0.0001f
*Vnc2 Bob_n_ Gate 0
XCap Bob_n_ pl FECap_LK Wz = 'T_fe' Wy = 'wid' Wx = 'Len' alpha='alpha_FE' beta='beta_FE' gamma='gamma_FE' rho='rho_FE' 
XEFET Drain pl Source dEg press efet_com type_FET=FET_par type=type_mod W=W_par te='T_fe' Vread = first
Vgnd Source 0 0
.ends

************************
Xacc  wordl_out readbl  writebl_out pl_out press NEFET M= 1
Xacc1  wordl_out readblr writeblr_out pl_out press NEFET  M = 1
Xacc2  wordl_out readblr2 writeblr2_out pl_out press NEFET  M = 1
Xacc3  wordl_out readblr3 writeblr3_out pl_out press NEFET  M = 1
Xacc4  wordl_out readblr3 writeblr4_out pl_out press NEFET  M = 1
Xacc5  wordl_out readblr3 writeblr5_out pl_out press NEFET  M = 1
Xacc6  wordl_out readblr3 writeblr6_out pl_out press NEFET  M = 1
Xacc7  wordl_out readblr3 writeblr7_out pl_out press NEFET  M = 1
Xacc8  wordl_out readblr3 writeblr8_out pl_out press NEFET  M = 1
Xacc9  wordl_out readblr3 writeblr9_out pl_out press NEFET  M = 1
Xacc10  wordl_out readblr3 writeblr10_out pl_out press NEFET  M = 1
Xacc11  wordl_out readblr3 writeblr11_out pl_out press NEFET  M = 1
Xacc12  wordl_out readblr3 writeblr12_out pl_out press NEFET  M = 1
Xacc13  wordl_out readblr3 writeblr13_out pl_out press NEFET  M = 1
Xacc14  wordl_out readblr3 writeblr14_out pl_out press NEFET  M = 1
Xacc15  wordl_out readblr3 writeblr15_out pl_out press NEFET  M = 1
Xacc16  wordl_out readblr3 writeblr16_out pl_out press NEFET  M = 1
Xacc17  wordl_out readblr3 writeblr17_out pl_out press NEFET  M = 1
Xacc18  wordl_out readblr3 writeblr18_out pl_out press NEFET  M = 1
Xacc19  wordl_out readblr3 writeblr19_out pl_out press NEFET  M = 1
Xacc20  wordl_out readblr3 writeblr20_out pl_out press NEFET  M = 1
Xacc21  wordl_out readblr3 writeblr21_out pl_out press NEFET  M = 1
Xacc22  wordl_out readblr3 writeblr22_out pl_out press NEFET  M = 1
Xacc23  wordl_out readblr3 writeblr23_out pl_out press NEFET  M = 1
Xacc24  wordl_out readblr3 writeblr24_out pl_out press NEFET  M = 1
Xacc25  wordl_out readblr3 writeblr25_out pl_out press NEFET  M = 1
Xacc26  wordl_out readblr3 writeblr26_out pl_out press NEFET  M = 1
Xacc27  wordl_out readblr3 writeblr27_out pl_out press NEFET  M = 1
Xacc28  wordl_out readblr3 writeblr28_out pl_out press NEFET  M = 1
Xacc29  wordl_out readblr3 writeblr29_out pl_out press NEFET  M = 1
Xacc30  wordl_out readblr3 writeblr30_out pl_out press NEFET  M = 1
Xacc31  wordl_out readblr3 writeblr31_out pl_out press NEFET  M = 1

Xhacc1  wordl_c readbl  writebl_out pl_c press NEFET  M = 1023	
Xhacc2  wordl_c readblr writeblr_out pl_c press NEFET  M = 1023
Xhacc3  wordl_c readblr2 writeblr2_out pl_c press NEFET  M = 1023
************************ 

.ic V(xacc.xcap.pn) = -1.7
.ic V(xacc2.xcap.pn) = -1.7
.ic V(xacc3.xcap.pn) = -1.7
.ic V(xhacc1.xcap.pn) = -1.7
.ic V(xhacc2.xcap.pn) = -1.7
.ic V(xhacc3.xcap.pn) = -1.7

.param wl_par = 4.37e-14
.param wbl_par = 1.58e-14
.param pl =  4.37e-14

*Cwl_cap   wordl_out 0 'wl_par'
*Cwbl_cap writebl_out 0 'wbl_par'
*Cwblr_cap writeblr_out 0 'wbl_par'
*Cpl_cap pl_out 0 'pl'
************************
Vwbl_acc writebl 0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14*T_pulse' '0' '14.01*T_pulse' '0' '16.00*T_pulse' '0'  '18*T_pulse' '0' '20.00*T_pulse' '0' '20.01*T_pulse' 'first' '24.00*T_pulse' 'first' '24.01*T_pulse' 0
*'26*T_pulse' '0'  '26.01*T_pulse' 'first' '27.00*T_pulse' 'first'  '27.01*T_pulse' '0'  


Vwbl_hacc writeblr 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse' '0' 

Vwbl_hacc2 writeblr2 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse' '0' 

Vwbl_hacc3 writeblr3 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse' '0' 

Vwbl_hacc4 writeblr4 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'


Vwbl_hacc5 writeblr5 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc6 writeblr6 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc7 writeblr7 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc8 writeblr8 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc9 writeblr9 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc10 writeblr10 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc11 writeblr11 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc12 writeblr12 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc13 writeblr13 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc14 writeblr14 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc15 writeblr15 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0

Vwbl_hacc16 writeblr16 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc17 writeblr17 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc18 writeblr18 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc19 writeblr19 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc20 writeblr20 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc21 writeblr21 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'

Vwbl_hacc22 writeblr22 0  0  pwl 0 0 '0.02*T_pulse' '0' '0.99*T_pulse' '0'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '6*T_pulse' 'first' '6.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' '0' '12.00*T_pulse' '0' '12.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '18*T_pulse' 'first'  '18.01*T_pulse '0'


Vwwl_acc wordl 0  pwl 0 0 '0.02*T_pulse' 'first' '0.99*T_pulse' 'first'  '1.00*T_pulse' 0 '2.02*T_pulse' 0 '2.03*T_pulse' 'first' '5.89*T_pulse' 'first' '5.9*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.02*T_pulse' 0  '8.03*T_pulse' 'first' '11.89*T_pulse' 'first' '11.9*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.02*T_pulse' '0' '14.03*T_pulse' 'first' '15.00*T_pulse' 'first'  '17.89*T_pulse' 'first'  '17.9*T_pulse' '0'  '20.02*T_pulse' 0 '20.03*T_pulse' 'first' '24.00*T_pulse' 'first'

Vwwl_hacc wordl_c 0  pwl 0 0 '0.01*T_pulse' 'first' '1.00*T_pulse' 'first' '1.01*T_pulse' 0 '1.99*T_pulse' 0 '2.00*T_pulse' 0

Vrbl_acc readbl 0  pwl 0 0 '25*T_pulse' 0

Vrbl_hacc readblr 0  pwl 0 0 '25*T_pulse' 0

Vrbl_hacc2 readblr2 0  pwl 0 0 '25*T_pulse' 0

Vpl_hacc  pl_c  0  pwl 0 0 '0.01*T_pulse' 'first' '1.00*T_pulse' 'first' '1.01*T_pulse' 0 '1.99*T_pulse' 0 '2.00*T_pulse' 0

Vpl_acc  pl  0 pwl 0 0 '0.02*T_pulse' 'first' '0.99*T_pulse' 'first'  '1.00*T_pulse' 0 '2.0*T_pulse' 0 '2.01*T_pulse' 'first' '4*T_pulse' 'first' '4.01*T_pulse' '0' '7.00*T_pulse' '0' '7.01*T_pulse' 0 '8.00*T_pulse' 0  '8.01*T_pulse' 'first' '10.00*T_pulse' 'first' '10.01*T_pulse' 0 '13.00*T_pulse' '0' '13.01*T_pulse' 0 '14.0*T_pulse' '0' '14.01*T_pulse' 'first' '16.00*T_pulse' 'first'  '16.01*T_pulse' '0'  '18.01*T_pulse' '0'  '20.00*T_pulse' 0 '20.01*T_pulse' 'first' '22.00*T_pulse' 'first'  '22.01*T_pulse' 0 '24.01*T_pulse' 0


*Vpl_acc  pl  0 0

Vpress press 0 press_par

.param first = 0.7
.param pvdd_read=0.35
.param T_pulse = 10n
.param TSTART= 5n
.param tsim = 300n
.param tstep=1p


*For 256
*.data Dim_Press wid press_par wl_par wbl_par
*90e-9   0.041  3.57e-15  3.88e-15
*120e-9  0.053  4.72e-15  3.88e-15
*150e-9  0.064  5.88e-15  3.88e-15
*180e-9  0.071  7.03e-15  3.88e-15
*.enddata

*For 1024
.data Dim_Press wid press_par wl_par wbl_par
90e-9   0.041  3.45e-14  1.58e-14
120e-9  0.053  3.91e-14  1.58e-14
150e-9  0.064  4.37e-14  1.58e-14
180e-9  0.071  4.83e-14  1.58e-14
.enddata


.tran 'tstep' 'tsim' START = '15n'
*sweep data = Dim_Press


.meas tran energy_wbl integ par('(i(Vdd_wbl))*(v(vdd_wbl,0))') from='19n' to='23n'  
.meas tran energy_wblr integ par('(i(Vdd_wblr))*(v(vdd_wblr,0))') from='19n' to='23n'  
.meas tran energy_wblr2 integ par('(i(Vdd_wblr2))*(v(vdd_wblr2,0))') from='19n' to='23n'  

.meas tran energy_wl integ par('(i(Vdd_wl))*(v(vdd_wl,0))') from='20.2n' to='20.4n'  

.meas tran energy_pl_l integ par('(i(Vdd_pl))*(v(vdd_pl,0))') from='19n' to='23n'  
.meas tran energy_pl_h integ par('(i(Vdd_pl))*(v(vdd_pl,0))') from='40n' to='40.2n'  

.meas tran energy_node1 integ par('(i(xacc1.vnc2))*first') from='40n' to='45n'  
.meas tran energy_node2 integ par('(i(xacc2.vnc2))*first') from='40n' to='45n'  
.meas tran energy_node3 integ par('(i(xacc3.vnc2))*first') from='40n' to='45n'  

*.meas energy_total_1bit param='energy_wwl+energy_wbl-energy_node'
*.meas energy_total_32bit  param='energy_wwl+ 32*energy_wbl- 32*energy_node'

.end
