`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2022 18:01:03
// Design Name: 
// Module Name: RamSim
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


module RomSim();
    
    reg Reset;
	reg Clock;
	reg [15:0]Address;
	wire[7:0]RomOut;
	
	initial
	begin
	   Clock   = 1'b0;
	   Reset   = 1'b0;
	   Address = 16'b0000000000000001;
	   
	   forever #2 Clock = ~Clock;
	end
	
    rom ROM(Reset, Clock, Address, RomOut);
    
    
endmodule
