`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2022 11:50:08
// Design Name: 
// Module Name: AluSim
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


module AluSim();
	
    reg Clock;
    reg Reset;
    
    reg [7:0]Opcode;
   
    wire [7:0]DataBus;
    wire[7:0]wPSW;
    
    reg[7:0]PSW;
    reg TMP1Load;
    reg TMP2Load;
    reg TMP2MuxSel;
    reg LoadBus = 0;
    reg ResultLoad;
    
    reg [7:0]Acc = 8'b1;
    alu test(Clock, Reset, Opcode, Acc, DataBus, ResultLoad, DataBus, PSW, TMP1Load, TMP2Load, TMP2MuxSel, LoadBus);
    
    
    initial
    begin
        Opcode = `RR;
        TMP2MuxSel = 1;
        Reset = 0;
        
        Clock = 0;
        
        Clock = ~Clock;
        #2
        TMP2Load = 1;
        
        Clock = ~Clock;
        #2
        
        
        Clock = ~Clock;
        #2
        TMP2Load = 0;
        
        Clock = ~Clock;
        #2
        
        Clock = ~Clock;
    end
    
endmodule
