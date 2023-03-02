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


module RamSim();
    
    reg Reset;
	reg Clock;
	reg WE;
	reg [7:0]Address;
	reg [7:0]DataIn;
	wire [7:0]RamOut;
	
	initial
	begin
	   Clock   = 1'b0;
	   WE      = 1'b0;
	   Reset   = 1'b0;
	   DataIn  = 8'b00000010;
	   Address = 8'b00000001;
	   
	   #2
	   Clock = 1;
	   
	   #2
	   Clock = 0;
	   
	   #2
	   Clock = 1;
	   
	   WE = 1;
	   
	   #2
	   Clock = 0;
	   
	   #2
	   Clock = 1;
	   
	   #2
	   Clock = 0;
	   
	   WE = 0;
	   
	   forever #2 Clock = ~Clock;
	end
	
    ram RAM(Reset, Clock, WE, Address, DataIn, RamOut);
    
    
endmodule
