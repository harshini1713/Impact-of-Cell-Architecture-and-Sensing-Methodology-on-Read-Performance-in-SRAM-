*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
.include './latch_sa.sp'

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
******************************************************
.param      vdd_supply   = 0.8
Vvdd        VDD      0   'vdd_supply'
Vvdd_array  VDD_ARR  0   'vdd_supply'
Vgnd   gnd  0        0
Vvss   VSS  0        0
******************************************************

******************************************************
* Define BL and WL cap
******************************************************
Cbl     BL   0 20.27f
Cblb    BLB  0 20.27f
Cwl     WL   0 47.29f
Cout    Q    0 2f
******************************************************

* --- Inverter Subcircuit ---
.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends

* --- 10T SRAM Subcircuit (Calhoun-Chandrakasan) ---
* Ports: Write_WL, Read_WL, Write_BL, Write_BLB, Read_BL, Read_BLB, VDD, VSS
.subckt SRAM wwl rwl wbl wblb rbl rblb vdd vss 

* --- 6T Core (Storage + Write Access) ---
X1 q qb vdd vss INVERTER_normal
X2 qb q vdd vss INVERTER_normal

* Write Access Transistors (Connected to Write Ports)
X1a q  wwl wbl  vss nfet1 W ='33n'
X1b qb wwl wblb vss nfet1 W ='33n'

* --- 10T Read Stack (Differential Read Path) ---
* Path 1: Driven by QB -> Discharges RBL
Xrd_driver1 int_rd1 qb vss vss nfet1 W='44n'
Xrd_access1 rbl rwl int_rd1 vss nfet1 W='44n'

* Path 2: Driven by Q -> Discharges RBLB
Xrd_driver2 int_rd2 q vss vss nfet1 W='44n'
Xrd_access2 rblb rwl int_rd2 vss nfet1 W='44n'

* Initial Conditions
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

******************************************************
* DUT INSTANTIATION (Read Operation Setup)
******************************************************
* We are simulating a READ. 
* 1. Connect Testbench WL to RWL (Read Wordline).
* 2. Connect Testbench BL/BLB to RBL/RBLB (Read Bitlines).
* 3. Ground WWL (Write Wordline) to disable write port.
* 4. Ground WBL/WBLB (Write Bitlines) as they are unused.

* Ports: wwl rwl wbl wblb rbl rblb vdd vss
Xsram 0 WL 0 0 BL BLB VDD VSS SRAM M = 1

*** HA ROW (Dummy Rows) ***
* Connected to Read Bitlines (BL/BLB) to simulate column load.
* RWL is grounded (0).
Xsram_har 0 0 0 0 BL BLB VDD_ARR VSS SRAM M = 511

*** HA COL (Dummy Cols) ***
* Connected to Read Wordline (WL) to simulate row load.
* RBL/RBLB are clamped (here to 0.8V to mimic precharged neighbors).
Xsram_hac 0 WL 0 0 HAR_BLx HAR_BLBx VDD_ARR VSS SRAM M = 511
Vhar1 HAR_BLx  0 0.8
Vhar2 HAR_BLBx 0 0.8


******************************************************
* STIMULUS
******************************************************

* --- Wordline Driver ---
Vwl_enbl wl_enbl 0 pwl 0 0.8  9.0n 0.8  9.1n 0  18n 0  18.1n 0.8
Xpu1 WL  wl_enbl vdd vdd pfet1 W = '360n'
Xpd1 WL  wl_enbl gnd gnd nfet1 W ='180n'


* --- Precharge Logic ---
* Drive BL/BLB precharge enable high from 0 to 8.9ns
* At 8.91ns, precharge OFF -> BL/BLB float
* WL asserted at 9.0ns
Vbl_pch   bl_pch   0 pwl 0 0   8.9n 0   8.91n 0.8   30n 0.8

Xpch1     BL bl_pch vdd vdd pfet1 W = '360n'
Xpch2     BLB bl_pch vdd vdd pfet1 W = '360n'
Xpeq      BL bl_pch BLB vdd pfet1 W = '360n'


* --- Sense Enable (SE) ---
* Fire at 9.44ns (approx 50-60mV discharge)
Vse_enbl  se_enbl 0 pwl  0 0.8  9.43n 0.8  9.44n 0  20n 0 20.1n 0.8
Xpu3      SE se_enbl vdd     vdd     pfet1 W = '720n'
Xpd3      SE se_enbl gnd     gnd     nfet1 W = '180n'


* ------------------------------------------------
* SENSE AMPLIFIER INSTANTIATION
* ------------------------------------------------
* Port Map: BL BLB SE SPE Q Q_bar VDD VSS
* Note: Output node here is "Q_SA", not "Q" to avoid conflict with internal SRAM node
Xsa  BL BLB SE Q_SA VDD VSS LATCH_SA 

.tran 1p 30n

.probe tran v(BL) v(BLB) v(SE) v(Q_SA) v(WL)

* ------------------------------------------------
* MEASUREMENTS
* ------------------------------------------------

.meas tran twl_init   WHEN v(WL)='0.05*(vdd_supply)' rise=1
.meas tran twl_fin    WHEN v(WL)='0.95*(vdd_supply)' rise=1
.meas twl param = 'twl_fin - twl_init'

.meas tran tbl_init   WHEN v(BL)='0.95*(vdd_supply)' fall=1
.meas tran tbl_fin    WHEN v(BL)='0.05*(vdd_supply)' fall=1
.meas tbl param = 'tbl_fin - tbl_init'

* Measure Sense Amp Output Latching
.meas tran tsa_init   WHEN v(Q_SA)='0.95*(vdd_supply) ' fall=1
.meas tran tsa_fin    WHEN v(Q_SA)='0.05*(vdd_supply) ' fall=1
.meas tsa param = 'tsa_fin - tsa_init'

.meas WL2Q_delay param='tsa_fin - twl_init'

* Measure Bitline Differential at Sensing Moment
.meas tran BL_Voltage  FIND v(BL)  AT=9.44n
.meas tran BLB_Voltage FIND v(BLB) AT=9.44n
.meas tran Delta_V PARAM='BLB_Voltage - BL_Voltage'

.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8n TO=10n

.end
