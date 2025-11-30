*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
*.include './differential_sa.sp'

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

******************************************************
* GLOBAL SUPPLIES (Unified VDD)
****************************************************** .param vdd_supply = 0.8
Vvdd   VDD  0   'vdd_supply'
Vvdd_array VDD_ARR 0  'vdd_supply'
Vgnd   gnd  0   0
Vvss   VSS  0   0
******************************************************

******************************************************
* Define BL and WL cap
******************************************************
Cbl_lft     BL_LFT   0 10.14f
Cblb_lft    BLB_LFT  0 10.14f
Cbl_rgt     BL_RGT   0 10.14f
Cblb_rgt    BLB_RGT  0 10.14f
Cwl_lft     WL_LFT   0 23.65f
Cwl_rgt     WL_RGT   0 23.65f
Csl_lft     SL_LFT   0 5f
Csl_rgt     SL_RFT   0 5f
Cse_lft     SE_LFT   0 5f
Cse_rgt     SE_RGT   0 5f
Cout    OUT  0 5f
******************************************************

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W ='44n'
.ends

* -----------------------------------------------------------
* 4T Single-Ended SRAM Bitcell
* Based on user provided figure:
* - M2 (PMOS): Pulls Q up, Gate connected to QB
* - M4 (PMOS) & M3 (NMOS): Inverter driving QB, Input is Q
* - M5 (NMOS): Access Transistor connecting Q to BL
* -----------------------------------------------------------
.subckt SRAM wl bl blb vdd vss 

* --- Inverter Stage (M4 and M3) driving QB ---
* M4 PMOS (Source=VDD, Drain=QB, Gate=Q)
X4 qb q vdd vdd pfet1 W='22n'
* M3 NMOS (Source=VSS, Drain=QB, Gate=Q)
X3 qb q vss vss nfet1 W='22n'

* --- Storage Node Q Stage (M2) ---
* M2 PMOS (Source=VDD, Drain=Q, Gate=QB)
X2 q qb vdd vdd pfet1 W='22n'
* Note: There is NO NMOS pull-down on Node Q in this 4T topology.

* --- Access Transistor (M5) ---
* M5 NMOS (Drain=Q, Source=BL, Gate=WL)
* Body tied to VSS
X5 q wl bl vss nfet1 W='33n'

* --- Unused Port ---
* BLB is not used in this single-ended cell, but kept for 
* testbench compatibility. It is floating.

* --- Initial Conditions ---
* Initialize Q=0, QB=1
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

.subckt INVERTER_special In Out vdd vss
Xp Out In vdd vdd pfet1 W = '100n'
Xn Out In vss vss nfet1 W = '22n'
.ends

*****************************************************************************
*** Left Sub-array Start ***
Xsram1          WL_LFT  BL_LFT  BLB_LFT VDD_ARR VSS SRAM M = 1
XINVERTER_special_LFT   BL_LFT  SL_LFT  vdd     vss INVERTER_special 

*** HA ROW ***
Xsram_har_LFT    WL_LFT HAR_BL_LFTx HAR_BLB_LFTx VDD_ARR VSS SRAM M = 255
Vhar1_LFT    HAR_BL_LFTx  0 0.8
Vhar2_LFT    HAR_BLB_LFTx 0 0.8

*** HA COL ***
Xsram_hac_LFT    HAC_WL_LFTx BL_LFT BLB_LFT VDD_ARR VSS SRAM M = 255
Vhac1_LFT        HAC_WL_LFTx 0 0 
*** Left Sub-array End ***
*****************************************************************************

*****************************************************************************
*** Right Sub-array Start ***
Xsram2          WL_RGT  BL_RGT    BLB_RGT VDD VSS SRAM M = 1
XINVERTER_special_RGT   BL_RGT  SL_RGT   vdd     vss INVERTER_special

*** HA ROW ***
Xsram_har_RGT    WL_RGT HAR_BL_RGTx HAR_BLB_RGTx VDD_ARR VSS SRAM M = 255
Vhar1_RGT    HAR_BL_RGTx  0 0.8
Vhar2_RGT    HAR_BLB_RGTx 0 0.8

*** HA COL ***
Xsram_hac_RGT    HAC_WL_RGTx BL_RGT BLB_RGT VDD_ARR VSS SRAM M = 255
Vhac1_RGT    HAC_WL_RGTx 0 0 
*** Right Sub-array End ***
*****************************************************************************

**** WL Driver for left subarray****
Vwl_enbl_LFT    wl_enbl_LFT        0              0.8
Xpu2_LFT    WL_LFT             wl_enbl_LFT    vdd_arr     vdd_arr     pfet1 W = '360n'
Xpd2_LFT    WL_LFT             wl_enbl_LFT    gnd         gnd         nfet1 W = '180n'
************************************

**** WL Driver for right subarray****

Vwl_enbl_RGT    wl_enbl_RGT        0       pwl    0 0.8 9.0n 0.8 9.1n 0 18n 0 18.1n 0.8
Xpu2_RGT    WL_RGT wl_enbl_RGT vdd     vdd     pfet1 W = '360n'
Xpd2_RGT    WL_RGT wl_enbl_RGT gnd     gnd     nfet1 W = '180n'
************************************


* ------------------------------------------------
* Precharge / bitline driver logic
* ------------------------------------------------
**** BL Pre-charge left ****
Vbl_pch_lft    bl_pch_lft   0 pwl 0 0   8.9n 0   8.91n 0.8   30n 0.8

Xpch1_lft      BL_LFT  bl_pch_lft   vdd_arr  vdd_arr  pfet1  W = '360n'
Xpch2_lft      BLB_LFT  bl_pch_lft  vdd_arr  vdd_arr  pfet1  W = '360n'
Xpeq_lft       BL_LFT  bl_pch_lft   BLB_LFT  vdd_arr  pfet1  W = '360n'
*****************************

**** BL Pre-charge Right ****
Vbl_pch_rgt    bl_pch_rgt   0 pwl 0 0   8.9n 0   8.91n 0.8   30n 0.8

Xpch1_rgt      BL_RGT  bl_pch_rgt   vdd      vdd  pfet1  W = '360n'
Xpch2_rgt      BLB_RGT  bl_pch_rgt  vdd      vdd  pfet1  W = '360n'
Xpeq_rgt       BL_RGT  bl_pch_rgt   BLB_RGT  vdd  pfet1  W = '360n'

*****************************

****Sense Line Enable****
Vse_lft    SE_LFT  0 0.8
Vse_rgt    SE_RGT  0 pwl 0 0.8      8.9n 0.8      9.0n 0         30n 0
Xpd3_LFT    SL_LFT   SE_LFT   gnd       gnd      nfet1 W ='180n'
Xpd3_RGT    SL_RGT   SE_RGT   gnd       gnd      nfet1 W ='180n'
*************************

****NOR Gate****
* Two-input NOR gate
.subckt NOR2_normal A B Out vdd vss

* Pull-up network: PMOS in series (A and B control)
Xp1 Out   A   net1  vdd  pfet1 W='22n'
Xp2 net1  B   vdd   vdd  pfet1 W='22n'

* Pull-down network: NMOS in parallel (stronger pull-down)
Xn1 Out   A   vss   vss  nfet1 W='66n'
Xn2 Out   B   vss   vss  nfet1 W='66n'

.ends NOR2_normal
****NOR Gate****

Xnor1  SL_LFT  SL_RGT  OUT  VDD  VSS  NOR2_normal

.tran 1p 30n

.meas tran twl_rgt_init   WHEN v(WL_RGT)='0.05*(vdd_supply)' rise=1
.meas tran twl_rgt_fin    WHEN v(WL_RGT)='0.95*(vdd_supply)' rise=1
.meas twl_rgt param = 'twl_rgt_fin - twl_rgt_init'

.meas tran tbl_rgt_init   WHEN v(BL_RGT)='0.95*(vdd_supply)' fall=1
.meas tran tbl_rgt_fin    WHEN v(BL_RGT)='0.05*(vdd_supply)' fall=1
.meas tblb_rgt param = 'tbl_rgt_fin - tbl_rgt_init'

.meas tran tinv_rgt_init   WHEN v(SL_RGT)='0.05*(vdd_supply)' rise=1
.meas tran tinv_rgt_fin    WHEN v(SL_RGT)='0.95*(vdd_supply)' rise=1
.meas tinv_rgt param = 'tinv_rgt_fin - tinv_rgt_init'

.meas tran tnor_init   WHEN v(OUT)='0.95*(vdd_supply)' fall=1
.meas tran tnor_fin    WHEN v(OUT)='0.05*(vdd_supply)' fall=1


.meas WL2Q_delay_RGT param = 'tnor_fin - twl_rgt_init'

.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8n TO=10.5n
.end
