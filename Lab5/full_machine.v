// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);

    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC, nextPC;
    wire [31:0] rsData, rtData, rdData, sign_out, zero_out, out, aluTopOut, aluBelowOut, jump;
    wire [31:0] rfMuxOut, addmMuxOut, sltOut, blOut, memRdOut, data_out, blInput, aluAddmOut; 
    wire [31:0] branch_offset;
    wire [31:0] memAddr;
    wire [7:0] dataMemMuxOut;
    wire [4:0] rdMuxOut;
    wire [2:0] alu_op;
    wire [1:0] alu_src2, control_type;
    wire writeenable, rd_src, lui, mem_read, byte_load, word_we, byte_we, slt, addm;
    wire overflow, zero, negative;
    
    // DO NOT comment out or rename this module
    // or the test bench will break!
    register #(32) PC_reg(PC, nextPC, clock, 1'b1, reset);

    alu32 topAlu(aluTopOut, , , , PC, 32'h4, `ALU_ADD);
    alu32 belowAlu(aluBelowOut, , , , aluTopOut, branch_offset, `ALU_ADD); 
    alu32 mainAlu(out, , zero, negative, addmMuxOut, rfMuxOut, alu_op[2:0]);

    mux4v #(32) controlTypeMux(nextPC, aluTopOut, aluBelowOut, jump, rsData, control_type); 
    mux4v #(8) dataMemMux(dataMemMuxOut, data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24], out[1:0]);

    mux3v #(32) rfMux(rfMuxOut, rtData, sign_out, zero_out, alu_src2[1:0]); // check last two params!

    mux2v #(32) sltMux(sltOut, out, {negative, 32'b0}, slt);
    mux2v #(32) byteLoadMux(blOut, data_out, blInput, byte_load); 
    mux2v #(32) memReadMux(memRdOut, sltOut, blOut, mem_read);
    mux2v #(5) rdMux(rdMuxOut, inst[15:11], inst[20:16], rd_src);
    mux2v #(32) luiMux(rdData, memRdOut, zero_out, lui);
    mux2v addmMux(addmMuxOut, rsData, data_out, addm);
    mux2v addmMux2(memAddr, out, rsData, addm);

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory im(inst, PC[31:2]);
    data_mem dm(data_out, memAddr, rtData, word_we, byte_we, clock, reset); // out is addr[31:0]

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf(rsData, rtData, inst[25:21], inst[20:16], rdMuxOut, rdData, writeenable, clock, reset);
    mips_decode md(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   inst[31:26], inst[5:0], zero);

    assign sign_out = {{16{inst[15]}}, inst[15:0]};
    assign zero_out = {{16{1'b0}}, inst[15:0]};
    assign branch_offset = {sign_out[29:0], 2'b0};

	assign jump[31:28] = PC[31:28];
	assign jump[27:2] = inst[25:0];
    assign jump[1:0] = 0;

    assign blInput = {dataMemMuxOut, 24'b0};

    
endmodule // full_machine
