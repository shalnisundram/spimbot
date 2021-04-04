module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target;
    wire [31:0]  inst;

    wire [31:0]  imm = {{ 16{inst_IF[15]} }, inst_IF[15:0] };  // sign-extended immediate
    wire [4:0]   rs = inst_IF[25:21];
    wire [4:0]   rt = inst_IF[20:16];
    wire [4:0]   rd = inst_IF[15:11];
    wire [5:0]   opcode = inst_IF[31:26];
    wire [5:0]   funct = inst_IF[5:0];

    wire [4:0]   wr_regnum;
    wire [4:0]   wr_regnum_MW;  // new
    wire [2:0]   ALUOp;

    wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst;
    wire         PCSrc, zero;
    wire         ForwardA, ForwardB;
    wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;  
    wire         MemWrite_MW, MemRead_MW, MemToReg_MW, RegWrite_MW;

    // new wires     
    wire[31:0]   alu_new_a_out_data, rd2_forwardB_out; // new mux outputs
    wire[31:0]   alu_out_data_MW;    
    wire[31:0]   rd1_data_forward, rd2_data_MW;        
    wire [31:0]  inst_IF;
    wire [31:2]  PC_plus4_IF;
    wire stall;
    wire flush;

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, ~stall, reset);

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
    adder30 target_PC_adder(PC_target, PC_plus4_IF, imm[29:0]);
    mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
    assign PCSrc = BEQ & zero;

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory imem(inst, PC[31:2]);

    mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst,
                      opcode, funct);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum_MW, wr_data,
               RegWrite_MW, clk, reset);

    mux2v #(32) imm_mux(B_data, rd2_forwardB_out, imm, ALUSrc);
    alu32 alu(alu_out_data, zero, ALUOp, alu_new_a_out_data, B_data);

    // DO NOT comment out or rename this module
    // or the test bench will break
    data_mem data_memory(load_data, alu_out_data_MW, rd2_data_MW, MemRead_MW, MemWrite_MW, clk, reset);

    mux2v #(32) wb_mux(wr_data, alu_out_data_MW, load_data, MemToReg_MW);
    mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

    // new modules
    mux2v #(32) forwardAMux(alu_new_a_out_data, rd1_data, alu_out_data_MW, ForwardA);
    mux2v #(32) forwardBMux(rd2_forwardB_out, rd2_data, alu_out_data_MW, ForwardB);

    register #(1) RegWrite_reg(RegWrite_MW, RegWrite, clk, 1'b1, reset);
    register #(1) MemRead_reg(MemRead_MW, MemRead, clk, 1'b1, reset);
    register #(1) MemWrite_reg(MemWrite_MW, MemWrite, clk, 1'b1, reset);
    register #(1) MemToReg_reg(MemToReg_MW, MemToReg, clk, 1'b1, reset);
    
    register #(32, 32'd0) inst_reg(inst_IF, inst, clk, ~stall, flush);
    register #(30) new_PC_reg(PC_plus4_IF, PC_plus4, clk, ~stall, flush);
    register #(5) wr_regnum_reg(wr_regnum_MW, wr_regnum, clk, 1'b1, reset);
    register #(32, 32'd0) alu_mw_reg(alu_out_data_MW, alu_out_data, clk, 1'b1, reset);
    register #(32) rd2_data_reg(rd2_data_MW, rd2_forwardB_out, clk, 1'b1, reset);

    assign ForwardA = RegWrite_MW & (wr_regnum_MW == rs) & ~(wr_regnum_MW == 5'b0); 
    assign ForwardB = RegWrite_MW & (wr_regnum_MW == rt) & ~(wr_regnum_MW == 5'b0);
    assign stall = MemRead_MW & ((wr_regnum_MW == rs) | (wr_regnum_MW == rt)) & ~(wr_regnum_MW == 5'b0);
    assign flush = (PCSrc | reset);

endmodule // pipelined_machine