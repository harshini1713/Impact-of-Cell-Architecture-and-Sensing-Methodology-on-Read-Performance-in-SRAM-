*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
*.include './differential_sa.sp'
*.hdl '../Jeffry/efet_comsol.va'
*.lib '../Jeffry/RSA_22_JV.lib' RSA
*.lib '../FEFET_LK_Model_ICDL_PSU/FEFET_LIB_UnEncrypted_22_mod.lib' fefet

*Include DC operating point capacitances.
.OPTIONS DCCAP = 1
.OPTION POST
.option lis_new
.option ingold
.OPTION method=trap
.OPTION runlvl = 6
.OPTION CO=132
.option measform=3

******************************************************
*  GLOBAL SUPPLIES (Unified VDD)
****************************************************** 
.param vdd_supply = 0.8
.param vdd_half   = '0.5 * vdd_supply'
Vvdd       VDD      0         'vdd_supply'
Vvdd_array VDD_ARR  0         'vdd_supply'
Vgnd       gnd      0         0
Vvss       VSS      0         0
******************************************************

******************************************************
*  BL / WL / RBR caps
******************************************************
Cbl_lft     BL_LFT    0 9.216f
Cblb_lft    BLB_LFT   0 9.216f
Cbl_rgt     BL_RGT    0 9.216f
Cblb_rgt    BLB_RGT   0 9.216f
Cwl_lft	    WL_LFT    0 28.36f
Cwl_rgt	    WL_RGT    0 28.36f
Cwl_rwl	    RWL_RGT   0 28.36f
Crbr_rgt    RBR_RGT   0 9.216f
Cout        Q         0 2f
******************************************************

******************************************************
*  BASIC INVERTER (used in cell)
******************************************************
.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W = '44n'
.ends

******************************************************
*  6T SRAM CELL (for left side / HA array)
******************************************************
.subckt SRAM wl bl blb vdd vss 
X1 q  qb vdd vss INVERTER_normal
X2 qb q  vdd vss INVERTER_normal
X1a q  wl bl  vss nfet1 W ='33n'
X1b qb wl blb vss nfet1 W ='33n'
.ic V(q) = 0
.ic V(qb) = 0.8
.ends

******************************************************
*  STRONG INVERTER (acts as single-ended SA)
******************************************************
.subckt INVERTER_special In Out vdd vss
Xp Out In vdd vdd pfet1 W = '720n'
Xn Out In vss vss nfet1 W = '120n'
.ends

******************************************************
*  10T SRAM CELL – separate read port, single-ended
*
* Pins:
*   WWL : write wordline
*   WBL : write bitline
*   WBR : write bitline bar
*   RWL : read wordline
*   RBR : read bitline (single-ended)
*   vdd, vss : supplies
******************************************************
.subckt SRAM_10T WWL WBL WBR RWL RBR vdd vss
* Internal nodes
* q, qb : storage
* qr    : read inverter output
* nrd   : series node in read stack

* Cross-coupled inverters (4T)
Xcore1 q  qb vdd vss INVERTER_normal
Xcore2 qb q  vdd vss INVERTER_normal

* Write access devices (2T), controlled by WWL
Xwwl_q   q   WWL WBL vss nfet1 W='33n'
Xwwl_qb  qb  WWL WBR vss nfet1 W='33n'

* Read inverter: QB → QR  (2T)
Xr_inv qb qr vdd vss INVERTER_normal

* Read stack: RBR –(RWL)→ nrd –(QR)→ vss  (2T)
Xracc  RBR RWL nrd vss nfet1 W='33n'
Xrpd   nrd qr  vss vss nfet1 W='33n'

* Store a '1' so that read discharges RBR:
* q = 1, qb = 0  → qr = 1 → read stack ON
.ic V(q)  = 0.8
.ic V(qb) = 0

.ends

*****************************************************************************
*** Left Sub-array – still 6T ***
*****************************************************************************
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
*** Right Sub-array – 10T cell + single-ended SA ***
*****************************************************************************
* 10T cell instance:
*   WWL_RGT controls write
*   RWL_RGT controls read stack
*   BL_RGT / BLB_RGT used as write bitlines
*   RBR_RGT is the dedicated read bitline
Xsram10T_RGT  WWL_RGT BL_RGT BLB_RGT RWL_RGT RBR_RGT VDD VSS SRAM_10T M = 1

* Sense amplifier: strong inverter on RBR_RGT
XINVERTER_special_RGT  RBR_RGT SL_RGT vdd vss INVERTER_special

*** HA ROW (still 6T style) ***
Xsram_har_RGT	 WL_RGT HAR_BL_RGTx HAR_BLB_RGTx VDD_ARR VSS SRAM M = 255
Vhar1_RGT	 HAR_BL_RGTx  0 0.8
Vhar2_RGT	 HAR_BLB_RGTx 0 0.8

*** HA COL ***
Xsram_hac_RGT	 HAC_WL_RGTx BL_RGT BLB_RGT VDD_ARR VSS SRAM M = 255
Vhac1_RGT	 HAC_WL_RGTx 0 0 
*** Right Sub-array End ***
*****************************************************************************

**** WL Driver for left subarray (unchanged)****
Vwl_enbl_LFT 	wl_enbl_LFT        0             0.8
Xpu2_LFT 	WL_LFT             wl_enbl_LFT   vdd_arr    vdd_arr    pfet1 W = '720n'
Xpd2_LFT 	WL_LFT             wl_enbl_LFT   gnd        gnd        nfet1 W = '360n'
************************************

**** WRITE WL Driver: WWL_RGT ****
Vwwl_enbl_RGT 	wwl_enbl_RGT  0  pwl  0 0.8   9.0n 0.8   9.05n 0   10.05n 0   10.1n 0.8
Xpu2_WWL_RGT 	WWL_RGT wwl_enbl_RGT vdd  vdd pfet1 W = '720n'
Xpd2_WWL_RGT 	WWL_RGT wwl_enbl_RGT gnd  gnd nfet1 W = '360n'

**** READ WL Driver: RWL_RGT ****
Vrwl_enbl_RGT 	rwl_enbl_RGT  0  pwl  0 0.8   9.0n 0.8   9.05n 0   10.05n 0   10.1n 0.8
Xpu2_RWL_RGT 	RWL_RGT rwl_enbl_RGT vdd  vdd pfet1 W = '720n'
Xpd2_RWL_RGT 	RWL_RGT rwl_enbl_RGT gnd  gnd nfet1 W = '360n'
************************************

* ------------------------------------------------
* Precharge logic (write BLs + read RBR)
* ------------------------------------------------
**** BL Pre-charge left (unchanged, effectively always on)****
Vbl_pch_lft           bl_pch_lft_enbl   0 0.8
Xpu_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  vdd_arr vdd_arr pfet1  W = '360n'
Xpd_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  gnd         gnd nfet1  W = '180n'

Xpch1_lft     BL_LFT   bl_pch_lft   vdd_arr  vdd_arr  pfet1  W = '360n'
Xpch2_lft     BLB_LFT  bl_pch_lft   vdd_arr  vdd_arr  pfet1  W = '360n'
Xpeq_lft      BL_LFT   bl_pch_lft   BLB_LFT  vdd_arr  pfet1  W = '360n'
*****************************

**** BL / RBR Pre-charge Right ****
Vbl_pch_rgt           bl_pch_rgt_enbl   0 pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  vdd vdd pfet1  W = '360n'
Xpd_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  gnd gnd nfet1  W = '180n'

Xpch1_rgt     BL_RGT   bl_pch_rgt   vdd      vdd  pfet1  W = '360n'
Xpch2_rgt     BLB_RGT  bl_pch_rgt   vdd      vdd  pfet1  W = '360n'
Xpeq_rgt      BL_RGT   bl_pch_rgt   BLB_RGT  vdd  pfet1  W = '360n'

* Precharge read bitline as well
Xpch_rbr_rgt  RBR_RGT  bl_pch_rgt   vdd      vdd  pfet1  W = '360n'
*****************************

****NOR Gate for SL_LFT / SL_RGT → Q****
.subckt NOR2_normal A B Q vdd vss
Xp1 Q     A   net1  vdd  pfet1 W='120n'
Xp2 net1  B   vdd   vdd  pfet1 W='120n'
Xn1 Q     A   vss   vss  nfet1 W='360n'
Xn2 Q     B   vss   vss  nfet1 W='360n'
.ends NOR2_normal

Xnor1  SL_LFT  SL_RGT  Q  VDD  VSS  NOR2_normal

******************************************************
*  TRANSIENT + MEASUREMENTS (updated for 10T)
******************************************************
.tran 1p 20n
.probe tran v(BL_RGT) v(BLB_RGT) v(RBR_RGT) v(SL_RGT) v(Q)

* Reference the READ WL (RWL_RGT) now
.meas tran twl_rgt_init   WHEN v(RWL_RGT) = vdd_half rise=1
.meas tran tq_fin         WHEN v(Q)       = vdd_half fall=1

.meas tran T_WL_rise_SL_RGT_rise \
      TRIG v(RWL_RGT)   val=vdd_half rise=1  \
      TARG v(SL_RGT)    val=vdd_half rise=1

.meas tran T_SL_RGT_rise_Q_fall \
      TRIG v(SL_RGT)   val=vdd_half rise=1  \
      TARG v(Q)        val=vdd_half fall=1

.meas WL2Q_delay param='tq_fin - twl_rgt_init'

.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8.9n TO=9.8n

.end

