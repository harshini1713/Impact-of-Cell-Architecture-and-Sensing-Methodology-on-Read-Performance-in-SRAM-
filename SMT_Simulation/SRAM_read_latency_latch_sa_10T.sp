*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
.include './latch_sa.sp'
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
.param      vdd_supply   =  0.8
.param      vdd_half     = '0.5 * vdd_supply'
Vvdd        VDD      0     'vdd_supply'
Vvdd_array  VDD_ARR  0     'vdd_supply'
Vgnd   gnd  0        0
Vvss   VSS  0        0
******************************************************

******************************************************
*  Define BL and WL cap
******************************************************
Cbl     BL   0 18.432f
Cblb    BLB  0 18.432f
Cwl     WL   0 56.72f
Cout    Q    0 2f
******************************************************

*----------------------------------------------------
* Simple static CMOS inverter (used in the cell)
*----------------------------------------------------
.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends

*----------------------------------------------------
* 10T SRAM / Register-File Bitcell
* Interface unchanged:   wl bl blb vdd vss
*   - WL also plays role of WWL/RWL
*   - BL is the single-ended read bitline (RBR)
*   - BL/BLB used for write as before
*   Devices:
*   - 4T latch (two inverters)
*   - 2T write access (X1a, X1b)
*   - 2T read stack (Xrd1, Xrd2)
*   - 2T read buffer inverter (Xrb_inv) --> total 10T
*----------------------------------------------------
.subckt SRAM wl bl blb vdd vss 

* Cross-coupled storage inverters (4T)
X1 q  qb vdd vss INVERTER_normal
X2 qb q  vdd vss INVERTER_normal

* Write access transistors (2T)
X1a q   wl bl  vss nfet1 W ='33n'     * WBL <-> Q (write)
X1b qb  wl blb vss nfet1 W ='33n'     * WBR <-> QB (write)

* Read buffer inverter (2T) : QB -> qrb
Xrb_inv qb qrb vdd vss INVERTER_normal

* Read stack (2T) on BL, gated by WL & buffered QB
* BL --Xrd1-- node_r --Xrd2-- GND
Xrd1 bl     wl   node_r vss nfet1 W='33n'   * top device, gate = WL (RWL)
Xrd2 node_r qrb  vss    vss nfet1 W='33n'   * bottom device, gate = buffered QB

* Initial conditions
.ic V(q)  = 0
.ic V(qb) = 0.8

.ends

******************************************************
*  TOP-LEVEL ARRAY AND PERIPHERY
******************************************************

* Single cell used with SA / BL drivers
Xsram WL BL BLB VDD VSS SRAM M = 1

*** HA ROW ***
Xsram_har WL HAR_BLx HAR_BLBx VDD_ARR VSS SRAM M = 511
Vhar1 HAR_BLx  0 0.8
Vhar2 HAR_BLBx 0 0.8

*** HA COL ***
Xsram_hac HAC_WLx BL BLB VDD_ARR VSS SRAM M = 511
Vhac1 HAC_WLx 0 pwl 0 0 

*Vwl1 WL 0 pwl 0 0 9n 0 9.1n 0.8  
Vwl_enbl wl_enbl 0 pwl  0 0.8   9.0n 0.8   9.05n 0  10.05n 0  10.1n 0.8
Xpu1 WL  wl_enbl vdd vdd pfet1 W = '720n'
Xpd1 WL  wl_enbl gnd gnd nfet1 W = '360n'

*Vbl BL 0 pwl 0 0.8 
*Vblb BLB 0 pwl 0 0

* ------------------------------------------------
* Precharge / bitline driver logic
* ------------------------------------------------
Vbl_pch           bl_pch_enbl   0 pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_bl_pch_enbl   bl_pch   bl_pch_enbl vdd vdd pfet1 W = '360n'
Xpd_bl_pch_enbl   bl_pch   bl_pch_enbl  gnd gnd nfet1 W = '180n'

Xpch1     BL  bl_pch  vdd vdd pfet1 W = '360n'
Xpch2     BLB bl_pch  vdd vdd pfet1 W = '360n'
Xpeq      BL  bl_pch  BLB vdd pfet1 W = '360n'


*** 1. Sense Precharge Enable (SPE) ***
Vspe_enbl spe_enbl 0 pwl 0 0.8   8.9n 0.8   8.95n 0    10.05n 0   10.1n 0.8
Xpu_spe   SPE spe_enbl vdd vdd pfet1 W = '360n'
Xpd_spe   SPE spe_enbl gnd gnd nfet1 W = '180n'


*** 2. Sense Enable (SE) ***
***Fire the sense amp when the BL discharges around 50-60mV (9.44 ns)
Vse_enbl  se_enbl    0 pwl   0 0.8   9.25n 0.8   9.3n 0   10.05n 0   10.1n 0.8
Xpu3      SE se_enbl vdd     vdd     pfet1 W = '720n'
Xpd3      SE se_enbl gnd     gnd     nfet1 W = '180n'


* ------------------------------------------------
* SENSE AMPLIFIER INSTANTIATION
* Port Map (per latch_sa.sp): BL BLB SE SPE Q VDD VSS
* ------------------------------------------------
Xsa  BL BLB SE SPE Q VDD VSS LATCH_SA 

******************************************************
*  ANALYSIS, PROBES, MEASUREMENTS
******************************************************
.tran 1p 20n

.probe tran v(BL) v(BLB) v(SE) v(Q)

.meas tran twl_init   WHEN v(WL)=vdd_half rise=1
.meas tran tq_fin     WHEN v(Q) =vdd_half fall=1

.meas tran T_WL_rise_SE_rise    TRIG v(WL)   val=vdd_half rise=1  TARG v(SE)   val=vdd_half rise=1
.meas tran T_SE_rise_Q_fall     TRIG v(SE)   val=vdd_half rise=1  TARG v(Q)    val=vdd_half fall=1
.meas WL2Q_delay param='tq_fin - twl_init'

*.meas tran T_sense_time   WHEN v(SE)    = vdd_half rise=1
*.meas tran V_BL_at_sense  FIND v(BL)  AT='T_sense_time'
*.meas tran V_BLB_at_sense FIND v(BLB) AT='T_sense_time'
*.meas tran BL_Delta_V     PARAM='abs(V_BL_at_sense - V_BLB_at_sense)'

.meas tran BL_Voltage  FIND v(BL)  AT=9.3n
.meas tran BLB_Voltage FIND v(BLB) AT=9.3n
.meas tran Delta_V PARAM='BLB_Voltage - BL_Voltage'

.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8.9n TO=9.5n

.end

