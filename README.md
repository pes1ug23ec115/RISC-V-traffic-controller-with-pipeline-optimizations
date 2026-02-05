RISC-V 5-Stage Pipeline Traffic Controller
A real-time traffic management system written in RISC-V Assembly, specifically engineered and verified for a 5-stage pipeline architecture using the Ripes simulator.

🚦 Overview
This project implements an intelligent traffic light controller for a four-way intersection. It is built with a "hardware-first" mindset, manually managing the timing and hazards inherent in pipelined processors—stages typically abstracted away by high-level languages.

🛠 Technical Features
Pipeline-Aware Design: Optimized for the standard 5-stage pipeline (IF, ID, EX, MEM, WB).

Hazard Mitigation: Features strategic instruction scheduling and NOP insertion to handle:

Load-Use Hazards: Ensuring data loaded from memory is ready before being used in the next cycle.

Control Hazards: Managing branch latencies to ensure correct execution flow.

Multi-Mode Finite State Machine (FSM):

Normal: Standard intersection cycling.

Rush Hour: Modified timing for peak traffic.

Emergency Flash: Cautionary flashing mode.

All-Way Stop: Immediate safety halt.

Memory-Mapped I/O (MMIO): Directly interfaces with a 25x25 LED display at address 0xF0000000.

🖥 Simulation in Ripes
This project was developed and tested using Ripes, utilizing its visual pipeline tool to verify hazard handling.

How to Run:
Open the Ripes simulator.

Load orange_code.s.

IO Setup: Configure a D/A (Digital-to-Analog) or LED Display peripheral.

Base Address: 0xF0000000

Width/Height: 25 x 25

Switch to the Processor Tab and select a 5-stage processor model (e.g., 5-stage RISC-V processor).

Run the simulation and observe the "Instruction Pipeline" view to see the hazard handling in action.

🏗 Key Components
Diagnostic Suite: Verifies LED address accessibility before starting.

Animation Engine: Uses a dedicated frame counter to drive smooth transitions on the display.

Cycle Counter: Real-time tracking of processor cycles for performance benchmarking.
