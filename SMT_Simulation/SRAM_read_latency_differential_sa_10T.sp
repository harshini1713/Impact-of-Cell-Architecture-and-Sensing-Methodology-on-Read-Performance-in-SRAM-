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
* 10T SRAM BITCELL SIMULATION (Differential Read)
******************************************************
* GLOBAL SUPPLIES (Unified VDD)
******************************************************
.param vdd_supply = 0.8
Vvdd   VDD  0   'vdd_supply'
Vvdd_array VDD_ARR 0  'vdd_supply'
Vgnd   gnd  0   0
Vvss   VSS  0   0
******************************************************

******************************************************
* Define BL and WL cap
******************************************************
* Write Port Caps
Cwbl     WBL    0 20.27f
Cwblb    WBLB   0 20.27f
Cwwl     WWL    0 47.29f

* Read Port Caps (Differential)
Crbl     RBL    0 20.27f 
Crblb    RBLB   0 20.27f
Crwl     RWL    0 47.29f
******************************************************

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends

******************************************************
* 10T SRAM Subcircuit
* Ports: 
* wwl  = Write Word Line
* rwl  = Read Word Line
* wbl  = Write Bit Line 
* wblb = Write Bit Line Bar
* rbl  = Read Bit Line
* rblb = Read Bit Line Bar (New for 10T)
******************************************************
.subckt SRAM wwl rwl wbl wblb rbl rblb vdd vss 

* --- 6T Core (Storage + Write Access) ---
X1 q qb vdd vss INVERTER_normal
X2 qb q vdd vss INVERTER_normal
* Write Access Transistors
X1a q  wwl wbl  vss nfet1 W ='33n'
X1b qb wwl wblb vss nfet1 W ='33n'

* --- 10T Read Stack (Differential Read Path) ---

* Path 1: Driven by QB -> Discharges RBL
* If QB is '1', this path turns ON.
Xrd_driver1 int_rd1 qb vss vss nfet1 W='44n'
Xrd_access1 rbl rwl int_rd1 vss nfet1 W='44n'

* Path 2: Driven by Q -> Discharges RBLB
* If Q is '1', this path turns ON.
Xrd_driver2 int_rd2 q vss vss nfet1 W='44n'
Xrd_access2 rblb rwl int_rd2 vss nfet1 W='44n'

* Initial Conditions
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

******************************************************
* Instantiations
******************************************************

* Device Under Test (DUT)
Xsram WWL RWL WBL WBLB RBL RBLB VDD VSS SRAM M = 1

*** HA ROW (Dummy Load) ***
* Tied off unused ports
Xsram_har WWL HAR_RWL HAR_WBLx HAR_WBLBx HAR_RBLx HAR_RBLBx VDD_ARR VSS SRAM M = 511
Vhar1 HAR_WBLx 0 0.8
Vhar2 HAR_WBLBx 0 0.8
Vhar3 HAR_RBLx 0 0.8
Vhar4 HAR_RBLBx 0 0.8
Vhar5 HAR_RWL  0 0

*** HA COL (Dummy Load) ***
Xsram_hac HAC_WWL HAC_RWL WBL WBLB RBL RBLB VDD_ARR VSS SRAM M = 511
Vhac1 HAC_WWL 0 0
Vhac2 HAC_RWL 0 0

******************************************************
* Stimulus: READ OPERATION
* Scenario: Read '0' (Q=0, QB=1). 
* Expectation: QB=1 turns on Path 1 -> RBL discharges.
* Q=0 keeps Path 2 OFF -> RBLB stays High.
******************************************************

* 1. Keep Write Port Quiet
Vwwl WWL 0 0
Vwbl WBL  0 0.8
Vwblb WBLB 0 0.8

* 2. Read Bitline Precharge Logic (Differential)
* Drive RBL and RBLB High until 8.9ns
Vrbl_pch rbl_pch 0 pwl 0 0  8.9n 0  8.91n 0.8  30n 0.8

* Precharge PMOS for RBL
Xpch_rbl  RBL  rbl_pch vdd vdd pfet1 W = '360n'
* Precharge PMOS for RBLB
Xpch_rblb RBLB rbl_pch vdd vdd pfet1 W = '360n'
* Equalizer (Optional but good for diff sensing)
Xeq_rbl   RBL  rbl_pch RBLB vdd pfet1 W = '360n'

* 3. Read Word Line (RWL) Activation
Vrwl_enbl rwl_enbl 0 pwl 0 0.8  9.0n 0.8  9.1n 0  18n 0  18.1n 0.8

* RWL Driver
Xpu_rwl RWL rwl_enbl vdd vdd pfet1 W = '360n'
Xpd_rwl RWL rwl_enbl gnd gnd nfet1 W = '180n'


******************************************************
* Analysis & Measurements
******************************************************
.tran 1p 20n

* Updated probe to look inside the subcircuit Xsram
.probe tran v(RBL) v(RBLB) v(RWL) v(Xsram.q) v(Xsram.qb)

* Measure Read Access Time
* Logic: RBL discharges, RBLB stays high.

.meas tran trwl_rise WHEN v(RWL)='0.5*(vdd_supply)' rise=1

* Measure delay to discharge RBL to 80% VDD
.meas tran trbl_disch WHEN v(RBL)='0.8*(vdd_supply)' fall=1

.meas read_delay param = 'trbl_disch - trwl_rise'

* Check differential splitting at 9.5ns
.meas tran rbl_val FIND v(RBL) AT=9.5n
.meas tran rblb_val FIND v(RBLB) AT=9.5n
.meas diff_sig param = 'rblb_val - rbl_val'

* Check noise on storage nodes (Corrected to use hierarchical path Xsram.q)
.meas tran q_noise MAX v(Xsram.q) from=9n to=15n
