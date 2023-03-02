`timescale 1ns / 1ps

module tb_alu_src_sel;


wire[7:0] alu_in1,alu_in2;

reg clock,reset,alu_src_sel_en;
reg [7:0] opcode,a;
    
alu_src_sel alu_src_sel_obj(clock,reset,alu_src_sel_en,opcode,a,alu_en,alu_in1,alu_in2);

initial
    begin
        a = 8'd5;
        opcode = 8'h04;
        reset = 1'b0;     
        clock = 1'b0;
        
        alu_src_sel_en = 1;
    end
    
    always clock = #5 ~clock;
        
endmodule
