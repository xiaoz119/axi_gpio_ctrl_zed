`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2025 04:43:48 PM
// Design Name: 
// Module Name: axi_ctrl_gpio_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module axi_ctrl_gpio_top(
    input wire sys_clk,       // System clock
    input wire btn_c,         // Active-low reset
    input wire [7:0] sws,    // 8-bit button input
    output wire [7:0] leds    // 8-bit LED output
);

    // Internal signals
    wire clk;
    wire reset_n = !btn_c; // Zedboard reset signal is active-high

    // Signals for LED (write) controller
    wire [8:0] axi_awaddr_led;
    wire axi_awvalid_led;
    wire axi_awready_led;
    wire [31:0] axi_wdata_led;
    wire [3:0] axi_wstrb_led;
    wire axi_wvalid_led;
    wire axi_wready_led;
    wire [1:0] axi_bresp_led;
    wire axi_bvalid_led;
    wire axi_bready_led;
    wire [8:0]axi_araddr_led;
    wire axi_arvalid_led;
    wire axi_arready_led;
    wire [31:0] axi_rdata_led;
    wire [1:0] axi_rresp_led;
    wire axi_rvalid_led;
    wire axi_rready_led;

    // Signals for Button (read) controller
    wire [8:0] axi_awaddr_btn;
    wire axi_awvalid_btn;
    wire axi_awready_btn;
    wire [31:0] axi_wdata_btn;
    wire [3:0] axi_wstrb_btn;
    wire axi_wvalid_btn;
    wire axi_wready_btn;
    wire [1:0] axi_bresp_btn;
    wire axi_bvalid_btn;
    wire axi_bready_btn;
    wire [8:0] axi_araddr_btn;
    wire axi_arvalid_btn;
    wire axi_arready_btn;
    wire [31:0] axi_rdata_btn;
    wire [1:0] axi_rresp_btn;
    wire axi_rvalid_btn;
    wire axi_rready_btn;

    // Signals for BRAM (dual-port)
    wire bram_ena_led, bram_wea_led;
    wire [7:0] bram_addra_led;
    wire [31:0] bram_dina_led;
    wire [31:0] bram_douta_led;

    wire bram_enb_btn, bram_web_btn;
    wire [7:0] bram_addrb_btn;
    wire [31:0] bram_dinb_btn;
    wire [31:0] bram_doutb_btn;

    // Instruction ROM signals for LED (write) controller
    wire [31:0] instr_led;
    wire [7:0] pc_led;

    // Instruction ROM signals for Button (read) controller
    wire [31:0] instr_btn;
    wire [7:0] pc_btn;

    // Assign internal clock
    assign clk = sys_clk;

    // Instantiate the LED (write) AXI4 Lite Master Controller
    axi4_lite_master_controller #(
        .AXI_ADDR_WIDTH(9),
        .AXI_DATA_WIDTH(32)
    ) uut_axi4_lite_master_controller_led (
        .ACLK(clk),
        .ARESETN(reset_n),
        .MEM_en(bram_ena_led),
        .MEM_we(bram_wea_led),
        .MEM_addr(bram_addra_led),
        .MEM_wdata(bram_dina_led),
        .MEM_rdata(bram_douta_led),
        .M_ACLK(clk),
        .M_ARESETN(reset_n),
        .M_AXI_araddr(axi_araddr_led),
        .M_AXI_arready(axi_arready_led),
        .M_AXI_arvalid(axi_arvalid_led),
        .M_AXI_awaddr(axi_awaddr_led),
        .M_AXI_awready(axi_awready_led),
        .M_AXI_awvalid(axi_awvalid_led),
        .M_AXI_bready(axi_bready_led),
        .M_AXI_bresp(axi_bresp_led),
        .M_AXI_bvalid(axi_bvalid_led),
        .M_AXI_rdata(axi_rdata_led),
        .M_AXI_rready(axi_rready_led),
        .M_AXI_rresp(axi_rresp_led),
        .M_AXI_rvalid(axi_rvalid_led),
        .M_AXI_wdata(axi_wdata_led),
        .M_AXI_wready(axi_wready_led),
        .M_AXI_wstrb(axi_wstrb_led),
        .M_AXI_wvalid(axi_wvalid_led),
        .instr(instr_led),
        .pc(pc_led)
    );

    // Instantiate the Button (read) AXI4 Lite Master Controller
    axi4_lite_master_controller #(
        .AXI_ADDR_WIDTH(9),
        .AXI_DATA_WIDTH(32)
    ) uut_axi4_lite_master_controller_btn (
        .ACLK(clk),
        .ARESETN(reset_n),
        .MEM_en(bram_enb_btn),
        .MEM_we(bram_web_btn),
        .MEM_addr(bram_addrb_btn),
        .MEM_wdata(bram_dinb_btn),
        .MEM_rdata(bram_doutb_btn),
        .M_ACLK(clk),
        .M_ARESETN(reset_n),
        .M_AXI_araddr(axi_araddr_btn),
        .M_AXI_arready(axi_arready_btn),
        .M_AXI_arvalid(axi_arvalid_btn),
        .M_AXI_awaddr(axi_awaddr_btn),
        .M_AXI_awready(axi_awready_btn),
        .M_AXI_awvalid(axi_awvalid_btn),
        .M_AXI_bready(axi_bready_btn),
        .M_AXI_bresp(axi_bresp_btn),
        .M_AXI_bvalid(axi_bvalid_btn),
        .M_AXI_rdata(axi_rdata_btn),
        .M_AXI_rready(axi_rready_btn),
        .M_AXI_rresp(axi_rresp_btn),
        .M_AXI_rvalid(axi_rvalid_btn),
        .M_AXI_wdata(axi_wdata_btn),
        .M_AXI_wready(axi_wready_btn),
        .M_AXI_wstrb(axi_wstrb_btn),
        .M_AXI_wvalid(axi_wvalid_btn),
        .instr(instr_btn),
        .pc(pc_btn)
    );

    // Instantiate the Instruction ROM for LED (write) controller
    instruction_rom_wr uut_instruction_rom_led (
        .clk(clk),
        .addr(pc_led),
        .data(instr_led)
    );

    // Instantiate the Instruction ROM for Button (read) controller
    instruction_rom_rd uut_instruction_rom_btn (
        .clk(clk),
        .addr(pc_btn),
        .data(instr_btn)
    );

    // Instantiate the Dual-Port BRAM
    blk_mem_gen_0 uut_bram (
        .clka(clk),
        .ena(bram_ena_led),
        .wea({bram_wea_led}),
        .addra(bram_addra_led),
        .dina(bram_dina_led),
        .douta(bram_douta_led),
        .clkb(clk),
        .enb(bram_enb_btn),
        .web({bram_web_btn}),
        .addrb(bram_addrb_btn),
        .dinb(bram_dinb_btn),
        .doutb(bram_doutb_btn)
    );

    // Instantiate the GPIO for LEDs
    axi_gpio_0 uut_gpio_led (
        .s_axi_aclk(clk),
        .s_axi_aresetn(reset_n),
        .s_axi_awaddr(axi_awaddr_led),
        .s_axi_awvalid(axi_awvalid_led),
        .s_axi_awready(axi_awready_led),
        .s_axi_wdata(axi_wdata_led),
        .s_axi_wstrb(axi_wstrb_led),
        .s_axi_wvalid(axi_wvalid_led),
        .s_axi_wready(axi_wready_led),
        .s_axi_bresp(axi_bresp_led),
        .s_axi_bvalid(axi_bvalid_led),
        .s_axi_bready(axi_bready_led),
        .s_axi_araddr(axi_araddr_led),
        .s_axi_arvalid(axi_arvalid_led),
        .s_axi_arready(axi_arready_led),
        .s_axi_rdata(axi_rdata_led),
        .s_axi_rresp(axi_rresp_led),
        .s_axi_rvalid(axi_rvalid_led),
        .s_axi_rready(axi_rready_led),
        .gpio_io_o(leds) // Connect GPIO output to LEDs
    );

    // Instantiate the GPIO for Buttons
    axi_gpio_1 uut_gpio_btn (
        .s_axi_aclk(clk),
        .s_axi_aresetn(reset_n),
        .s_axi_awaddr(axi_awaddr_btn),
        .s_axi_awvalid(axi_awvalid_btn),
        .s_axi_awready(axi_awready_btn),
        .s_axi_wdata(axi_wdata_btn),
        .s_axi_wstrb(axi_wstrb_btn),
        .s_axi_wvalid(axi_wvalid_btn),
        .s_axi_wready(axi_wready_btn),
        .s_axi_bresp(axi_bresp_btn),
        .s_axi_bvalid(axi_bvalid_btn),
        .s_axi_bready(axi_bready_btn),
        .s_axi_araddr(axi_araddr_btn),
        .s_axi_arvalid(axi_arvalid_btn),
        .s_axi_arready(axi_arready_btn),
        .s_axi_rdata(axi_rdata_btn),
        .s_axi_rresp(axi_rresp_btn),
        .s_axi_rvalid(axi_rvalid_btn),
        .s_axi_rready(axi_rready_btn),
        .gpio_io_i(sws) // Connect GPIO input to buttons
    );

endmodule
