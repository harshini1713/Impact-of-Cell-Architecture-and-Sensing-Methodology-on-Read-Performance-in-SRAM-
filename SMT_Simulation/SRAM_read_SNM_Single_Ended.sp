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

* 1. GLOBAL PARAMETERS
.param supply_v = 0.8
.global vdd vss

* 2. VOLTAGE SOURCES
Vdd_src vdd 0 'supply_v'
Vss_src vss 0 0

* Read Conditions: Wordline (WL) and Bitlines (BL, BLB) are High
Vwl wl 0 'supply_v'
Vbl bl 0 'supply_v'
Vblb blb 0 'supply_v'

* Sweep Source: This drives the input of the open-loop inverters
Vin_sweep u 0 0

* 3. DEVICE UNDER TEST (DUT)
* We instantiate the "Half Cells" directly to create the open loop.
* This mimics the SRAM subcircuit components but breaks the feedback connection.

* --- Left Half Cell (Inverter 1 + Access Transistor) ---
* Input: u, Output: v1
X_inv1 u  v1 vdd vss INVERTER_normal
X_acc1 v1 wl bl vss nfet1 W ='33n'

* --- Right Half Cell (Inverter 2 + Access Transistor) ---
* Input: u, Output: v2
* Note: We drive the Right Half with the SAME sweep input (u) 
* to generate the mirrored VTC simultaneously.
X_inv2 u  v2 vdd vss INVERTER_normal
X_acc2 v2 wl blb vss nfet1 W ='33n'

* 4. SIMULATION COMMAND
* Sweep the input voltage from 0 to VDD
.DC Vin_sweep 0 'supply_v' 0.005

* 5. MEASUREMENTS (SNM CALCULATION)
* To find SNM, we rotate the coordinates by 45 degrees and find the max width.
* Coordinate transformation: u_rot = (u + v)/sqrt(2), v_rot = (u - v)/sqrt(2)
* SNM is the maximum length of the side of the square nested in the butterfly eye.

* Calculate the difference between the two curves in the rotated domain
* 'u' is the input voltage sweep, 'v1' and 'v2' are the outputs.
* Because the cell is symmetric, we can look at the difference between 
* the logic low curve and logic high curve relative to the diagonal.

.param sqrt2 = 1.41421356

* Define the "Butterfly Width" function in rotated coordinates
* This essentially measures the opening of the eye
E_snm_diff n_diff 0 VOL = '(V(v1) - V(u)) - (V(u) - V(v2))'

* Find the maximum separation
.MEAS DC max_diff MAX V(n_diff)

* Convert back to standard voltage units to get the final SNM value
.MEAS DC READ_SNM PARAM = 'max_diff * (1/sqrt2)'

.END

