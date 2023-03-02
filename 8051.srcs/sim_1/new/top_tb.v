`timescale 1ns / 1ps

module top_tb;
	reg ex0_button;
    reg clock;
    reg reset_button;
    wire[7:0] p0;
    top test(clock,reset_button,ex0_button,

             tx,p0);
       
    initial
    begin
        ex0_button = 1'b0;
        reset_button = 1'b0;     
        clock = 1'b0;
    end
    
    always clock = #1 ~clock;
    
endmodule
