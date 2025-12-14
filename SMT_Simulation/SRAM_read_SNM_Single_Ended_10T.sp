* ============================================================
* 10T SRAM SNM READ TESTBENCH (Open-loop method)
* ============================================================

*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
*.include './differential_sa.sp'
*.hdl '../Jeffry/efet_comsol.va'
*.lib '../Jeffry/RSA_22_JV.lib' RSA
*.lib '../FEFET_LK_Model_ICDL_PSU/FEFET_LIB_UnEncrypted_22_mod.lib' fefet

* --- INCLUDE THE CSV WRITER ---
.hdl 'csv_write.va'

.OPTIONS DCCAP = 1
.OPTION POST
.option lis_new
.option ingold=2
.OPTION method=trap
.OPTION runlvl = 6
.OPTION CO=132
.option measform=3
.option numdgt=12

* ------------------------------------------------------------
* Basic inverter used for the open-loop SNM method
* ------------------------------------------------------------
.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W='22n'
Xn Out In vss vss nfet1 W='44n'
.ends

* ------------------------------------------------------------
* 10T "OPEN-LOOP" SRAM macro for SNM READ
*
* Ports:
*   u   = swept input driving both inverters (open-loop SNM method)
*   q,qb= internal storage nodes (here: v1,v2 in the bench)
*   WWL/WBL/WBR = write port (kept OFF during read SNM)
*   RWL/RBL/RBR = read port (ON during read SNM, bitlines precharged)
* ------------------------------------------------------------
.subckt SRAM10T_OPEN u q qb WWL WBL WBR RWL RBL RBR vdd vss

* Two independent inverters (open-loop SNM construction)
XinvL u  q  vdd vss INVERTER_normal
XinvR u  qb vdd vss INVERTER_normal

* Write access devices (2T) -- typically OFF for read SNM
XwL  q  WWL WBL vss nfet1 W='33n'
XwR  qb WWL WBR vss nfet1 W='33n'

* Read port (4T): stacked NMOS per read bitline
* RBL discharges when (QB=1) AND (RWL=1)
Xrbl1 RBL qb  n_rbl vss nfet1 W='33n'
Xrbl2 n_rbl RWL vss  vss nfet1 W='33n'

* RBR discharges when (Q=1) AND (RWL=1)
Xrbr1 RBR q   n_rbr vss nfet1 W='33n'
Xrbr2 n_rbr RWL vss  vss nfet1 W='33n'

.ends

* ============================================================
* SNM READ TEST BENCH
* ============================================================

.param supply_v = 0.8
.global vdd vss

* Supplies
Vdd_src vdd 0 'supply_v'
Vss_src vss 0 0

* -------------------------------
* READ CONDITIONS (10T):
* - Precharge read bitlines HIGH
* - Assert RWL HIGH
* - Keep WWL LOW so write port is OFF
* -------------------------------
Vwwl WWL 0 0
Vwbl WBL 0 'supply_v'
Vwbr WBR 0 'supply_v'

Vrwl RWL 0 'supply_v'
Vrbl RBL 0 'supply_v'
Vrbr RBR 0 'supply_v'

* Sweep source driving open-loop inverters
Vin_sweep u 0 0

* DUT: 10T open-loop SRAM for read SNM
* Map q/qb -> v1/v2 for plotting/writing
Xdut u v1 v2 WWL WBL WBR RWL RBL RBR vdd vss SRAM10T_OPEN

* CSV writer: capture butterfly curve points
* (You can add RBL/RBR too if your csv_writer supports more pins.)
Xwrite v1 v2 u csv_writer

* DC sweep
.DC Vin_sweep 0 'supply_v' 0.005

.print DC V(v1) V(v2) V(u) V(RBL) V(RBR)

.end

