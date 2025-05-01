`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2025 05:10:50 PM
// Design Name: 
// Module Name: axi_ctrl_gpio_top_tb
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
module axi_ctrl_gpio_top_tb;

    // Testbench signals
    reg sys_clk;
    reg btn_c;
    reg [7:0] sws; // 8-bit button input
    wire [7:0] leds; // 8-bit LED output

    // Clock generation
    initial begin
        sys_clk = 0;
        forever #5 sys_clk = ~sys_clk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        btn_c = 1; // Active-low reset
        #50 btn_c = 0; // Release reset after 50 ns
    end

    // Stimulus for buttons
    initial begin
        sws = 8'b00000000; // Initialize buttons to 0
        #100 sws = 8'b00001111; // Change button values after 100 ns
        #100 sws = 8'b11110000; // Change button values after another 100 ns
        #100 sws = 8'b10101010; // Change button values after another 100 ns
        #100 sws = 8'b01010101; // Change button values after another 100 ns
    end

    // Instantiate the top-level module
    axi_ctrl_gpio_top uut_axi_ctrl_gpio_top (
        .sys_clk(sys_clk),
        .btn_c(btn_c),
        .sws(sws),
        .leds(leds)
    );

    // Monitor button inputs and LED outputs
    initial begin
        $monitor("Time: %0t | Reset: %b | Buttons: %b | LEDs: %b", $time, btn_c, btns, leds);
    end

    // Simulation control
    initial begin
        #1000; // Run simulation for 1000 ns
        $finish; // End simulation
    end

endmodule
