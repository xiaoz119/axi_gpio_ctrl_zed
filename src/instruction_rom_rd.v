`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2025 11:39:37 AM
// Design Name: 
// Module Name: instruction_rom_rd
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


module instruction_rom_rd(
    input wire clk,
    input wire [7:0] addr,  // Program counter input
    output reg [31:0] data  // Instruction output
);

    // Memory array to store instructions
    reg [31:0] memory [0:255]; // 256 instructions, each 32 bits wide

    // Load instructions from the .mem file
    initial begin
        $readmemb("instr_mem_rd.mem", memory);
    end

    // Read instruction on clock edge
    always @(posedge clk) begin
        data <= memory[addr];
    end

endmodule
