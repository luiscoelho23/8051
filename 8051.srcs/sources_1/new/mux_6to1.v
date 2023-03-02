`timescale 1ns / 1ps

module mux_6to1(src_1, src_2, src_3,src_4,src_5,src_6,src_sel,
  
                mux_out  
    );
    
input[7:0] src_1, src_2, src_3, src_4,src_5,src_6;
input[2:0] src_sel;
  
output wire[7:0] mux_out;    
    
assign mux_out = src_sel[2] ? (src_sel[0] ? src_1 : src_2) : (src_sel[1] ? (src_sel[0] ? src_3 : src_4) : (src_sel[0] ? src_5 : src_6));   
 
endmodule
