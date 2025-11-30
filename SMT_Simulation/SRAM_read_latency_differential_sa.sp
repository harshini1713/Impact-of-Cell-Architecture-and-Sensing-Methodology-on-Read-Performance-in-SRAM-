*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
.include './differential_sa.sp'
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

******************************************************
*  GLOBAL SUPPLIES (Unified VDD)
******************************************************
.param vdd_supply = 0.8
Vvdd   VDD  0   'vdd_supply'
Vvdd_array VDD_ARR 0  'vdd_supply'
Vgnd   gnd  0   0
Vvss   VSS  0   0
******************************************************

******************************************************
*  Define BL and WL cap
******************************************************
Cbl     BL   0 20.27f
Cblb    BLB  0 20.27f
Cwl     WL   0 47.29f
Cout    Q    0 2f
******************************************************

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

*** HA ROW ***
Xsram_har WL HAR_BLx HAR_BLBx VDD_ARR VSS SRAM M = 511
Vhar1 HAR_BLx 0 0.8
Vhar2 HAR_BLBx 0 0.8

*** HA COL ***
Xsram_hac HAC_WLx BL BLB VDD_ARR VSS SRAM M = 511
Vhac1 HAC_WLx 0 pwl 0 0 

*Vwl1 WL 0 pwl 0 0 9n 0 9.1n 0.8  
Vwl_enbl wl_enbl 0 pwl 0 0.8  9.0n 0.8  9.1n 0  18n 0  18.1n 0.8
Xpu1 WL  wl_enbl vdd vdd pfet1 W = '360n'
Xpd1 WL  wl_enbl gnd gnd nfet1 W ='180n'

*Vbl BL 0 pwl 0 0.8 
*Vblb BLB 0 pwl 0 0

* ------------------------------------------------
* Precharge / bitline driver logic
* Approach:
*  - Drive BL/BLB precharge enable high from 0 to 8.9ns (PFET ON -> precharge to VDD)
*  - At 8.91ns, deassert precharge enable -> PFET off => BL/BLB float
*  - WL asserted at 9.0ns -> cell connects to BL/BLB and produces small differential
*  - SAEN asserted at 9.5ns to amplify the difference
* ------------------------------------------------
Vbl_pch   bl_pch   0 pwl 0 0   8.9n 0   8.91n 0.8   30n 0.8

Xpch1     BL bl_pch vdd vdd pfet1 W = '360n'
Xpch2     BLB bl_pch vdd vdd pfet1 W = '360n'
Xpeq      BL bl_pch BLB vdd pfet1 W = '360n'

***Fire the sense amp when the BL discharges around 50-60mV (9.44 ns)
Vse_enbl  se_enbl  0 pwl  0 0.8  9.43n 0.8  9.44n 0  20n 0 20.1n 0.8
Xpu3      SE se_enbl vdd    vdd    pfet1 W = '360n'
Xpd3      SE se_enbl gnd    gnd    nfet1 W = '180n'

Xsa BL BLB SE Q VDD VSS sense_amp

.tran 1p 30n

.probe tran v(BL) v(BLB) v(SE) v(Q) 

.meas tran twl_init   WHEN v(WL)='0.05*(vdd_supply)' rise=1
.meas tran twl_fin    WHEN v(WL)='0.95*(vdd_supply)' rise=1
.meas twl param = 'twl_fin - twl_init'

.meas tran tbl_init   WHEN v(BL)='0.95*(vdd_supply)' fall=1
.meas tran tbl_fin    WHEN v(BL)='0.05*(vdd_supply)' fall=1
.meas tbl param = 'tbl_fin - tbl_init'

.meas tran tsa_init   WHEN v(Q)='0.95*(vdd_supply) ' fall=1
.meas tran tsa_fin    WHEN v(Q)='0.05*(vdd_supply) ' fall=1
.meas tsa param = 'tsa_fin - tsa_init'

.meas WL2Q_delay param='tsa_fin - twl_init'

.meas tran BL_Voltage  FIND v(BL)  AT=9.44n
.meas tran BLB_Voltage FIND v(BLB) AT=9.44n
.meas tran Delta_V PARAM = 'BLB_Voltage - BL_Voltage'


.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8n TO=10n

.end


