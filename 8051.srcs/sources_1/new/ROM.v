`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2022 18:50:45
// Design Name: 
// Module Name: rom
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

//Bus Width
`define ROMADDRBUS 16
`define ROMBUS     8

`define ROMWIDE    8
`define ROMHEIGHT  4096

module rom(
	input [`ROMADDRBUS - 1 : 0]Address,
	
	output [`ROMBUS - 1 : 0 ]RomOut
	);
	
	//ROM Declaration
	reg [`ROMWIDE - 1 :0] ROM [`ROMHEIGHT - 1 :0];
	
	//ROM Initialization
    integer index;
    initial
    begin
     
        for (index = 0;index < `ROMHEIGHT; index = index + 1)
            ROM[index] = 0;    
               
        $readmemh("ROM.mem", ROM);
    end 
    
    assign RomOut = ROM[Address];
endmodule 
