# Impact of Cell Architecture and Sensing Methodology on Read Performance in SRAM and FeFET Memories

Modern computing systems increasingly demand **higher speed**, **lower power**, and **greater robustness** from memory subsystems. While **SRAM** remains the primary choice for on-chip storage due to its reliability and fast access times, traditional **6T SRAM** faces challenges in variability, noise margins, and technology scaling. Emerging topologies such as **8T/10T SRAM** and **FeFET-based memory cells** offer potential improvements but require thorough evaluation of read behavior.

This project systematically compares **read latency** and **read static noise margin (RSNM)** across multiple memory-cell architectures and sensing methodologies to determine optimal combinations for low-power, high-performance memory designs.

---

## Objectives

### **1. Comparative Evaluation of Memory Cell & Sense Amplifier Architectures**

We design, simulate, and benchmark the following bit-cell and sense-amplifier structures:

| Memory Cell Architecture                | Sense Amplifier Architecture     |
|----------------------------------------|----------------------------------|
| 6T SRAM (baseline reference)           | Differential Sense Amplifier     |
| 8T differential-read SRAM              | Latch-Based Sense Amplifier      |
| 10T SRAM (with improved read isolation)| —                                |
| FeFET-based non-volatile memory cell   | —                                |

For each combination, we extract and compare:

- **Read latency**
- **Read static noise margin (RSNM)**

This allows us to map which sense-amplifier architecture is best suited for each memory topology.

---

### **2. Evaluation of Single-Ended Read Schemes (No Dedicated Sense Amplifier)**

We also examine memory designs using **single-ended sensing**, relying only on bitline voltage swing:

- 6T SRAM (baseline)
- 5T SRAM
- 4T SRAM (dynamic, leakage-limited)

For these designs, we explore:

- Methods to **reduce read latency**
- Trade-offs between **simplicity/area** and **read robustness**

---
