`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2022 09:40:16 AM
// Design Name: 
// Module Name: alu
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


module alu(
    input Clock,
    input Reset,
    input Opcode,
    input [7:0]DataBusIn,
    input [7:0]ACC,
    input TMP2MuxSel,
    
    output [7:0]PSW,
    output [7:0]DataBusOut
    );

assign TMP2MuxOut = TMP2MuxSel ? ACC : DataBusIn;   
    
register_master #(.size(8))TMP1 (.load(TMP1Load),.clear(Reset),.clock(Clock),.dataIn(DataBusIn),.dataOut(ALUIN1));
register_master #(.size(8))TMP2 (.load(TMP2Load),.clear(Reset),.clock(Clock),.dataIn(TMP2MuxOut),.dataOut(ALUIN2));    
    
endmodule
