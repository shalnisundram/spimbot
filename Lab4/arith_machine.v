// arith_machine: execute a series of arithmetic instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock  (input)  - the clock signal
// reset  (input)  - set to 1 to set all registers to zero, set to 0 for normal execution.

module arith_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;  
    wire [31:0] PC, nextPC, bigMuxOut; 
    wire [4:0] smallMuxOut;
    wire [31:0] rsData, rtData, sign_out, zero_out, out;
    wire [2:0] alu_op;
    wire [1:0] alu_src2;
    wire writeenable, rd_src;

    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(32) PC_reg(PC, nextPC, clock, 1'b1, reset);
    alu32 a1(nextPC, , , , PC, 32'h4, `ALU_ADD);
    alu32 a2(out, , , , rsData, bigMuxOut, alu_op);

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory im(inst, PC[31:2]);

    // DO NOT comment out or rename this module
    // or the test bench will break
    regfile rf(rsData, rtData, inst[25:21], inst[20:16], smallMuxOut, out, writeenable, clock, reset);
    mux2v #(5) m2(smallMuxOut, inst[15:11], inst[20:16], rd_src);
    mux3v #(32) m3(bigMuxOut, rtData, sign_out, zero_out, alu_src2);
    mips_decode d1(rd_src, writeenable, alu_src2, alu_op, except, inst[31:26], inst[5:0]); 
    assign zero_out = {16'b0, inst[15:0]};
    assign sign_out = {{16{inst[15]}}, inst[15:0]}; 

   //  zero_extend z1(zero_out, inst[15:0]);
   //  sign_extend s1(sign_out, inst[15:0]);
   
endmodule // arith_machine

//  module zero_extend(out, in);
//     output [31:0] out;
//     input [15:0] in;
//     assign out[31:0] = {16'b0, in[15:0]};
//  endmodule // zero_extend

//  module sign_extend(out, in);
//     output [31:0] out;
//     input [15:0] in;
//     assign out[31:2] = {{16{in[15]}}, in[15:0]}; 

//  endmodule // sign_extend

