`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 01:07:43 PM
// Design Name: 
// Module Name: axi4_lite_master_controller
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
////////////////////////////////////////////////////////////////////////////////
module axi4_lite_master_controller
  #(parameter AXI_ADDR_WIDTH = 9,
    parameter AXI_DATA_WIDTH = 32)
  (
    input ACLK,
    input ARESETN,
    output MEM_en,
    output MEM_we,
    output [8-1:0] MEM_addr,
    output [AXI_DATA_WIDTH-1:0] MEM_wdata,
    input [AXI_DATA_WIDTH-1:0] MEM_rdata,
    input M_ACLK,
    input M_ARESETN,
    output [AXI_ADDR_WIDTH-1:0] M_AXI_awaddr,
    input M_AXI_awready,
    output M_AXI_awvalid,
    output [AXI_DATA_WIDTH-1:0] M_AXI_wdata,
    input M_AXI_wready,
    output [(AXI_DATA_WIDTH/8)-1:0] M_AXI_wstrb,
    output M_AXI_wvalid,
    output M_AXI_bready,
    input [1:0] M_AXI_bresp,
    input M_AXI_bvalid,
    output [AXI_ADDR_WIDTH-1:0] M_AXI_araddr,
    input M_AXI_arready,
    output M_AXI_arvalid,
    input [AXI_DATA_WIDTH-1:0] M_AXI_rdata,
    output M_AXI_rready,
    input [1:0] M_AXI_rresp,
    input M_AXI_rvalid,
    input [31:0] instr, // Instruction input from external instruction_rom
    output [7:0] pc     // Program counter output to instruction_rom
  );

  // Internal signals
  wire wr_start_flag, wr_done_flag;
  wire rd_start_flag, rd_done_flag;
  wire wr_awvalid, wr_wvalid, wr_bready;
  wire rd_arvalid, rd_rready;
  wire rd_en_read;

  wire [AXI_ADDR_WIDTH-1:0] axi_r_w_addr;
  reg [AXI_ADDR_WIDTH-1:0] axi_wr_addr = 0;
  reg [AXI_ADDR_WIDTH-1:0] axi_rd_addr = 0;

  reg [AXI_DATA_WIDTH-1:0] axi_wr_data = 0;
  wire [AXI_DATA_WIDTH-1:0] axi_rd_data;

  reg [7:0] pc_reg = 0;
  wire [7:0] pc_next = pc_reg + 1;

  wire [3-1:0] opcode;
  wire [7-1:0] mem_r_w_addr;
  wire [7-1:0] axi_count;
  wire [7-1:0] axi_exec_count;

  wire en_pc;
  wire [7:0] axi_counter;
  wire en_mem;
  wire en_mem_wr;
  wire en_mem_rd;
  wire instr_done_flag;

  reg [32-1:0] mem_rdata = 0;

  // AXI IO Control
  assign M_AXI_wstrb = 4'b1111; // Hardcoded to enable writing to all byte lanes
  assign M_AXI_wdata = mem_rdata; 
  assign M_AXI_araddr = axi_rd_addr;
  assign M_AXI_awaddr = axi_wr_addr;
  assign axi_rd_data = M_AXI_rdata;

  // Program Counter
  always @ (posedge ACLK, negedge ARESETN) begin
    if (!ARESETN)
      pc_reg <= 8'b00000000;
    else
      pc_reg <= (en_pc)? pc_next : pc_reg;
      // if (en_pc) 
      //   pc_reg <= pc_next;
      //   else
    
  end

  assign pc = pc_reg; // Output program counter to external instruction_rom

  // Decoder 
  assign opcode = instr[2:0];
  assign axi_r_w_addr = instr[11:3];
  // assign mem_r_w_addr = instr[19:12];
  assign axi_count = instr[26:20];
  assign axi_counter = axi_count - axi_exec_count;
  // assign MEM_addr = mem_r_w_addr; 

  assign MEM_addr = instr[19:12];

  // Address calculation
  always @(*) begin
    axi_wr_addr = axi_r_w_addr  + (axi_counter << 2);
    axi_rd_addr = axi_r_w_addr  + (axi_counter << 2);
  end

  // Connect FSM outputs to AXI signals
  assign M_AXI_awvalid = wr_awvalid;
  assign M_AXI_wvalid = wr_wvalid;
  assign M_AXI_bready = wr_bready;

  assign M_AXI_arvalid = rd_arvalid;
  assign M_AXI_rready = rd_rready;

  // Memory control signals
  assign en_mem = en_mem_rd | en_mem_wr;
  assign MEM_en = en_mem;
  assign MEM_we = en_mem_wr;
  assign MEM_wdata = axi_rd_data;

  always @(posedge ACLK, negedge ARESETN) begin
    if (!ARESETN) 
      mem_rdata <= 0;
    else 
      mem_rdata <= (en_mem_rd) ? MEM_rdata : mem_rdata;
      // if (en_mem_rd) 
      //   mem_rdata <= MEM_rdata;
      // else
      //   mem_rdata <= mem_rdata
  end

  // FSM instantiations
  fsm_top_level u_fsm_top_level (
    .clk(ACLK),
    .rst_n(ARESETN),
    .opcode(opcode),
    .count(axi_count),
    .done_wr(wr_done_flag),
    .done_rd(rd_done_flag),
    .start_rd(rd_start_flag),
    .start_wr(wr_start_flag),
    .en_mem_rd(en_mem_rd),
    .en_pc(en_pc),
    .axi_exec_count(axi_exec_count),
    .done_instr(instr_done_flag)
  );

  fsm_axi_lite_wr u_fsm_axi_lite_wr (
    .clk(ACLK),
    .rst_n(ARESETN),
    .start(wr_start_flag),
    .done_flag(wr_done_flag),
    .awvalid(wr_awvalid),
    .awready(M_AXI_awready),
    .wvalid(wr_wvalid),
    .wready(M_AXI_wready),
    .bvalid(M_AXI_bvalid),
    .bready(wr_bready),
    .bresp(M_AXI_bresp)
  );

  fsm_axi_lite_rd u_fsm_axi_lite_rd (
    .clk(ACLK),
    .rst_n(ARESETN),
    .start(rd_start_flag),
    .done_flag(rd_done_flag),
    .en_mem_wr(en_mem_wr),
    .arready(M_AXI_arready),
    .arvalid(rd_arvalid),
    .rvalid(M_AXI_rvalid),
    .rready(rd_rready),
    .rresp(M_AXI_rresp)
  );

endmodule
