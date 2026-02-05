# RISC-V 5-Stage Pipeline Traffic Controller

A real-time traffic management system written in **RISC-V Assembly**, specifically engineered and verified for a **5-stage pipeline architecture** using the **Ripes** simulator.

---

## 🚦 Overview
This project implements an intelligent traffic light controller for a four-way intersection. It is built with a **"hardware-first"** mindset, manually managing the timing and hazards inherent in pipelined processors—stages typically abstracted away by high-level languages.

---

## 🎥 What’s Happening on the LED Screen?
Think of the LED grid as a birds-eye view of a **busy city intersection**. The code acts as the "Traffic Police," directing the flow of virtual cars by controlling four sets of signals.

### **The Visual Layout**
* **The Intersection:** You’ll see a dark grey cross. This represents the **asphalt** where the two roads meet.
* **The Four Signals:** There are lights at the North, South, East, and West ends of the cross.
* **The Pulse:** The lights aren't just flat dots; they have a slight **"flicker" or movement**. This is a **heartbeat animation**—it shows that the "brain" of the controller is actively thinking and processing data every millisecond.

### **🕒 Timing & Logic**
The system follows a strict schedule to keep the roads safe:
* 🟢 **Green:** Traffic is allowed to move.
* 🟡 **Yellow:** The "warning" phase, telling cars to prepare to stop.
* 🔴 **Red:** The "wait" phase, allowing the other road to take its turn.

---

## 🔄 Dynamic Traffic Patterns
The controller automatically changes its behavior to simulate real-world traffic scenarios:

1. **Normal Flow:** Standard, equal timing for all sides.
2. **Rush Hour:** Timing is adjusted to handle heavier traffic flow efficiently.
3. **Emergency Override:** All four lights flash **Orange**. This represents an emergency vehicle (like a fire truck) passing through.
4. **All-Way Stop:** Every light turns **Red**. This is the safety **"Fail-Safe"** mode that halts all traffic instantly.

---

## 🛠️ How to Execute (Step-by-Step)
To see the traffic controller in action in **Ripes**, follow these instructions exactly:

1. **Copy the Code:** Copy the assembly code into a standard text file (e.g., `traffic.s`).
2. **Load in Ripes:** Open the **Ripes** application and load your saved file.
3. **Configure the LED Matrix:** * Open the **I/O Tab**.
   * Set **Height** & **Width** to **25**.
   * Set **LED Size** to **16**.
4. **Run the Simulation:**
   * Press the **Play** button on the top bar.
   * Reduce the **Time** (speed) slider beside the play button to **1ms – 10ms**.
   * **Pause** the execution using the same button if you need to inspect the state.
   * To see the high-speed logic, press the **Double Forward (≫)** sign beside the play button.
