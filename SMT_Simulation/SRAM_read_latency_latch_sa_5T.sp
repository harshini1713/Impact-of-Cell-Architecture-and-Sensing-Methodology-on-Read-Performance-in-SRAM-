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
*Cblb    BLB  0 18.432f
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
* 5T SRAM / Register-File Bitcell
* Interface kept the same:   wl bl blb vdd vss
*   - 4T latch: two inverters (X1, X2)
*   - 1T access: NMOS from Q to BL, gate = WL
*   - BLB pin is unused inside the cell (can act as
*     reference / dummy bitline via periphery)
*----------------------------------------------------
.subckt SRAM wl bl vdd vss 

* --- Cross-Coupled Inverters (Storage) ---
X1 q qb vdd vss INVERTER_normal
X2 qb q vdd vss INVERTER_normal

* --- Single Access Transistor (5T) ---
* Connects Bitline (bl) to Storage Node (q)
* Controlled by Wordline (wl)
X1a bl wl q vss nfet1 W ='33n'

* Initial Conditions (Stored '0')
* Q=0, QB=1. When WL opens, BL (Precharged High) will discharge into Q.
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

Xsram WL BL VDD VSS SRAM M = 1

*** HA ROW ***
Xsram_har WL HAR_BLx VDD_ARR VSS SRAM M = 511
Vhar1 HAR_BLx  0 0.8

*** HA COL ***
Xsram_hac HAC_WLx BL VDD_ARR VSS SRAM M = 511
Vhac1 HAC_WLx 0 pwl 0 0 

*Vwl1 WL 0 pwl 0 0 9n 0 9.1n 0.8  
Vwl_enbl wl_enbl 0 pwl  0 0.8   9.0n 0.8   9.05n 0  10.05n 0  10.1n 0.8
Xpu1 WL  wl_enbl vdd vdd pfet1 W = '720n'
Xpd1 WL  wl_enbl gnd gnd nfet1 W = '360n'

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

* Precharge RBL
Vbl_pch             bl_pch_enbl    0  pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_bl_pch_enbl     bl_pch         bl_pch_enbl  vdd vdd pfet1  W = '360n'
Xpd_bl_pch_enbl     bl_pch         bl_pch_enbl  gnd gnd nfet1  W = '180n'
Xpch_rbl            BL             bl_pch       vdd vdd pfet1  W = '360n'

*** 1. Sense Precharge Enable (SPE) ***
* Needs to be 0 (ON) initially, then switch to 1 (OFF) before SE fires.
* Logic: Input 0.8 -> Buffer Out 0 (SPE=0). Input 0 -> Buffer Out 1 (SPE=1).
* Switch at 9.4ns (100ps before SE).
Vspe_enbl spe_enbl 0 pwl 0 0.8   8.9n 0.8   8.95n 0    10.05n 0   10.1n 0.8
Xpu_spe   SPE spe_enbl vdd vdd pfet1 W = '360n'
Xpd_spe   SPE spe_enbl gnd gnd nfet1 W = '180n'


*** 2. Sense Enable (SE) ***
* Fire at 9.5ns 
***Fire the sense amp when the BL discharges around 50-60mV (9.44 ns)
Vse_enbl  se_enbl    0 pwl   0 0.8   9.225n 0.8   9.275n 0   10.05n 0   10.1n 0.8
Xpu3      SE se_enbl vdd     vdd     pfet1 W = '720n'
Xpd3      SE se_enbl gnd     gnd     nfet1 W = '180n'

Vref_sa  node_ref  0  0.8
* ------------------------------------------------
* SENSE AMPLIFIER INSTANTIATION
* ------------------------------------------------
* Port Map: BL BLB SE SPE Q Q_bar VDD VSS

Xsa  BL node_ref SE SPE Q VDD VSS LATCH_SA 

.tran 1p 20n

.probe tran v(BL)  v(SE) v(Q)

.meas tran twl_init   WHEN v(WL)=vdd_half rise=1
.meas tran tq_fin     WHEN v(Q) =vdd_half fall=1

.meas tran T_WL_rise_SE_rise    TRIG v(WL)   val=vdd_half rise=1  TARG v(SE)   val=vdd_half rise=1
.meas tran T_SE_rise_Q_fall     TRIG v(SE)   val=vdd_half rise=1  TARG v(Q)    val=vdd_half fall=1
.meas WL2Q_delay param='tq_fin - twl_init'


*.meas tran T_sense_time   WHEN v(SE)    = vdd_half rise=1
*.meas tran V_BL_at_sense  FIND v(BL)  AT='T_sense_time'
*.meas tran V_BLB_at_sense FIND v(BLB) AT='T_sense_time'
*.meas tran BL_Delta_V     PARAM='abs(V_BL_at_sense - V_BLB_at_sense)'


.meas tran BL_Voltage        FIND v(BL)       AT=9.275n
.meas tran node_ref_Voltage  FIND v(node_ref) AT=9.275n
.meas tran Delta_V           PARAM='node_ref_Voltage - BL_Voltage'

.meas tran bl_pch_rise     WHEN v(bl_pch) = vdd_half rise=1
.meas tran WL_fall         WHEN v(WL)     = vdd_half fall=1
 
.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=bl_pch_rise TO=WL_fall

*.meas tran E_read_1  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8.9n TO=9.5n

.end
