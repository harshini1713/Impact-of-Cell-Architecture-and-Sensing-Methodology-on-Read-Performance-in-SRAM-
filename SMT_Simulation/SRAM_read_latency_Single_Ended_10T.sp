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
Cbl_lft     BL_LFT   0 9.216f
Cblb_lft    BLB_LFT  0 9.216f
Cbl_rgt     BL_RGT   0 9.216f
Cblb_rgt    BLB_RGT  0 9.216f

Crbl_rgt    RBL_RGT  0 9.216f
Crbl_lft    RBL_LFT  0 9.216f

Crwl_lft    RWL_LFT   0 28.36f
Crwl_rgt    RWL_RGT   0 28.36f
Cwl_lft     WL_LFT    0 28.36f
Cwl_rgt     WL_RGT    0 28.36f
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
.subckt SRAM WWL WBL WBR RWL RBL vdd vss
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

* ---------------------------------------------------------
* Read Port (4T): M7, M8, M9, M10
* ---------------------------------------------------------
Xm9  q_int qb  vdd vdd pfet1 W='33n'

Xm7  q_mid qb  vss vss nfet1 W='33n'

Xm10 q_int RWL q_mid vss nfet1 W='33n'

Xm8  RBL   RWL q_int vss nfet1 W='33n'

* Store a '1' so that read discharges RBL:
* q = 1, qb = 0  → qr = 1 → read stack ON
.ic V(q)  = 0
.ic V(qb) = 0.8

.ends

*****************************************************************************
*** Left Sub-array Start (Dummy/Inactive) ***
* Port Map: wwl wbl wbr rwl rbl vdd vss
Xsram1                  WL_LFT   BL_LFT  BLB_LFT  RWL_LFT  RBL_LFT         VDD_ARR   VSS      SRAM M = 1
XINVERTER_special_LFT   RBL_LFT  SL_LFT  vdd      vss      INVERTER_special 

*** HA ROW ***
Xsram_har_LFT    WL_LFT         HAR_BL_LFTx   HAR_BLB_LFTx       RWL_LFT         HAR_RBL_LFTx   VDD_ARR   VSS   SRAM M = 255
Vhar1_LFT        HAR_BL_LFTx  0 0.8
Vhar2_LFT        HAR_BLB_LFTx 0 0.8
Vhar3_LFT        HAR_RBL_LFTx 0 0.8
     
*** HA COL ***
Xsram_hac_LFT    HAC_WL_LFTx     BL_LFT       BLB_LFT            HAC_RWL_LFTx    RBL_LFT        VDD_ARR   VSS   SRAM M = 255
Vhac1_LFT        HAC_WL_LFTx  0 0 
Vhac2_LFT        HAC_RWL_LFTx 0 0 

*** Left Sub-array End ***
*****************************************************************************

*****************************************************************************
*** Right Sub-array Start (Active Read Test) ***
* Port Map: wwl wbl wbr rwl rbl vdd vss
* Note: Write ports grounded. RWL and RBL connected to active drivers.
*****************************************************************************
Xsram2          WL_RGT     BL_RGT   BLB_RGT  RWL_RGT  RBL_RGT  VDD VSS SRAM M = 1

* SENSING: Connected to RBL_RGT (Read Bitline)
* If RBL drops, Inverter Output (SL_RGT) rises.
XINVERTER_special_RGT   RBL_RGT  SL_RGT   vdd      vss INVERTER_special

*** HA ROW ***
Xsram_har_RGT    WL_RGT         HAR_BL_RGTx   HAR_BLB_RGTx   RWL_RGT       HAR_RBL_RGTx   VDD_ARR   VSS   SRAM M = 255
Vhar1_RGT        HAR_BL_RGTx        0 0.8
Vhar2_RGT        HAR_BLB_RGTx       0 0.8
Vhar3_RGT        HAR_RBL_RGTx       0 0.8

*** HA COL ***
Xsram_hac_RGT    HAC_WL_RGTx    BL_RGT        BLB_RGT        HAC_RWL_RGTx   RBL_RGT       VDD_ARR   VSS   SRAM M = 255
Vhac1_RGT        HAC_WL_RGTx  0 0 
Vhac2_RGT        HAC_RWL_RGTx 0 0 

*** Right Sub-array End ***
*****************************************************************************

**** WL Driver for left subarray (turned off)****
Vwl_enbl_LFT    wl_enbl_LFT        0              0.8
Xpu2_LFT        WL_LFT             wl_enbl_LFT    vdd_arr     vdd_arr     pfet1 W = '720n'
Xpd2_LFT        WL_LFT             wl_enbl_LFT    gnd         gnd         nfet1 W = '360n'
**** RWL Driver for left subarray (turned off)****
Vrwl_enbl_LFT   rwl_enbl_LFT       0               0.8
Xpu3_LFT        RWL_LFT            rwl_enbl_LFT    vdd_arr     vdd_arr     pfet1 W = '720n'
Xpd3_LFT        RWL_LFT            rwl_enbl_LFT    gnd         gnd         nfet1 W = '360n'
************************************

**** READ WL Driver for right subarray (Active) ****
Vwl_enbl_RGT    wl_enbl_RGT        0              0.8
Xpu2_RGT        WL_RGT             wl_enbl_RGT    vdd_arr     vdd_arr     pfet1 W = '720n'
Xpd2_RGT        WL_RGT             wl_enbl_RGT    gnd         gnd         nfet1 W = '360n'
* Drives RWL_RGT
Vrwl_enbl_RGT   rwl_enbl_RGT       0              pwl      0 0.8    9.0n 0.8    9.05n 0  10.05n 0  10.1n 0.8
Xpu3_RGT        RWL_RGT            rwl_enbl_RGT   vdd      vdd      pfet1 W = '720n'
Xpd3_RGT        RWL_RGT            rwl_enbl_RGT   gnd      gnd      nfet1 W = '360n'

************************************

* ------------------------------------------------
* Precharge Logic
* ------------------------------------------------
**** BL Pre-charge left (turned off)****
Vbl_pch_lft           bl_pch_lft_enbl   0 0.8
Xpu_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  vdd_arr      vdd_arr pfet1  W = '360n'
Xpd_bl_pch_enbl_lft   bl_pch_lft        bl_pch_lft_enbl  gnd          gnd     nfet1  W = '180n'

Xpch1_lft      BL_LFT    bl_pch_lft    vdd_arr   vdd_arr   pfet1  W = '360n'
Xpch2_lft      BLB_LFT   bl_pch_lft    vdd_arr   vdd_arr   pfet1  W = '360n'
Xpeq_lft       BL_LFT    bl_pch_lft    BLB_LFT   vdd_arr   pfet1  W = '360n'

*** RBL Pre-charge (RBL left is off)
Vrbl_pch_lft           rbl_pch_lft_enbl    0  0.8 
Xpu_rbl_pch_enbl_lft   rbl_pch_lft         rbl_pch_lft_enbl  vdd_arr  vdd_arr   pfet1  W = '360n'
Xpd_rbl_pch_enbl_lft   rbl_pch_lft         rbl_pch_lft_enbl  gnd      gnd       nfet1  W = '180n'
Xpch_rbl_lft           RBL_LFT             rbl_pch_lft       vdd_arr  vdd_arr   pfet1  W = '360n'

*****************************

**** BL and RBL Pre-charge Right ****
* Control signal pulses 0 -> 1 -> 0 to precharge before Read
Vbl_pch_rgt           bl_pch_rgt_enbl   0 0.8  
Xpu_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  vdd_arr  vdd_arr pfet1  W = '360n'
Xpd_bl_pch_enbl_rgt   bl_pch_rgt        bl_pch_rgt_enbl  gnd gnd          nfet1  W = '180n'

Xpch1_rgt      BL_RGT   bl_pch_rgt    vdd_arr      vdd_arr   pfet1  W = '360n'
Xpch2_rgt      BLB_RGT  bl_pch_rgt    vdd_arr      vdd_arr   pfet1  W = '360n'
Xpeq_rgt       BL_RGT   bl_pch_rgt    BLB_RGT      vdd_arr   pfet1  W = '360n'

* 8T Read Bitline Precharge
Vrbl_pch_rgt           rbl_pch_rgt_enbl    0  pwl 0 0.8   8.9n 0.8   8.95n 0   10.05n 0   10.1n 0.8
Xpu_rbl_pch_enbl_rgt   rbl_pch_rgt         rbl_pch_rgt_enbl  vdd vdd pfet1  W = '360n'
Xpd_rbl_pch_enbl_rgt   rbl_pch_rgt         rbl_pch_rgt_enbl  gnd gnd nfet1  W = '180n'
Xpch_rbl_rgt           RBL_RGT             rbl_pch_rgt       vdd vdd pfet1  W = '360n'
*****************************

****NOR Gate****
.subckt NOR2_normal A B Q vdd vss
* Pull-up network
Xp1 Q      A    net1  vdd  pfet1 W='120n'
Xp2 net1   B    vdd   vdd  pfet1 W='120n'
* Pull-down network
Xn1 Q      A    vss   vss  nfet1 W='360n'
Xn2 Q      B    vss   vss  nfet1 W='360n'
.ends NOR2_normal
****NOR Gate****

Xnor1  SL_LFT  SL_RGT  Q  VDD  VSS  NOR2_normal

.tran 1p 20n
* Probes updated for 8T read operation
.probe tran v(BL_RGT) v(RBL_RGT) v(SL_RGT) v(Q) v(RWL_RGT)

* Measurements updated to track RBL path delays
.meas tran twl_rgt_init   WHEN v(RWL_RGT) = vdd_half rise=1
.meas tran tq_fin         WHEN v(Q)       = vdd_half fall=1

.meas tran T_WL_rise_SL_RGT_rise     TRIG v(RWL_RGT)   val=vdd_half rise=1  TARG v(SL_RGT)    val=vdd_half rise=1
.meas tran T_SL_RGT_rise_Q_fall      TRIG v(SL_RGT)    val=vdd_half rise=1  TARG v(Q)         val=vdd_half fall=1

.meas WL2Q_delay param='tq_fin - twl_rgt_init'

.meas tran rbl_pch_rgt_rise    WHEN v(rbl_pch_rgt) = vdd_half rise=1
.meas tran RWL_rgt_fall        WHEN v(RWL_RGT)     = vdd_half fall=1
 
.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM = rbl_pch_rgt_rise TO = RWL_rgt_fall

*.meas tran E_read  INTEG par('abs(v(VDD) * i(Vvdd))') FROM=8.9n TO=9.8n

.end
