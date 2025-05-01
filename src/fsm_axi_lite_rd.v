`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 01:54:46 PM
// Design Name: 
// Module Name: fsm_axi_lite_rd
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


module fsm_axi_lite_rd(
    input  clk,
    input  rst_n,
    input  start,
    output reg done_flag,
    output  en_mem_wr,
    // AXI4-Lite signal
    input arready,
    output reg arvalid,  
    input rvalid,
    output reg rready,
    input [1:0] rresp
    );
    
    // Read State    
    reg [1:0] curr_state, next_state;
    localparam S_IDLE = 2'b00;
    localparam S_WAIT_ACK = 2'b01;
    localparam S_READ = 2'b10;
    localparam S_DONE = 2'b11;
    // read response
    wire resp_okay;
    assign resp_okay = (rresp == 2'b00) ? 1'b1 : 1'b0;
    
    // Sequential block
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            curr_state <= S_IDLE;
        else
            curr_state <= next_state;
    end
    
    // Transitation
    always @(*) begin
        case (curr_state)
            S_IDLE: begin
                if(start) 
                    next_state = S_WAIT_ACK;
                else
                    next_state = S_IDLE;
            end
            
            S_WAIT_ACK: begin
                if(arready)
                    next_state = S_READ;
                else
                    next_state = S_WAIT_ACK;
            end
            S_READ: begin 
                if(rvalid && resp_okay)
                    next_state = S_DONE;
                else
                    next_state = S_READ;        
            end
            S_DONE: next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end
    
    
    // Output logic
    always @(*) begin
        case (curr_state)
            S_IDLE: begin
                arvalid = 1'b0;
                rready = 1'b0;
                done_flag = 1'b0;
            end
            S_WAIT_ACK: begin
                arvalid = 1'b1;
                rready = 1'b1;
                done_flag = 1'b0;
            end
            S_READ: begin
                arvalid = 1'b0;
                rready = 1'b1;
                done_flag = 1'b0;
            end
            S_DONE:begin
                arvalid = 1'b0;
                rready = 1'b1;
                done_flag = 1'b1;
            end
        endcase
    end

    assign en_mem_wr = rready && rvalid && resp_okay;
    
    
endmodule
