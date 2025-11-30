************************************************************************
* Subcircuit: Latch-Based Sense Amplifier (VLSA)
* Integrated with Sense Precharge and NAND SR Latch Output
************************************************************************
.subckt LATCH_SA BL BLB SE Q VDD VSS
.param lambda='11n'
.param w_n='3*lambda'
.param w_p='3*lambda'
* ======================================================================
* 1. SENSE LINE PRECHARGE CIRCUIT (Matches Diagram "Precharge")
* ======================================================================
* Operation: When SPE is LOW, these pull int_lft/rgt to VDD and equalize them.
* This prepares the nodes ST and SB (in diagram) for the next read.
* Sizing: Standard width is usually sufficient for precharge.
*XMp_pre_l  int_lft  SPE  VDD      VDD  pfet1 W='22n'
*XMp_pre_r  int_rgt  SPE  VDD      VDD  pfet1 W='22n'
*XMp_eq     int_lft  SPE  int_rgt  VDD  pfet1 W='22n'

* ======================================================================
* 2. INPUT ISOLATION / COUPLING
* ======================================================================
* Isolates the bitlines from the internal sense nodes.
* (Based on your original code structure).
XMp_1  int_lft  SE  BL   VDD  pfet1 W='22n'
XMp_2  int_rgt  SE  BLB  VDD  pfet1 W='22n'

* ======================================================================
* 3. THE FOOTER (NMOS TAIL)
* ======================================================================
* The "Gas Pedal". When SE goes High, this sinks current.
XMn_tail  COM_N  SE  VSS  VSS  nfet1  W='w_n * 10'

* ======================================================================
* 4. THE CROSS-COUPLED LATCH (The Brain)
* ======================================================================
* Left Side Inverter (Drives int_lft, Gate connected to int_rgt)
XMn_left  int_lft  int_rgt  COM_N  VSS  nfet1  W='w_n * 5'
XMp_left  int_lft  int_rgt  VDD    VDD  pfet1  W='w_p * 5'

* Right Side Inverter (Drives int_rgt, Gate connected to int_lft)
XMn_right int_rgt  int_lft  COM_N  VSS  nfet1  W='w_n * 5'
XMp_right int_rgt  int_lft  VDD    VDD  pfet1  W='w_p * 5'

* ======================================================================
* 5. OUTPUT NAND SR LATCH (Matches Diagram "Output FF")
* ======================================================================
* Uses the internal sense nodes (int_lft/rgt) as Set/Reset inputs.
* When Precharge is active (Inputs 1,1) -> Latch Holds state.
* When Sense fires (Inputs 0,1 or 1,0) -> Latch Updates.

*XNand_1  int_rgt  Q_bar  Q      VDD  VSS  NAND2
*XNand_2  int_lft  Q      Q_bar  VDD  VSS  NAND2


** Output buffer
Xinverter1 int_lft  node_x VDD VSS inverter_stage
Xinverter2 node_x   Q      VDD VSS inverter_stage

.ends LATCH_SA

************************************************************************
* Helper Subcircuit: 2-Input NAND Gate
************************************************************************
*.subckt NAND2 A B Out VDD VSS
*.param wn_nand='66n'
*.param wp_nand='66n'
* Pull-up Network (Parallel PMOS)
*XMp1 Out A VDD VDD pfet1 W='wp_nand'
*XMp2 Out B VDD VDD pfet1 W='wp_nand'
* Pull-down Network (Series NMOS)
*XMn1 Out A node_x VSS nfet1 W='wn_nand'
*XMn2 node_x B VSS VSS nfet1 W='wn_nand'
*.ends NAND2

.subckt inverter_stage In Out vdd vss
Xp Out In vdd vdd pfet1 W = '66n'
Xn Out In vss vss nfet1 W ='33n'
.ends inverter_stage

