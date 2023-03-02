`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2022 02:59:40
// Design Name: 
// Module Name: SFR
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

//SFR Addresses
`define P0   8'H80
`define SP   8'H81
`define DPL  8'H82
`define DPH  8'H83
`define PCON 8'H87
`define TCON 8'H88
`define TMOD 8'H89
`define P1   8'H90
`define TL0  8'H8A
`define TH0  8'H8C
`define AUXR 8'H8E
`define P2   8'HA0
`define IE   8'HA8
`define P3   8'HB0
`define IPH  8'HB7
`define IP   8'HB8
`define PSW  8'HD0
`define ACC  8'HE0
`define B    8'HF0

//Bus Width
`define SFRADDRBUS   8
`define SFRBUS    8

`define SFRWIDE   8
`define SFRHEIGHT 128

module sfr(
    input Clock,
	input Reset,
	input WE,
	input [`SFRADDRBUS - 1 : 0]Address,
	input [`SFRADDRBUS - 1 : 0 ]DataIn,
	output [`SFRBUS - 1 : 0 ]SfrOut,
	);
	
	//SFR memory Declaration
	reg [`SFRWIDE - 1 :0] SFR [`SFRHEIGHT - 1 :0];
    
    initial
    begin
   
    SFR[`P0]   = 8'B11111111;
    SFR[`SP]   = 8'B00000111;
    SFR[`DPL]  = 8'B11111111;
    SFR[`DPH]  = 8'B00000000;
    SFR[`PCON] = 8'B00x00000;
    SFR[`TCON] = 8'B00000000;
    SFR[`TMOD] = 8'Bxxxx1111;
    SFR[`TL0]  = 8'B00000000;
    SFR[`TH0]  = 8'B00000000;
    SFR[`AUXR] = 8'Bxxxxxxx0;   
    SFR[`P2]   = 8'B11111111;
    SFR[`IE]   = 8'B0xxx0000;
    SFR[`P3]   = 8'B11111111;
    SFR[`IPH]  = 8'Bxxxx0000;
    SFR[`IP]   = 8'Bxxxx0000;
    SFR[`PSW]  = 8'B00000000;
    SFR[`ACC]  = 8'B00000000;
    SFR[`B]    = 8'B00000000;
    
    end

    //RAM Input
    always@(posedge Clock)
    begin
        if(Reset)
        begin
            SFR[`P0]   = 8'B11111111;
            SFR[`SP]   = 8'B00000111;
            SFR[`DPL]  = 8'B11111111;
            SFR[`DPH]  = 8'B00000000;
            SFR[`PCON] = 8'B00x00000;
            SFR[`TCON] = 8'B00000000;
            SFR[`TMOD] = 8'Bxxxx1111;
            SFR[`TL0]  = 8'B00000000;
            SFR[`TH0]  = 8'B00000000;
            SFR[`AUXR] = 8'Bxxxxxxx0;   
            SFR[`P2]   = 8'B11111111;
            SFR[`IE]   = 8'B0xxx0000;
            SFR[`P3]   = 8'B11111111;
            SFR[`IPH]  = 8'Bxxxx0000;
            SFR[`IP]   = 8'Bxxxx0000;
            SFR[`PSW]  = 8'B00000000;
            SFR[`ACC]  = 8'B00000000;
            SFR[`B]    = 8'B00000000;
        end
        
        if(WE)
            SFR[Address] <= DataIn;
    end
    
endmodule 
