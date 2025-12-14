*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
*.include './differential_sa.sp'
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
.param vdd_half   = '0.5 * vdd_supply'
Vvdd   VDD  0         'vdd_supply'
Vvdd_array VDD_ARR 0  'vdd_supply'
Vgnd   gnd  0   0
Vvss   VSS  0   0
******************************************************
 
******************************************************
*  Define BL and WL cap
******************************************************
Cbl_lft     BL_LFT   0 9.216f
Cblb_lft    BLB_LFT  0 9.216f
Cbl_rgt     BL_RGT   0 9.216f
Cblb_rgt    BLB_RGT  0 9.216f
Cwl_lft	    WL_LFT   0 28.36f
Cwl_rgt	    WL_RGT   0 28.36f
*Csl_lft     SL_LFT   0 1f
*Csl_rgt     SL_RGT   0 1f
*Cse_lft     SE_LFT   0 1f
*Cse_rgt     SE_RGT   0 1f
Cout        Q        0 2f
******************************************************
 
.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends
 
.subckt SRAM wl bl blb vdd vss 
* --- 4T SRAM Topology (Diagram a) ---
* PMOS Access Transistors (Gate -> WL, Source/Drain -> BL/Storage)
* Note: PMOS access requires Active-Low WL.
Xacc_l  q   wl  bl   vdd  pfet1  W='33n'
Xacc_r  qb  wl  blb  vdd  pfet1  W='33n'

* NMOS Driver Transistors (Cross-Coupled)
* Source -> VSS, Drain -> Storage, Gate -> Opposite Storage
Xdriv_l q   qb  vss  vss  nfet1  W='44n'
Xdriv_r qb  q   vss  vss  nfet1  W='44n'

* Initial Conditions
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

.subckt INVERTER_special In Out vdd vss
Xp Out In vdd vdd pfet1 W = '720n'
Xn Out In vss vss nfet1 W = '120n'
.ends
 
*****************************************************************************
*** Left Sub-array Start ***
Xsram1 			WL_LFT 	BL_LFT 	BLB_LFT VDD_ARR VSS SRAM M = 1
XINVERTER_special_LFT	BL_LFT 	SL_LFT  vdd     vss INVERTER_special
 
*** HA ROW ***
Xsram_har_LFT 	 WL_LFT HAR_BL_LFTx HAR_BLB_LFTx VDD_ARR VSS SRAM M = 255
Vhar1_LFT	 HAR_BL_LFTx  0 0.8
Vhar2_LFT	 HAR_BLB_LFTx 0 0.8
 
*** HA COL ***
Xsram_hac_LFT 	 HAC_WL_LFTx BL_LFT BLB_LFT VDD_ARR VSS SRAM M = 255
Vhac1_LFT        HAC_WL_LFTx 0 0 
*** Left Sub-array End ***
*****************************************************************************
 
*****************************************************************************
*** Right Sub-array Start ***
Xsram2 			WL_RGT  BL_RGT   BLB_RGT VDD VSS SRAM M = 1
XINVERTER_special_RGT	BL_RGT 	SL_RGT   vdd     vss INVERTER_special
 
*** HA ROW ***
Xsram_har_RGT	 WL_RGT HAR_BL_RGTx HAR_BLB_RGTx VDD_ARR VSS SRAM M = 255
Vhar1_RGT	 HAR_BL_RGTx  0 0.8
Vhar2_RGT	 HAR_BLB_RGTx 0 0.8
 
*** HA COL ***
Xsram_hac_RGT	 HAC_WL_RGTx BL_RGT BLB_RGT VDD_ARR VSS SRAM M = 255
Vhac1_RGT	 HAC_WL_RGTx 0 0 
*** Right Sub-array End ***
*****************************************************************************
 
**** WL Driver for left subarray (turned off)****
* Input LOW -> Inverter Output HIGH (0.8V) -> PMOS OFF (Correct for Idle)
Vwl_enbl_LFT    wl_enbl_LFT        0             0

Xpu2_LFT    WL_LFT             wl_enbl_LFT   vdd_arr    vdd_arr    pfet1 W = '720n'
Xpd2_LFT    WL_LFT             wl_enbl_LFT   gnd        gnd        nfet1 W = '360n'

************************************

**** WL Driver for right subarray****
* Logic Inverted for PMOS Access:
* Idle: Input LOW (0V) -> Output HIGH (0.8V) -> SRAM OFF
* Active: Pulse HIGH (0.8V) -> Output LOW (0V) -> SRAM ON
Vwl_enbl_RGT    wl_enbl_RGT        0      pwl    0 0   9.0n 0   9.05n 0.8  10.05n 0.8  10.1n 0

Xpu2_RGT    WL_RGT wl_enbl_RGT vdd     vdd    pfet1 W = '720n'
Xpd2_RGT    WL_RGT wl_enbl_RGT gnd     gnd    nfet1 W = '360n'


************************************
 
 
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
**** BL Pre-charge left (turned off)****
Vbl_pch_lft           bl_pch_lft_enbl   0 0.8
Xpu_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  vdd_arr vdd_arr pfet1  W = '360n'
Xpd_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  gnd         gnd nfet1  W = '180n'
 
Xpch1_lft     BL_LFT   bl_pch_lft   vdd_arr  vdd_arr  pfet1  W = '360n'
Xpch2_lft     BLB_LFT  bl_pch_lft   vdd_arr  vdd_arr  pfet1  W = '360n'
Xpeq_lft      BL_LFT   bl_pch_lft   BLB_LFT  vdd_arr  pfet1  W = '360n'
*****************************
 
**** BL Pre-charge Right ****
Vbl_pch_rgt           bl_pch_rgt_enbl   0 pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  vdd vdd pfet1  W = '360n'
Xpd_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  gnd gnd nfet1  W = '180n'
 
Xpch1_rgt     BL_RGT  bl_pch_rgt   vdd      vdd  pfet1  W = '360n'
Xpch2_rgt     BLB_RGT bl_pch_rgt   vdd      vdd  pfet1  W = '360n'
Xpeq_rgt      BL_RGT  bl_pch_rgt   BLB_RGT  vdd  pfet1  W = '360n'
*****************************
 
****Sense Line pre-discharge****
*Vse_lft        se_lft_enbl  0 0
*Vse_rgt        se_rgt_enbl  0 pwl  0 0    8.9n 0    8.95n 0.8    10.05n 0.8   10.1n 0
 
*Xpu_se_rgt   SE_RGT        se_rgt_enbl  vdd vdd pfet1  W = '360n'
*Xpd_se_rgt   SE_RGT        se_rgt_enbl  gnd gnd nfet1  W = '180n'
 
*Xpu_se_lft   SE_LFT        se_lft_enbl  vdd vdd pfet1  W = '360n'
*Xpd_se_lft   SE_LFT        se_lft_enbl  gnd gnd nfet1  W = '180n'
 
*Xpd3_LFT	SL_LFT   SE_LFT   gnd      gnd     nfet1 W ='180n'
*Xpd3_RGT	SL_RGT   SE_RGT   gnd      gnd     nfet1 W ='180n'
*************************
 
****NOR Gate****
* Two-input NOR gate
.subckt NOR2_normal A B Q vdd vss
 
* Pull-up network: PMOS in series (A and B control)
Xp1 Q     A   net1  vdd  pfet1 W='120n'
Xp2 net1  B   vdd   vdd  pfet1 W='120n'
 
* Pull-down network: NMOS in parallel (stronger pull-down)
Xn1 Q     A   vss   vss  nfet1 W='360n'
Xn2 Q     B   vss   vss  nfet1 W='360n'
 
.ends NOR2_normal
****NOR Gate****
 
Xnor1  SL_LFT  SL_RGT  Q  VDD  VSS  NOR2_normal
 
.tran 1p 20n
.probe tran v(BL_RGT) v(BLB_RGT) v(SL_RGT) v(Q) v(WL_RGT)
 
* Adjusted for Active-Low Wordline (Trigger on Falling Edge)
.meas tran twl_rgt_init  WHEN v(WL_RGT) = vdd_half fall=1

.meas tran tq_fin        WHEN v(Q)      = vdd_half fall=1

* Changed TRIG to fall=1 (Start of Access)
.meas tran T_WL_fall_SL_RGT_rise    TRIG v(WL_RGT)   val=vdd_half fall=1  TARG v(SL_RGT)   val=vdd_half rise=1

.meas tran T_SL_RGT_rise_Q_fall     TRIG v(SL_RGT)   val=vdd_half rise=1  TARG v(Q)        val=vdd_half fall=1

.meas WL2Q_delay param='tq_fin - twl_rgt_init'

.meas tran bl_pch_rgt_rise    WHEN v(bl_pch_rgt) = vdd_half rise=1

* End of access is now a Rising edge on WL
.meas tran WL_rgt_end         WHEN v(WL_RGT)     = vdd_half rise=1

.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=bl_pch_rgt_rise TO=WL_rgt_end
 
.end
