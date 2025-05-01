# AXI Controller GPIO Project for ZedBoard

This repository contains a Vivado project that implements an AXI4-Lite-based GPIO controller for the ZedBoard.

## Requirements

- **Vivado Version**: 2023.1 or higher  
- **Board**: ZedBoard (Zynq-7000)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/axi_ctrl_gpio_zed.git
cd axi_ctrl_gpio_zed
```

### 2. Launch Vivado and Open the TCL Console
Start Vivado and open the Tcl Console.

### 3. Run the Setup Script
In the Tcl Console, navigate to the project directory and run:

```bash
cd <full_path_to_repo>
source axi_ctrl_gpio_zed.tcl
```

This will automatically create the Vivado project, add all necessary source files, and configure the design.
## Notes
- Ensure the Vivado version is 2023.1 or newer to avoid compatibility issues.
- IP cores may require regeneration if opened in a different environment.

## BLOCK Diagram
<p align="center">
  <img src="figure/block_diagram_axi_gpio.jpg" width="600"/>
</p
  
## Controller Instruction Set
### 🧠 Instruction Format Overview

| Bit Range  | 31–27       | 26–20     | 19–12       | 11–3        | 2–0      |
|------------|-------------|-----------|-------------|-------------|----------|
| Field Name | `RESERVED`  | `COUNT`   | `ADDR_LOCAL`| `ADDR_AXI`  | `OPCODE` |
        
Each instruction is exactly 32 bits, structured as follows:

| Bits       | Field Name   | Width | Description                                 |
|------------|--------------|-------|---------------------------------------------|
| 31 – 27    | `RESERVED`   | 5     | Reserved for future use                     |
| 26 – 20    | `COUNT`      | 7     | Number of read/write transactions (0–127)   |
| 19 – 12    | `ADDR_LOCAL` | 8     | Internal/local address                      |
| 11 – 3     | `ADDR_AXI`   | 9     | AXI4-Lite address (9-bit aligned)           |
| 2 – 0      | `OPCODE`     | 3     | Operation type (Read, Write, etc.)          |

### `OPCODE` (Bits 2:0)

| Value | Operation      |
|-------|----------------|
| `000` | NOP / Reserved |
| `001` | AXI4 Read      |
| `010` | AXI4 Write     |
| `011` – `111` | Reserved for future |

### `ADDR_AXI` (Bits 11:3)

- 9-bit AXI address
- Aligned to your AXI4-Lite address width (typically byte addressable)

### `ADDR_LOCAL` (Bits 19:12)

- Local memory/register address, used internally by the controller.

### `COUNT` (Bits 26:20)

- Number of times to perform the operation (e.g., burst-like behavior)
- Range: 0–127 (interpret 0 as 1 if needed)

### `RESERVED` (Bits 31:27)

- Reserved for future use (e.g., flags, conditions, priority bits)
- Always set to 0 in the current version


### Example 1: AXI4 Read
- `OPCODE`: `001` (Read)
- `ADDR_AXI`: `0x1A5` (binary: `00000000`) (The AXI_ARADDR is 0000_0000)
- `ADDR_LOCAL`: `0x4F` (binary: `00000000`) (Write the read data to the local data memory starting at address 0000_0000)
- `COUNT`: `0x05` (binary: `0000101`)
- `RESERVED`: `00000`


## How to use Instructions
1. Wirte the instructions in binary as above format to the instr_mem_xx.mem file
2. For write operation, write the data to the data_mem.coe file