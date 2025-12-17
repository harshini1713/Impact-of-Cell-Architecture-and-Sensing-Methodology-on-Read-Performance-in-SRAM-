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
Cbl         BL   0 18.432f
Cblb        BLB  0 18.432f
Cwl         WL   0 56.72f

Crbl        RBL  0 18.432f
Crwl        RWL  0 56.72f

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
* 8T SRAM / Register-File Bitcell
*   Pin order kept the same as your original:
*     wl bl blb vdd vss
*   -> WL used as write+read wordline
*   -> BL/BLB are write bitlines; BL also used as read bitline
*----------------------------------------------------
.subckt SRAM wwl wbl wbr rwl rbl vdd vss 

* --- Standard 6T Core ---
X1 q qb vdd vss INVERTER_normal
X2 qb q vdd vss INVERTER_normal
X1a q wwl wbl vss nfet1 W ='33n'
X1b qb wwl wbr vss nfet1 W ='33n'

* --- 8T Read Port Stack ---
* FIXED: Used 'X' instead of 'M' because nfet1 is a subcircuit
* X_rd_acc: Gate = RWL, Drain = RBL, Source = Internal Node
X_rd_acc rbl rwl int_node vss nfet1 W='33n'

* X_rd_drv: Gate = QB, Drain = Internal Node, Source = VSS
* Logic: If QB is High (Stored 0), RBL discharges when RWL is High.
X_rd_drv int_node qb vss vss nfet1 W='33n'

* Initial Conditions
.ic V(q)  = 0
.ic V(qb) = 0.8
.ends

******************************************************
*  TOP-LEVEL ARRAY AND PERIPHERY
******************************************************

* Single cell used with SA / BL drivers
Xsram      WL    BL    BLB    RWL    RBL    VDD    VSS   SRAM    M = 1
*** HA ROW ***
Xsram_har  WL          HAR_BLx    HAR_BLBx     RWL       HAR_RBLx     VDD_ARR   VSS   SRAM M = 511
Vhar1      HAR_BLx     0 0.8
Vhar2      HAR_BLBx    0 0.8
Vhar3      HAR_RBLx    0 0.8

*** HA COL ***
Xsram_hac   HAC_WLx    BL         BLB          HAC_RWLx   RBL         VDD_ARR   VSS   SRAM M = 511
Vhac1       HAC_WLx  0 0 
Vhac2       HAC_RWLx 0 0 

* WL Driver  
Vwl_enbl         wl_enbl         0 0.8 
Xpu1 WL          wl_enbl         vdd_arr     vdd_arr  pfet1 W = '720n'
Xpd1 WL          wl_enbl         gnd         gnd      nfet1 W = '360n'

* WL Driver for RWL
Vrwl_enbl       rwl_enbl       0              pwl      0 0.8    9.0n 0.8    9.05n 0  10.05n 0  10.1n 0.8
Xpu2            RWL            rwl_enbl       vdd      vdd      pfet1 W = '720n'
Xpd2            RWL            rwl_enbl       gnd      gnd      nfet1 W = '360n'

*Vbl BL 0 pwl 0 0.8 
*Vblb BLB 0 pwl 0 0

* ------------------------------------------------
* Precharge / bitline driver logic
* ------------------------------------------------
Vbl_pch           bl_pch_enbl   0 0.8   
Xpu_bl_pch_enbl   bl_pch   bl_pch_enbl  vdd_arr  vdd_arr pfet1 W = '360n'
Xpd_bl_pch_enbl   bl_pch   bl_pch_enbl  gnd      gnd     nfet1 W = '180n'

Xpch1            BL  bl_pch  vdd_arr  vdd_arr pfet1 W = '360n'
Xpch2            BLB bl_pch  vdd_arr  vdd_arr pfet1 W = '360n'
Xpeq             BL  bl_pch  BLB      vdd_arr pfet1 W = '360n'

* Precharge RBL
Vrbl_pch             rbl_pch_enbl    0  pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_rbl_pch_enbl     rbl_pch         rbl_pch_enbl  vdd vdd pfet1  W = '360n'
Xpd_rbl_pch_enbl     rbl_pch         rbl_pch_enbl  gnd gnd nfet1  W = '180n'
Xpch_rbl             RBL             rbl_pch       vdd vdd pfet1  W = '360n'

*** 1. Sense Precharge Enable (SPE) ***
Vspe_enbl spe_enbl 0 pwl 0 0.8   8.9n 0.8   8.95n 0    10.05n 0   10.1n 0.8
Xpu_spe   SPE spe_enbl vdd vdd pfet1 W = '360n'
Xpd_spe   SPE spe_enbl gnd gnd nfet1 W = '180n'

*** 2. Sense Enable (SE) ***
***Fire the sense amp when the BL discharges around 50-60mV (9.44 ns)
Vse_enbl  se_enbl    0 pwl   0 0.8   9.25n 0.8   9.3n 0   10.05n 0   10.1n 0.8
Xpu3      SE se_enbl vdd     vdd     pfet1 W = '720n'
Xpd3      SE se_enbl gnd     gnd     nfet1 W = '180n'

Vref_sa  node_ref  0  0.8
* ------------------------------------------------
* SENSE AMPLIFIER INSTANTIATION
* Port Map (per latch_sa.sp): BL BLB SE SPE Q VDD VSS
* ------------------------------------------------
Xsa  RBL node_ref SE SPE Q VDD VSS LATCH_SA 

******************************************************
*  ANALYSIS, PROBES, MEASUREMENTS
******************************************************
.tran 1p 20n

.probe tran v(BL) v(BLB) v(SE) v(Q)

.meas tran twl_init   WHEN v(RWL)=vdd_half rise=1
.meas tran tq_fin     WHEN v(Q) = vdd_half fall=1

.meas tran T_WL_rise_SE_rise    TRIG v(RWL)   val=vdd_half rise=1  TARG v(SE)   val=vdd_half rise=1
.meas tran T_SE_rise_Q_fall     TRIG v(SE)   val=vdd_half rise=1   TARG v(Q)    val=vdd_half fall=1
.meas WL2Q_delay param='tq_fin - twl_init'

*.meas tran T_sense_time   WHEN v(SE)    = vdd_half rise=1
*.meas tran V_BL_at_sense  FIND v(BL)  AT='T_sense_time'
*.meas tran V_BLB_at_sense FIND v(BLB) AT='T_sense_time'
*.meas tran BL_Delta_V     PARAM='abs(V_BL_at_sense - V_BLB_at_sense)'

.meas tran RBL_Voltage  FIND v(RBL)  AT=9.3n
.meas tran BLB_Voltage  FIND v(node_ref)  AT=9.3n
.meas tran Delta_V PARAM='BLB_Voltage - RBL_Voltage'

.meas tran rbl_pch_rise    WHEN v(rbl_pch) = vdd_half rise=1
.meas tran RWL_fall        WHEN v(RWL)     = vdd_half fall=1
 
.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM = rbl_pch_rise TO = RWL_fall

*.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8.9n TO=9.5n

.end
