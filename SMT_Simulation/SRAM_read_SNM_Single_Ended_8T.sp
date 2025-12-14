* ============================================================
* 8T SRAM SNM READ TESTBENCH (Open-loop method)
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
* Inverter used for the open-loop SNM method
* ------------------------------------------------------------
.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W='22n'
Xn Out In vss vss nfet1 W='44n'
.ends

* ------------------------------------------------------------
* 8T "OPEN-LOOP" SRAM macro for READ SNM
*
* Ports:
*   u   = swept input driving both inverters (open-loop SNM)
*   q,qb= internal storage nodes (bench uses v1,v2)
*   WWL/WBL/WBR = write port (OFF during read SNM)
*   RWL/RB      = decoupled single-ended read port
* ------------------------------------------------------------
.subckt SRAM8T_OPEN u q qb WWL WBL WBR RWL RB vdd vss

* Two inverters (open-loop SNM construction)
XinvL u  q  vdd vss INVERTER_normal
XinvR u  qb vdd vss INVERTER_normal

* Write access devices (2T) -- keep WWL=0 during read SNM
XwL  q  WWL WBL vss nfet1 W='33n'
XwR  qb WWL WBR vss nfet1 W='33n'

* Decoupled read port (2T stack), single-ended RB
* RB discharges when (QB=1) AND (RWL=1)
Xr1  RB  qb  n_rd vss nfet1 W='33n'
Xr2  n_rd RWL vss vss nfet1 W='33n'

* If your 8T variant uses Q instead of QB for read, change Xr1 to:
* Xr1  RB  q   n_rd vss nfet1 W='33n'

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
* READ CONDITIONS (8T):
* - Precharge RB HIGH
* - Assert RWL HIGH
* - Keep WWL LOW so write port is OFF
* -------------------------------
Vwwl WWL 0 0
Vwbl WBL 0 'supply_v'
Vwbr WBR 0 'supply_v'

Vrwl RWL 0 'supply_v'
Vrb  RB  0 'supply_v'

* Sweep source driving open-loop inverters
Vin_sweep u 0 0

* DUT: 8T open-loop SRAM for read SNM
* Map q/qb -> v1/v2 for plotting/writing
Xdut u v1 v2 WWL WBL WBR RWL RB vdd vss SRAM8T_OPEN

* CSV writer: capture butterfly curve points
Xwrite v1 v2 u csv_writer

* DC sweep
.DC Vin_sweep 0 'supply_v' 0.005

.print DC V(v1) V(v2) V(u) V(RB)

.end

