*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
*.lib '../Jeffry/RSA_22_JV.lib' RSA

**** Importing the FeFET Library ***
.lib './FEFET_LK_Model_ICDL_PSU/FEFET_LIB_UnEncrypted_22_mod.lib' fefet

*Include DC operating point capacitances.
.OPTIONS DCCAP = 1
*Enable post-processing/output data for waveform viewing
.OPTION POST
*Control listing/output formats (internal simulator flags).
.option lis_new
.option ingold
*Use the trapezoidal integration method
.OPTION method=trap
*Sets simulation detail level 
* --- ROBUST FeFET CONVERGENCE OPTIONS ---
.OPTION POST
.OPTION INGOLD=2        $ Better output number formatting
.OPTION DCCAP=1
.OPTION RUNLVL=5        $ Lower runlvl sometimes handles stiff models better than 6
.OPTION METHOD=GEAR     $ CRITICAL: Must use GEAR for FeFETs
.OPTION MAXORD=2        $ Limit Gear order to 2 for stability
.OPTION RELTOL=0.01     $ Relax to 1% (FeFET models are often noisy)
.OPTION ABSTOL=1n       $ Relax current absolute tolerance
.OPTION VNTOL=1u        $ Relax voltage noise tolerance
.OPTION CHGTOL=1e-14    $ Relax charge tolerance
.OPTION TRTOL=7         $ Allow larger transient error (helps avoid timestep errors)
.OPTION ITL4=100        $ Allow more iterations per timestep before giving up
********************
* GLOBAL SUPPLIES (Unified VDD)
****************************************************** 
.param vdd_supply = 0.8

* --- FIX START: Changed to DC sources to match .IC statements ---
Vvdd    VDD     0    'vdd_supply'
Vvdd_array VDD_ARR  0    'vdd_supply'
* --- FIX END ---

Vgnd   gnd  0   0
Vvss   VSS  0   0

.IC V(BL_RGT)=0.8 V(BL_LFT)=0.8 V(OUT)=0

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

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W ='44n'
.ends

.subckt INVERTER_special In Out vdd vss
Xp Out In vdd vdd pfet1 W = '100n'
Xn Out In vss vss nfet1 W = '22n'
.ends

*****************************************************************************
*** Left Sub-array Start (Inactive Side) ***
* REPLACED SRAM WITH FeFET
* Connections: Drain(BL), Gate(WL), Source(VSS), Body(VSS), Switch(0)
Xfefet1_LFT  BL_LFT  WL_LFT  VSS  VSS  0  nfefet  l='20n' w_par='44n' a_par='44n'

XINVERTER_special_LFT	BL_LFT 	SL_LFT  vdd     vss INVERTER_special 

*** HA ROW (Wordline Loading) ***
* Replaced with FeFETs to model Gate Capacitance on WL
* M=255 parallel devices. Gate connected to WL_LFT. Drains floating or tied to dummy.
Xfefet_har_LFT   HAR_BL_LFTx  WL_LFT  VSS  VSS 0 nfefet M=255 l='20n' w_par='44n' a_par='44n'
Vhar1_LFT	 HAR_BL_LFTx  0 0.8

*** HA COL (Bitline Loading) ***
* Replaced with FeFETs to model Drain Capacitance on BL
* Gate grounded (OFF). Drain connected to BL_LFT.
Xfefet_hac_LFT  BL_LFT  0  VSS  VSS 0 nfefet M=255 l='20n' w_par='44n' a_par='44n'

*** Left Sub-array End ***
*****************************************************************************

*****************************************************************************
*** Right Sub-array Start (Active Read Side) ***
* REPLACED SRAM WITH FeFET
* This is the device being Read.
Xfefet2_RGT  BL_RGT  WL_RGT  VSS  VSS  0  nfefet  l='20n' w_par='44n' a_par='44n'

XINVERTER_special_RGT	BL_RGT 	SL_RGT   vdd     vss INVERTER_special

*** HA ROW (Wordline Loading) ***
* Models parasitic gate cap of 255 other cells on this WL
Xfefet_har_RGT  HAR_BL_RGTx  WL_RGT  VSS  VSS 0 nfefet M=255 l='20n' w_par='44n' a_par='44n'
Vhar1_RGT	 HAR_BL_RGTx  0 0.8

*** HA COL (Bitline Loading) ***
* Models parasitic drain cap of 255 other cells on this BL
Xfefet_hac_RGT  BL_RGT  0  VSS  VSS 0 nfefet M=255 l='20n' w_par='44n' a_par='44n'

*** Right Sub-array End ***
*****************************************************************************

**** WL Driver for left subarray****
Vwl_enbl_LFT 	wl_enbl_LFT          0              0.8
Xpu2_LFT 	WL_LFT             wl_enbl_LFT   vdd_arr     vdd_arr     pfet1 W = '360n'
Xpd2_LFT 	WL_LFT             wl_enbl_LFT   gnd         gnd         nfet1 W = '180n'
************************************

**** WL Driver for right subarray****
* Standard Read Pulse at 9ns
Vwl_enbl_RGT 	wl_enbl_RGT        0       pwl    0 0.8 9.0n 0.8 9.1n 0 18n 0 18.1n 0.8
Xpu2_RGT 	WL_RGT wl_enbl_RGT vdd     vdd     pfet1 W = '360n'
Xpd2_RGT 	WL_RGT wl_enbl_RGT gnd     gnd     nfet1 W = '180n'
************************************

* ------------------------------------------------
* Precharge / bitline driver logic
* ------------------------------------------------
**** BL Pre-charge left ****
Vbl_pch_lft   bl_pch_lft   0 pwl 0 0   8.9n 0   8.91n 0.8   30n 0.8

Xpch1_lft     BL_LFT  bl_pch_lft   vdd_arr  vdd_arr  pfet1  W = '360n'
* Note: BLB Precharge kept to maintain load symmetry if needed, but BLB is floating at cell
Xpch2_lft     BLB_LFT  bl_pch_lft  vdd_arr  vdd_arr  pfet1  W = '360n'
Xpeq_lft      BL_LFT  bl_pch_lft   BLB_LFT  vdd_arr  pfet1  W = '360n'
*****************************

**** BL Pre-charge Right ****
Vbl_pch_rgt   bl_pch_rgt   0 pwl 0 0   8.9n 0   8.91n 0.8   30n 0.8

Xpch1_rgt     BL_RGT  bl_pch_rgt   vdd      vdd  pfet1  W = '360n'
Xpch2_rgt     BLB_RGT  bl_pch_rgt  vdd      vdd  pfet1  W = '360n'
Xpeq_rgt      BL_RGT  bl_pch_rgt   BLB_RGT  vdd  pfet1  W = '360n'

*****************************

****Sense Line Enable****
Vse_lft   SE_LFT  0 0.8
Vse_rgt   SE_RGT  0 pwl 0 0.8     8.9n 0.8     9.0n 0          30n 0
Xpd3_LFT	SL_LFT   SE_LFT   gnd       gnd      nfet1 W ='180n'
Xpd3_RGT	SL_RGT   SE_RGT   gnd       gnd      nfet1 W ='180n'
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

* Run transient simulation
* --- FIX START: Added UIC ---
.tran 1p 30n uic
* --- FIX END ---

* ---------------- MEASUREMENTS ----------------
* Logic Delay Measurements
.meas tran twl_rgt_init   WHEN v(WL_RGT)='0.05*(vdd_supply)' rise=1
.meas tran twl_rgt_fin    WHEN v(WL_RGT)='0.95*(vdd_supply)' rise=1
.meas twl_rgt param = 'twl_rgt_fin - twl_rgt_init'

* Bitline Discharge (Read) Delay
.meas tran tbl_rgt_init   WHEN v(BL_RGT)='0.95*(vdd_supply)' fall=1
.meas tran tbl_rgt_fin    WHEN v(BL_RGT)='0.05*(vdd_supply)' fall=1
.meas tblb_rgt param = 'tbl_rgt_fin - tbl_rgt_init'

* Inverter/Sense Output Delay
.meas tran tinv_rgt_init   WHEN v(SL_RGT)='0.05*(vdd_supply)' rise=1
.meas tran tinv_rgt_fin    WHEN v(SL_RGT)='0.95*(vdd_supply)' rise=1
.meas tinv_rgt param = 'tinv_rgt_fin - tinv_rgt_init'

* Final Output (NOR) Delay
.meas tran tnor_init   WHEN v(OUT)='0.95*(vdd_supply)' fall=1
.meas tran tnor_fin    WHEN v(OUT)='0.05*(vdd_supply)' fall=1

* Total Delay (WL to Output)
.meas WL2Q_delay_RGT param = 'tnor_fin - twl_rgt_init'

* Read Energy
.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8n TO=10.5n

.end
