*.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
*.include './differential_sa.sp'
*.hdl '../Jeffry/efet_comsol.va'
*.lib '../Jeffry/RSA_22_JV.lib' RSA
*.lib '../FEFET_LK_Model_ICDL_PSU/FEFET_LIB_UnEncrypted_22_mod.lib' fefet

* --- INCLUDE THE CSV WRITER (See Step 2) ---
.hdl 'csv_write.va'

*Include DC operating point capacitances.
.OPTIONS DCCAP = 1
*Enable post-processing/output data for waveform viewing
.OPTION POST
*Control listing/output formats.
.option lis_new
.option ingold=2  
*Ingold=2 forces exponential notation (e.g., 1.2e-09) which is safer for CSV parsing
.OPTION method=trap
.OPTION runlvl = 6
.OPTION CO=132
.option measform=3
.option numdgt=12

.subckt INVERTER_normal In Out vdd vss
Xp Out In vdd vdd pfet1 W = '22n'
Xn Out In vss vss nfet1 W ='44n'
.ends

.subckt SRAM wl bl blb q qb vdd vss
X1 q qb vdd vss INVERTER_normal
X2 qb q vdd vss INVERTER_normal
X1a q wl bl vss nfet1 W ='33n'
X1b qb wl blb vss nfet1 W ='33n'
.ends

* ============================================================
* SNM READ TEST BENCH
* ============================================================

.param supply_v = 0.8
.global vdd vss

* 2. VOLTAGE SOURCES
Vdd_src vdd 0 'supply_v'
Vss_src vss 0 0

* Read Conditions: Wordline (WL) and Bitlines (BL, BLB) are High
Vwl wl 0 'supply_v'
Vbl bl 0 'supply_v'
Vblb blb 0 'supply_v'

* Sweep Source: Drives the input of the open-loop inverters
Vin_sweep u 0 0

* 3. DEVICE UNDER TEST (DUT)
* --- Left Half Cell ---
X_inv1 u  v1 vdd vss INVERTER_normal
X_acc1 v1 wl bl vss nfet1 W ='33n'

* --- Right Half Cell ---
X_inv2 u  v2 vdd vss INVERTER_normal
X_acc2 v2 wl blb vss nfet1 W ='33n'

* 4. CSV WRITER INSTANCE
* This block reads the voltages and writes them to the CSV file
Xwrite v1 v2 u csv_writer

* 5. SIMULATION COMMAND
.DC Vin_sweep 0 'supply_v' 0.005

* Standard Print (Backup for .lis file)
.print DC V(v1) V(v2) V(u)

.end
