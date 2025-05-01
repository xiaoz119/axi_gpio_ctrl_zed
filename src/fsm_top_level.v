`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2025 10:34:57 AM
// Design Name: 
// Module Name: fsm_top_level
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


module fsm_top_level(
        input clk,
        input rst_n,
        input [2:0] opcode,
        input [6:0] count,
        // Control Signal,
        input done_wr,
        input done_rd,
        // output reg [1:0] curr_state,
        output reg start_rd,
        output reg start_wr,
        output reg en_mem_rd,
        output reg en_pc,
        output reg [6:0] axi_exec_count,
        output reg done_instr
    );

    // Internal signals and registers
    // axi_exec_count = 7'b0; // Initialization is handled in the always block below
    wire en_count_load;
    // wire en_count_update;
    wire done_axi_exec = done_wr | done_rd;
    wire run = opcode != 3'b000;
    wire stall = opcode == 3'b111;

    // Delay Counter
    parameter DELAY_CYCLES = 1;  // e.g., set to 2 if RAM has 2-cycle latency
    reg [$clog2(DELAY_CYCLES+1)-1:0] delay_counter;
    reg instr_valid;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_counter <= 0;
            instr_valid <= 0;
        end else begin
            if (en_pc)
                delay_counter <= DELAY_CYCLES;
            else if (delay_counter != 0)
                delay_counter <= delay_counter - 1;

            instr_valid <= (delay_counter == 1); // assert one cycle before 0
        end
    end

    // Control state
    reg [2:0] curr_state, next_state;
    localparam S_IDLE              = 3'b000;
    localparam S_FETCH             = 3'b001;
    localparam S_DECODE            = 3'b010;
    localparam S_AXI_EXECUTE_START = 3'b011;
    localparam S_AXI_EXECUTE       = 3'b100;
    localparam S_COUNT_CHECK       = 3'b101;
    localparam S_AXI_EXECUTE_DONE  = 3'b110;
    localparam S_STALL             = 3'b111;

    
    
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;
    end

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            axi_exec_count <= 7'b0000000;
        else begin
            if (en_count_load) 
                axi_exec_count <= count;
            else if (done_axi_exec)
                axi_exec_count <= axi_exec_count - 1;
            else
                axi_exec_count <= axi_exec_count;
        end
    end
    
    // Transition
    always @(*) begin
        case (curr_state)
            S_IDLE: begin 
                next_state = S_FETCH;
            end
            S_FETCH: next_state = S_DECODE;
            S_DECODE: next_state = (instr_valid) ?  S_AXI_EXECUTE_START : S_DECODE;
            S_AXI_EXECUTE_START: next_state = (opcode != 3'b000) ? S_AXI_EXECUTE : S_AXI_EXECUTE_DONE;
            S_AXI_EXECUTE: begin
                if (done_axi_exec)
                    next_state = S_COUNT_CHECK;
                else
                    next_state = S_AXI_EXECUTE;
            end
            S_COUNT_CHECK: begin
                if (axi_exec_count != 7'b0000000) 
                    next_state = S_AXI_EXECUTE_START;
                else
                    next_state = S_AXI_EXECUTE_DONE;
            end
            S_AXI_EXECUTE_DONE: next_state = S_IDLE;
            // S_STALL: begin
            //     // Remain in S_STALL state until external conditions change
            // end
            default: next_state = S_IDLE;
        endcase
    end

    // Output logic
    always @(*) begin
        case (curr_state)
            S_IDLE: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b0;
                en_mem_rd = 1'b0;
                done_instr = 1'b0;
            end
            S_FETCH: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b1;
                en_mem_rd = 1'b0;
                done_instr = 1'b0;

            end
            S_DECODE: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b0;
                en_mem_rd = 1'b0;
                done_instr = 1'b0;

            end
            S_AXI_EXECUTE_START: begin
                case (opcode)
                    3'b001: begin
                        // Read operation
                        start_rd = 1'b1;
                        start_wr = 1'b0;
                        en_pc = 1'b0;
                        en_mem_rd = 1'b0;
                        done_instr = 1'b0;
                    end
                    3'b010: begin
                        // Write operation
                        start_rd = 1'b0;
                        start_wr = 1'b1;
                        en_pc = 1'b0;
                        en_mem_rd = 1'b0;
                        done_instr = 1'b0;
                    end
                    default: begin
                        // Default case: No operation
                        start_rd = 1'b0;
                        start_wr = 1'b0;
                        en_pc = 1'b0;
                        en_mem_rd = 1'b0;
                        done_instr = 1'b0;
                    end
                endcase
            end
            S_AXI_EXECUTE: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b0;
                en_mem_rd = 1'b1;
                done_instr = 1'b0;
            end
            S_COUNT_CHECK: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b0;
                en_mem_rd = 1'b0;
                done_instr = 1'b0;
            end
            S_AXI_EXECUTE_DONE: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b0;
                en_mem_rd = 1'b0;
                done_instr = 1'b1;
            end
            S_STALL: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b0;
                en_mem_rd = 1'b0;
                done_instr = 1'b0;
            end
            default: begin
                start_rd = 1'b0;
                start_wr = 1'b0;
                en_pc = 1'b0;
                en_mem_rd = 1'b0;
                done_instr = 1'b0;
            end
        endcase
    end

    assign en_count_load = (curr_state == S_DECODE);

endmodule
