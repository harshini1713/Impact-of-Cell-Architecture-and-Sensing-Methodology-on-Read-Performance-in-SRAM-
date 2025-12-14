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
* GLOBAL SUPPLIES (Unified VDD)
******************************************************
.param      vdd_supply   =  0.8
.param      vdd_half     = '0.5 * vdd_supply'
Vvdd        VDD      0     'vdd_supply'
Vvdd_array  VDD_ARR  0     'vdd_supply'
Vgnd   gnd  0        0
Vvss   VSS  0        0
******************************************************

******************************************************
* Define BL and WL cap
******************************************************
Cbl     BL   0 18.432f
Cblb    BLB  0 18.432f
Cwl     WL   0 56.72f
Cout    Q    0 2f
******************************************************

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends

* --- MODIFIED: 4T SRAM Topology (Diagram a) ---
.subckt SRAM wl bl blb vdd vss 
* PMOS Access Transistors (Gate -> WL, Source/Drain -> BL/Storage)
* ACTIVE LOW WL required to turn these ON.
Xacc_l  q   wl  bl   vdd  pfet1  W='33n'
Xacc_r  qb  wl  blb  vdd  pfet1  W='33n'

* NMOS Driver Transistors (Cross-Coupled, Loadless)
Xdriv_l q   qb  vss  vss  nfet1  W='44n'
Xdriv_r qb  q   vss  vss  nfet1  W='44n'

* Initial Conditions
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

Xsram WL BL BLB VDD VSS SRAM M = 1

*** HA ROW ***
Xsram_har WL HAR_BLx HAR_BLBx VDD_ARR VSS SRAM M = 511
Vhar1 HAR_BLx  0 0.8
Vhar2 HAR_BLBx 0 0.8

*** HA COL ***
Xsram_hac HAC_WLx BL BLB VDD_ARR VSS SRAM M = 511
Vhac1 HAC_WLx 0 pwl 0 0 

* --- MODIFIED: Wordline Stimulus ---
* Target: WL must be High (0.8V) to be OFF, and Low (0V) to be ON.
* Driver: Inverter (Xpu1/Xpd1).
* Input (wl_enbl): Must be Low (0V) to Idle, and High (0.8V) to Active.
* Timing: Pulse High starting at 9.05n.
Vwl_enbl wl_enbl 0 pwl  0 0   9.0n 0   9.05n 0.8  10.05n 0.8  10.1n 0

Xpu1 WL  wl_enbl vdd vdd pfet1 W = '720n'
Xpd1 WL  wl_enbl gnd gnd nfet1 W = '360n'


* ------------------------------------------------
* Precharge / bitline driver logic
* ------------------------------------------------
* Vbl_pch is Active High logic for the signal source.
* Driver (Xpu/Xpd) is an inverter -> 'bl_pch' node is Active Low.
* PFETs (Xpch) turn ON when 'bl_pch' is Low.
* Sequence: 0 to 8.9ns (High input -> Low gate -> PCH ON).
Vbl_pch           bl_pch_enbl   0 pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_bl_pch_enbl   bl_pch   bl_pch_enbl vdd vdd pfet1 W = '360n'
Xpd_bl_pch_enbl   bl_pch   bl_pch_enbl  gnd gnd nfet1 W = '180n'

Xpch1     BL  bl_pch  vdd vdd pfet1 W = '360n'
Xpch2     BLB bl_pch  vdd vdd pfet1 W = '360n'
Xpeq      BL  bl_pch  BLB vdd pfet1 W = '360n'


*** 1. Sense Precharge Enable (SPE) ***
* Needs to be 0 (ON) initially, then switch to 1 (OFF) before SE fires.
* Logic: Input 0.8 -> Buffer Out 0 (SPE=0). Input 0 -> Buffer Out 1 (SPE=1).
* Switch at 9.4ns (100ps before SE).
Vspe_enbl spe_enbl 0 pwl 0 0.8   8.9n 0.8   8.95n 0     10.05n 0   10.1n 0.8
Xpu_spe   SPE spe_enbl vdd vdd pfet1 W = '360n'
Xpd_spe   SPE spe_enbl gnd gnd nfet1 W = '180n'


*** 2. Sense Enable (SE) ***
* Fire at 9.3n (approx)
* Input Logic: Active Low pulse (starts 0.8, goes 0).
* Driver Output (SE): Active High pulse.
Vse_enbl  se_enbl    0 pwl   0 0.8   9.25n 0.8   9.3n 0   10.05n 0   10.1n 0.8
Xpu3      SE se_enbl vdd     vdd     pfet1 W = '720n'
Xpd3      SE se_enbl gnd     gnd     nfet1 W = '180n'


* ------------------------------------------------
* SENSE AMPLIFIER INSTANTIATION
* ------------------------------------------------
* Port Map: BL BLB SE SPE Q Q_bar VDD VSS
Xsa  BL BLB SE SPE Q VDD VSS LATCH_SA 

.tran 1p 20n

.probe tran v(BL) v(BLB) v(SE) v(Q) v(WL)

* --- MODIFIED: Measurements for Active-Low Wordline ---

* Trigger on falling edge of WL (Start of Read)
.meas tran twl_init   WHEN v(WL)=vdd_half fall=1

.meas tran tq_fin     WHEN v(Q) =vdd_half fall=1

* Changed Trigger to FALLING edge of WL
.meas tran T_WL_fall_SE_rise    TRIG v(WL)   val=vdd_half fall=1  TARG v(SE)   val=vdd_half rise=1

.meas tran T_SE_rise_Q_fall     TRIG v(SE)   val=vdd_half rise=1  TARG v(Q)    val=vdd_half fall=1

.meas WL2Q_delay param='tq_fin - twl_init'

.meas tran BL_Voltage  FIND v(BL)  AT=9.3n
.meas tran BLB_Voltage FIND v(BLB) AT=9.3n
.meas tran Delta_V PARAM='BLB_Voltage - BL_Voltage'

* 1. Define Start Point: When Precharge Ends (Gate goes High -> PFET OFF)
.meas tran bl_pch_rgt_rise     WHEN v(bl_pch) = vdd_half rise=1

* 2. Define End Point: When Wordline turns OFF (Active-Low WL goes High -> PMOS OFF)
* NOTE: Changed from 'fall=1' to 'rise=1' because this is a 4T PMOS cell.
.meas tran WL_rgt_end          WHEN v(WL)     = vdd_half rise=1

* 3. Integrate Power between these two points
.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=bl_pch_rgt_rise TO=WL_rgt_end


.end
