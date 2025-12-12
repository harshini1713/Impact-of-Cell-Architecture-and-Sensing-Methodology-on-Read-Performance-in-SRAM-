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
* GLOBAL SUPPLIES (Unified VDD)
****************************************************** 
.param vdd_supply = 0.8
.param vdd_half   = '0.5 * vdd_supply'

Vvdd   VDD  0         'vdd_supply'
Vvdd_array VDD_ARR 0  'vdd_supply'
Vgnd   gnd  0   0
Vvss   VSS  0   0
******************************************************

******************************************************
* Define Capacitances
* 5T is Single-Ended, so we mostly care about BL
******************************************************
Cbl_lft     BL_LFT   0 9.216f
Cbl_rgt     BL_RGT   0 9.216f

Cwl_lft     WL_LFT   0 28.36f
Cwl_rgt     WL_RGT   0 28.36f
Cout        Q        0 2f
******************************************************

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends

******************************************************
* 5T SRAM CELL DEFINITION (Single-Ended)
* Ports: wl, bl, vdd, vss
******************************************************
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

.subckt INVERTER_special In Out vdd vss
Xp Out In vdd vdd pfet1 W = '720n'
Xn Out In vss vss nfet1 W = '120n'
.ends

*****************************************************************************
*** Left Sub-array Start (Dummy/Inactive) ***
* Port Map: wl bl vdd vss
Xsram1          WL_LFT  BL_LFT  VDD_ARR VSS SRAM M = 1
XINVERTER_special_LFT   BL_LFT  SL_LFT   vdd  vss INVERTER_special 

*** HA ROW ***
Xsram_har_LFT    WL_LFT HAR_BL_LFTx VDD_ARR VSS SRAM M = 255
Vhar1_LFT    HAR_BL_LFTx  0 0.8

*** HA COL ***
Xsram_hac_LFT    HAC_WL_LFTx BL_LFT VDD_ARR VSS SRAM M = 255
Vhac1_LFT        HAC_WL_LFTx 0 0 
*** Left Sub-array End ***
*****************************************************************************

*****************************************************************************
*** Right Sub-array Start (Active Read Test) ***
* Port Map: wl bl vdd vss
*****************************************************************************
* DUT (Device Under Test)
Xsram2          WL_RGT  BL_RGT  VDD VSS SRAM M = 1

* SENSING: Single-Ended Sensing on BL_RGT
* If BL_RGT discharges (Read 0), this inverter output (SL_RGT) will rise.
XINVERTER_special_RGT   BL_RGT  SL_RGT   vdd      vss INVERTER_special

*** HA ROW ***
Xsram_har_RGT    WL_RGT HAR_BL_RGTx VDD_ARR VSS SRAM M = 255
Vhar1_RGT    HAR_BL_RGTx  0 0.8

*** HA COL ***
Xsram_hac_RGT    HAC_WL_RGTx BL_RGT VDD_ARR VSS SRAM M = 255
Vhac1_RGT        HAC_WL_RGTx 0 0 
*** Right Sub-array End ***
*****************************************************************************

**** WL Driver for left subarray (turned off)****
Vwl_enbl_LFT    wl_enbl_LFT        0              0.8
Xpu2_LFT    WL_LFT             wl_enbl_LFT    vdd_arr     vdd_arr     pfet1 W = '720n'
Xpd2_LFT    WL_LFT             wl_enbl_LFT    gnd         gnd         nfet1 W = '360n'
************************************

**** WL Driver for right subarray (Active) ****
* Drives WL_RGT for the Read Operation
Vwl_enbl_RGT    wl_enbl_RGT        0        pwl    0 0.8    9.0n 0.8    9.05n 0  10.05n 0  10.1n 0.8
Xpu2_RGT    WL_RGT wl_enbl_RGT vdd      vdd     pfet1 W = '720n'
Xpd2_RGT    WL_RGT wl_enbl_RGT gnd      gnd     nfet1 W = '360n'
************************************

* ------------------------------------------------
* Precharge Logic (Single Bitline)
* ------------------------------------------------
**** BL Pre-charge left (turned off)****
Vbl_pch_lft           bl_pch_lft_enbl   0 0.8
Xpu_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  vdd_arr vdd_arr pfet1  W = '360n'
Xpd_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  gnd          gnd nfet1  W = '180n'
Xpch1_lft      BL_LFT    bl_pch_lft    vdd_arr   vdd_arr   pfet1  W = '360n'
*****************************

**** BL Pre-charge Right (Active) ****
* Precharges BL_RGT to VDD before the read
Vbl_pch_rgt           bl_pch_rgt_enbl   0 pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  vdd vdd pfet1  W = '360n'
Xpd_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  gnd gnd nfet1  W = '180n'

* Precharge Transistor for BL_RGT
Xpch1_rgt      BL_RGT   bl_pch_rgt    vdd      vdd   pfet1  W = '360n'
*****************************

****NOR Gate****
.subckt NOR2_normal A B Q vdd vss
Xp1 Q      A    net1  vdd  pfet1 W='120n'
Xp2 net1   B    vdd   vdd  pfet1 W='120n'
Xn1 Q      A    vss   vss  nfet1 W='360n'
Xn2 Q      B    vss   vss  nfet1 W='360n'
.ends NOR2_normal
****NOR Gate****

Xnor1  SL_LFT  SL_RGT  Q_sense  VDD  VSS  NOR2_normal

.tran 1p 20n
* Probes updated for 5T Single-Ended Read
.probe tran v(BL_RGT) v(SL_RGT) v(Q) v(WL_RGT)

* Measurements
* 1. When WL rises (Start of Access)
.meas tran twl_rgt_init   WHEN v(WL_RGT) = vdd_half rise=1
* 2. When the Sense Amplifier Output (SL_RGT) flips (indicating successful read)
.meas tran tq_fin         WHEN v(SL_RGT) = vdd_half rise=1

.meas tran T_WL_rise_SL_RGT_rise    TRIG v(WL_RGT)   val=vdd_half rise=1  TARG v(SL_RGT)   val=vdd_half rise=1

* "Read Delay": Time from WL activation to Sense Output High
.meas WL2Sense_delay param='tq_fin - twl_rgt_init'

.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8.9n TO=9.8n

.end
