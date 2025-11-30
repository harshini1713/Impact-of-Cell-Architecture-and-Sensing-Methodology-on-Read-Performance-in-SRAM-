
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
*.hdl '../Jeffry/efet_comsol.va'
*.lib '../Jeffry/RSA_22_JV.lib' RSA
*.lib '../FEFET_LK_Model_ICDL_PSU/FEFET_LIB_UnEncrypted_22_mod.lib' fefet

*Include DC operating point capacitances.
.OPTIONS DCCAP = 1
*Enable post-processing/output data for waveform viewing
.OPTION POST
*Control listing/output formats (internal simulator flags).
.option lis_new
.option ingold
*Use the trapezoidal integration method (accurate transient solver).
.OPTION method=trap
*Sets simulation detail level (6 = highest detail).
.OPTION runlvl = 6
*Column width for output listings.
.OPTION CO=132
*Output .meas results in a convenient format.
.option measform=3
*.OPTION MEASFILE=1 

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W ='44n'
.ends

.subckt SRAM wl bl blb vdd vss 
X1 q qb vdd vss INVERTER_normal
X2 qb q vdd vss INVERTER_normal
X1a q wl bl vss nfet1 W ='33n'
X1b qb wl blb vss nfet1 W ='33n'
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

Xsram WL BL BLB VDD VSS SRAM M = 1

*** HA ROW *** (bitlines are shared across one row)
Xsram_har WL HAR_BLx HAR_BLBx VDD VSS SRAM M = 511
Vhar1 HAR_BLx 0 0.8
Vhar2 HAR_BLBx 0 0.8

*** HA COL ***(
Xsram_hac HAC_WLx BL BLB VDD VSS SRAM M = 511
Vhac1 HAC_WLx 0 pwl 0 0 

*Vwl1 WL 0 pwl 0 0 9n 0 9.1n 0.8  
.param vdd_wl = 0.8
Vwl_enbl wl_enbl 0 pwl 0 0.8 9.0n 0.8 9.1n 0 18n 0 18.1n 0.8
Xpu2 WL wl_enbl vdd_wl vdd_wl pfet1 W = '360n'
Xpd2 WL wl_enbl gnd gnd nfet1 W ='180n'
Vvdd_wl vdd_wl 0 'vdd_wl'

*Vbl BL 0 pwl 0 0.8 
*Vblb BLB 0 pwl 0 0

Vbl_enbl bl_enbl 0 pwl 0 0.8 1n 0.8 1.1n 0 16n 0 16.1n 0.8 18n 0.8 18.1n 0.8
Vbl_enbl2 bl_enbl2 0 pwl 0 0.8 1n 0.8 1.1n 0 16n 0 16.1n 0 18n 0 18.1n 0.8
Xpu1 BL bl_enbl vdd_bl vdd_bl pfet1 W = '360n'
Xpd1 BL bl_enbl2 gnd gnd nfet1 W ='180n'
Vvdd_bl vdd_bl 0 'vdd_bl'
.param vdd_bl = 0.8

Vblb_enbl blb_enbl 0 pwl 0 0.8 15n 0.8 15.1n 0 16n 0 16.1n 0.8 18n 0.8 18.1n 0.8
Vblb_enbl2 blb_enbl2 0 pwl 0 0.8 15n 0.8 15.1n 0 16n 0 16.1n 0 18n 0 18.1n 0.8
Xpu1_ BLB blb_enbl vdd_bl vdd_bl pfet1 W = '360n'
Xpd1_ BLB blb_enbl2 gnd gnd nfet1 W ='180n'

Vvdd VDD 0 0.8
Vvss VSS 0 0
.tran 1p 30n

Cbl BL 0 20.27f
Cblb BLB 0 20.27f
Cwl WL 0 47.29f

.meas tran twl_init   WHEN v(WL)='0.05*(vdd_wl)' rise=1
.meas tran twl_fin   WHEN v(WL)='0.95*(vdd_wl)' rise=1
.meas twl param = 'twl_fin - twl_init'

.meas tran tblb_init   WHEN v(BL)='0.05*(vdd_bl)' rise=1
.meas tran tblb_fin   WHEN v(BL)='0.95*(vdd_bl)' rise=1
.meas tblb param = 'tblb_fin - tblb_init'

.meas tran tq_init   WHEN v(Xsram.q)= '0.05*(vdd_bl)' rise=1
.meas tran tq_fin   WHEN v(Xsram.q) = '0.95*(vdd_bl)' rise=1
.meas tq param = 'tq_fin - tq_init'


.end


