module machine(clk, reset);
   input        clk, reset;

   wire [31:0]  PC;
   wire [31:2]  next_PC, PC_plus4, PC_target;
   wire [31:0]  inst;

   wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
   wire [4:0]   rs = inst[25:21];
   wire [4:0]   rt = inst[20:16];
   wire [4:0]   rd = inst[15:11];

   wire [4:0]   wr_regnum;
   wire [2:0]   ALUOp;

   wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET;
   wire         PCSrc, zero, negative;
   wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

   //Your extra wires go here
   
   // cp0 wires
   wire [31:0]  cp0_rd_data;
   wire [29:0]  EPC;

   // timer wires
   wire [31:0] t_address, t_data;

   wire TimerAddress, TimerInterrupt, TakenInterrupt, NotIO;
   wire newMemRead, newMemWrite;
   wire [31:0]  wb_mux_out;
   wire [29:0] taken_interr_mux_out;
   wire [31:0] eret_mux_out;


   register #(30, 30'h100000) PC_reg(PC[31:2], taken_interr_mux_out, clk, /* enable */1'b1, reset);
   assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
   adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
   adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
   mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
   assign PCSrc = BEQ & zero;

   instruction_memory imem (inst, PC[31:2]);

   mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET,
                      inst);

   regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum, wr_data,
               RegWrite, clk, reset);

   mux2v #(32) imm_mux(B_data, rd2_data, imm, ALUSrc);
   alu32 alu(alu_out_data, zero, negative, ALUOp, rd1_data, B_data);

   data_mem data_memory(load_data, alu_out_data, rd2_data, newMemRead, newMemWrite, clk, reset);

   mux2v #(32) wb_mux(wb_mux_out, alu_out_data, load_data, MemToReg);
   mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);

   //Connect your new modules below
   mux2v mfco_mux(wr_data, wb_mux_out, cp0_rd_data, MFC0);
   mux2v eret_mux(eret_mux_out, next_PC, EPC, ERET);
   mux2v taken_interr_mux(taken_interr_mux_out, eret_mux_out, 30'h20000060, TakenInterrupt);

   cp0 cp01(cp0_rd_data, EPC, TakenInterrupt, rd, rd2_data, next_PC, TimerInterrupt, MTC0, ERET, clk, reset);
   timer timer1(TimerAddress, TimerInterrupt, load_data, t_address, t_data, MemRead, MemWrite, clk, reset);

   assign NotIO = (~TimerAddress);
   assign newMemRead = (MemRead & NotIO);
   assign newMemWrite = (MemWrite & NotIO);
   assign t_address = alu_out_data;
   assign t_data = rd2_data;

endmodule // machine