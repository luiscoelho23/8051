`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.11.2022 18:30:37
// Design Name: 
// Module Name: register_master_tristate
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


module register_master_tristate(load, reset, clock, dataIn, dataOut, wBus);
    
    parameter size = 1;
    
    input load,reset,clock;
    input [size-1:0]dataIn;
    output dataOut;
    reg[size-1:0]data;
    input wBus;
    
    always@(negedge clock,negedge reset)
	if(reset)
		data <= 0;
	else
		if(load)
			data <= dataIn;
        else
            data <= data;
            
assign dataOut = wBus ? data : 8'bzzzzzzzz;            
			
endmodule
