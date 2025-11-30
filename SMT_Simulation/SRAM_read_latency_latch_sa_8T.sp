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

******************************************************
* GLOBAL SUPPLIES (Unified VDD)
******************************************************
.param      vdd_supply   = 0.8
Vvdd        VDD      0    'vdd_supply'
Vvdd_array  VDD_ARR  0    'vdd_supply'
Vgnd   gnd  0        0
Vvss   VSS  0        0
******************************************************

******************************************************
* Define BL, BLB (Write) and RBL (Read) cap
******************************************************
Cbl     BL   0 20.27f
Cblb    BLB  0 20.27f
* RBL typically has similar capacitance to BL/BLB
Crbl    RBL  0 20.27f 
Cwl     WWL  0 47.29f
Cout    Q    0 2f
******************************************************

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends

******************************************************
* 8T SRAM SUB-CIRCUIT
* Ports: wwl (Write WL), wbl (Write BL), wblb (Write BLB)
* rwl (Read WL), rbl (Read BL), vdd, vss
******************************************************
.subckt SRAM wwl wbl wblb rwl rbl vdd vss 

* --- 6T Core (Storage + Write Port) ---
X1 q qb vdd vss INVERTER_normal
X2 qb q vdd vss INVERTER_normal

* Write Access Transistors
X1a q wwl wbl vss nfet1 W ='33n'
X1b qb wwl wblb vss nfet1 W ='33n'

* --- 8T Read Stack (Decoupled Read) ---
* M7: Read Buffer/Amplifier (Driven by internal node QB)
* Note: Depending on layout, this can be driven by Q or QB. 
* Here driven by QB. If QB=1, RBL discharges.
X_rd_amp    int_rd  qb   vss  vss  nfet1 W='66n'

* M8: Read Access Transistor (Driven by Read Wordline)
X_rd_access rbl     rwl  int_rd vss  nfet1 W='33n'

* Initial Conditions
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

******************************************************
* INSTANTIATION
******************************************************

* Main Instance (DUT)
* Mapping: WWL=WWL, WBL=BL, WBLB=BLB, RWL=RWL, RBL=RBL
Xsram WWL BL BLB RWL RBL VDD VSS SRAM M = 1

*** HA ROW (Dummy Loads) ***
* Connected to dummy lines to simulate row loading
Xsram_har WWL HAR_BLx HAR_BLBx RWL HAR_RBLx VDD_ARR VSS SRAM M = 511
Vhar1 HAR_BLx  0 0.8
Vhar2 HAR_BLBx 0 0.8
Vhar3 HAR_RBLx 0 0.8

*** HA COL (Dummy Loads) ***
* Connected to dummy wordlines to simulate column loading
Xsram_hac HAC_WLx BL BLB HAC_RWLx RBL VDD_ARR VSS SRAM M = 511
Vhac1 HAC_WLx 0 0
Vhac2 HAC_RWLx 0 0

******************************************************
* CONTROL SIGNALS & DRIVERS
******************************************************

* --- WRITE PORT CONTROL (Held OFF for Read Test) ---
* We keep Write Wordline (WWL) at 0 to demonstrate read stability
Vwwl WWL 0 0 
* Maintain Write Bitlines at VDD
Vbl  BL  0 0.8
Vblb BLB 0 0.8

* --- READ PORT CONTROL (RWL) ---
* Pulse RWL to perform the read operation
Vrwl_enbl rwl_enbl 0 pwl 0 0.8  9.0n 0.8  9.1n 0  18n 0  18.1n 0.8

* Read Wordline Driver
Xpu_rwl RWL  rwl_enbl vdd vdd pfet1 W = '360n'
Xpd_rwl RWL  rwl_enbl gnd gnd nfet1 W ='180n'


* --- PRECHARGE LOGIC (RBL) ---
* 8T Read is Single-Ended. We precharge RBL to VDD.
* If cell contains '0' (Q=0, QB=1), RBL discharges.
* If cell contains '1' (Q=1, QB=0), RBL stays High.

* Precharge Signal: Active Low (0 to 8.9ns)
Vbl_pch    bl_pch    0 pwl 0 0   8.9n 0   8.91n 0.8   30n 0.8

* Precharge PMOS for Read Bitline
Xpch_rbl   RBL bl_pch vdd vdd pfet1 W = '360n'


******************************************************
* SENSING (Single Ended for 8T)
******************************************************
* Note: Standard 6T differential sense amps (LATCH_SA) are 
* connected to BL/BLB. Since 8T reads via RBL, we use 
* an inverter or simply measure the RBL voltage drop.
* Ideally, a single-ended sense amp (using a reference voltage) 
* is used here. For this netlist, we monitor RBL discharge.

* (Optional) 6T Sense Amp left connected to Write Lines if needed later
Xsa  BL BLB SE Q_SA VDD VSS LATCH_SA 

* Sense Enable (SE) - Only relevant if using the latch
Vse_enbl  se_enbl 0 pwl  0 0.8  9.43n 0.8  9.44n 0  20n 0 20.1n 0.8


******************************************************
* SIMULATION & MEASUREMENTS
******************************************************
.tran 1p 30n

.probe tran v(RWL) v(RBL) v(Q) v(QB)

* Measure Read Wordline Delay
.meas tran trwl_init   WHEN v(RWL)='0.05*(vdd_supply)' rise=1
.meas tran trwl_fin    WHEN v(RWL)='0.95*(vdd_supply)' rise=1
.meas trwl param = 'trwl_fin - trwl_init'

* Measure Read Bitline Discharge Delay (RBL)
* Measuring time for RBL to drop to 50% VDD (or specific sense margin)
.meas tran trbl_init   WHEN v(RBL)='0.95*(vdd_supply)' fall=1
.meas tran trbl_cross  WHEN v(RBL)='0.50*(vdd_supply)' fall=1
.meas trbl_delay param = 'trbl_cross - trwl_fin'

* Measure Bitline Voltage at Sense Time
.meas tran RBL_Voltage FIND v(RBL)  AT=9.44n

* Power Measurement
.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8n TO=10n

.end
