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
This will automatically create the Vivado project, add all necessary source files, and configure the design.
``` 
## Notes
- Ensure the Vivado version is 2023.1 or newer to avoid compatibility issues.
- IP cores may require regeneration if opened in a different environment.
