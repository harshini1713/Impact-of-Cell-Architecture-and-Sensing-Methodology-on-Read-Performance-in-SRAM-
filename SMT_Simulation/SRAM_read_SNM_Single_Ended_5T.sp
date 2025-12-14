* ============================================================
* 5T SRAM SNM READ TESTBENCH (Open-loop method)
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
* 5T SRAM "OPEN-LOOP" macro for SNM READ
*
* Ports:
*   u   = swept input driving both inverters (open-loop SNM)
*   q,qb= internal storage nodes (bench uses v1,v2)
*   WL,BL = single-ended access
* ------------------------------------------------------------
.subckt SRAM5T_OPEN u q qb WL BL vdd vss

* Open-loop SNM construction (two inverters driven by u)
XinvL u  q  vdd vss INVERTER_normal
XinvR u  qb vdd vss INVERTER_normal

* Single access device (1T) to single bitline (BL)
* (Connect to Q-side per your figure.)
Xacc q WL BL vss nfet1 W='33n'

.ends

* ============================================================
* SNM READ TEST BENCH
* ============================================================

.param supply_v = 0.8
.global vdd vss

* Supplies
Vdd_src vdd 0 'supply_v'
Vss_src vss 0 0

* READ CONDITIONS:
* WL asserted
* BL held at read-precharge (often VDD or slightly below in 5T; start with VDD)
Vwl WL 0 'supply_v'
Vbl BL 0 'supply_v'

* Sweep source driving open-loop inverters
Vin_sweep u 0 0

* DUT
Xdut u v1 v2 WL BL vdd vss SRAM5T_OPEN

* CSV writer (same as your flow)
Xwrite v1 v2 u csv_writer

* DC sweep
.DC Vin_sweep 0 'supply_v' 0.005

.print DC V(v1) V(v2) V(u) V(BL)

.end

