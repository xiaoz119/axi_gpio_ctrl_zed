`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 04:56:15 PM
// Design Name: 
// Module Name: fsm_axi_lite_wr
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


module fsm_axi_lite_wr(
    input  clk,
    input  rst_n,
    input  start,
    output reg done_flag,
    // AXI4-Lite signal
    // Write address
    output reg awvalid,
    input awready,
    // Write data
    output reg wvalid,
    input wready,
    // Write Response
    input bvalid,
    output reg bready,
    input [1:0] bresp
    );

    // Write State
    reg [1:0] curr_state, next_state;
    localparam S_IDLE = 2'b00;
    localparam S_WAIT_ACK = 2'b01;
    localparam S_WRITE = 2'b10;
    localparam S_DONE = 2'b11;

    // write response
    wire resp_okay;
    assign resp_okay = (bresp == 2'b00) ? 1'b1 : 1'b0;

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
                if(awready && wready)
                    next_state = S_WRITE;
                else
                    next_state = S_WAIT_ACK;
            end
            S_WRITE: begin
                if(bvalid && resp_okay) 
                    next_state = S_DONE;
                else
                    next_state = S_WRITE;
            end
            S_DONE: begin
                next_state = S_IDLE;
            end
            default: next_state = S_IDLE;
        endcase
    end

    // Output logic
    always @(*) begin
        case (curr_state)
            S_IDLE: begin
                awvalid = 1'b0;
                wvalid = 1'b0;
                bready = 1'b0;
                done_flag = 1'b0;
            end
            S_WAIT_ACK: begin
                awvalid = 1'b1;
                wvalid = 1'b1;
                bready = 1'b1;
                done_flag = 1'b0;
            end
            S_WRITE: begin
                awvalid = 1'b0;
                wvalid = 1'b0;
                bready = 1'b1;
                done_flag = 1'b0;
            end
            S_DONE: begin
                awvalid = 1'b0;
                wvalid = 1'b0;
                bready = 1'b0;
                done_flag = 1'b1;
            end
            // default: begin
            //     awvalid = 1'b0;
            //     wvalid = 1'b0;
            //     bready = 1'b0;
            //     done_flag = 1'b0;
            // end
        endcase
    end
endmodule
