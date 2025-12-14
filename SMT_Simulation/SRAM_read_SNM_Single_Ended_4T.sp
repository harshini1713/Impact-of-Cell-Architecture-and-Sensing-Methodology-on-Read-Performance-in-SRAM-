* ============================================================
* LIBRARY INCLUDES (UNCOMMENTED)
* ============================================================
* Ensure the paths below match your actual folder structure
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' norm_2DFET
.lib './FEFET_LK_Model_ICDL_PSU/MOSFET_LIB.lib' Std_FET_22n_hp
* .include './differential_sa.sp'
* .hdl '../Jeffry/efet_comsol.va'
* .lib '../Jeffry/RSA_22_JV.lib' RSA
* .lib '../FEFET_LK_Model_ICDL_PSU/FEFET_LIB_UnEncrypted_22_mod.lib' fefet

* --- CSV WRITER ---
.hdl 'csv_write.va'

* --- OPTIONS ---
.OPTIONS DCCAP = 1
.OPTION POST
.option lis_new
.option ingold=2
.OPTION method=trap
.OPTION runlvl = 6
.OPTION CO=132
.option measform=3
.option numdgt=12

* ============================================================
* 4T SRAM HALF-CELL SUBCIRCUIT
* ============================================================
* Topology: Loadless 4T (NMOS Driver + PMOS Access)
.subckt HALF_CELL_4T q qb_in wl bl vdd vss
    * Driver Transistor (Pull Down)
    Xn_driver q qb_in vss vss nfet1 W='44n'

    * Access Transistor (Acts as Load during Read)
    Xp_access q wl bl vdd pfet1 W='33n'
.ends

* ============================================================
* SNM READ TEST BENCH (4T Configuration)
* ============================================================

.param supply_v = 0.8
.global vdd vss

* 1. VOLTAGE SOURCES
Vdd_src vdd 0 'supply_v'
Vss_src vss 0 0

* 2. READ CONDITIONS
Vbl bl 0 'supply_v'
Vblb blb 0 'supply_v'
* Wordline Low (0V) to turn on PMOS Access
Vwl wl 0 0

* 3. SWEEP SOURCE
Vin_sweep u 0 0

* 4. DEVICE UNDER TEST (DUT)
* --- Left Half Cell ---
X_left v1 u wl bl vdd vss HALF_CELL_4T

* --- Right Half Cell ---
X_right v2 u wl blb vdd vss HALF_CELL_4T

* 5. CSV WRITER
Xwrite v1 v2 u csv_writer

* 6. SIMULATION COMMAND
.DC Vin_sweep 0 'supply_v' 0.005

.print DC V(v1) V(v2) V(u)
.end
