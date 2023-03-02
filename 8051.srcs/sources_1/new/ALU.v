`timescale 1ns / 1ps

`include "opcodes.v"

module alu(alu_en,opcode,psw_out,psw_in,alu_in1,alu_in2,

           result,comp_flag
          );
     
    input wire[7:0] alu_in1, alu_in2;
    output reg[7:0] result;
    input alu_en;
    
    input [7:0]opcode;
    input [7:0]psw_in;
    output [7:0]psw_out;
    output comp_flag;
    
    reg cy;
    reg ac;
    reg ov;
    reg P ;
    
    initial
        begin
            result = 8'b00000000;
            cy = 0;
            ac = 0;
            ov = 0;
            P  = 0;
        end
    
    //Psw Temp Flags
    assign psw_out[7] = cy;
    assign psw_out[6] = ac;
    assign psw_out[5] = psw_in[5];
    assign psw_out[4] = psw_in[4];
    assign psw_out[3] = psw_in[3];
    assign psw_out[2] = ov;
    assign psw_out[1] = psw_in[1];
    assign psw_out[0] = P;

    assign comp_flag = (alu_in1 == alu_in2) ? 1 : 0;

    //Operations
    always@(posedge alu_en)
    begin
        //Shift Right
        if(opcode == `RR)
                    result = {alu_in2[0],alu_in2[7:1]};
        //Shift Left
        if(opcode == `RL)
                    result = {alu_in2[6:0],alu_in2[7]};
        //Increment   
        if(opcode == `INCA)
            begin
                    result = alu_in2 + 8'b00000001;
                    P = ~^result;
            end
         
        if( opcode == `INCD || opcode == `INCPR0 || opcode == `INCPR1 
                            || opcode == `INCR0 || opcode == `INCR1 || opcode == `INCR2
                            || opcode == `INCR3 || opcode == `INCR4 || opcode == `INCR5
                            || opcode == `INCR6 || opcode == `INCR7 )
                           
                    result = alu_in2 + 8'b00000001;
                     
        //Shift Right with carry
        if(opcode == `RRC)
            begin
                    result = {psw_in[7],alu_in2[7:1]};
                    cy = alu_in2[0]; 
            end
            
        //Shift Left with carry
        if(opcode == `RLC)
            begin
                    result = {alu_in2[6:0],psw_in[7]};
                    cy = alu_in2[0]; 
            end
        //Decrement    
        if(opcode == `DECA)
            begin
                    result = alu_in2 - 8'b00000001;
                    P = ~^result;
            end   
        if( opcode == `DECD || opcode == `DECPR0 || opcode == `DECPR1 
                            || opcode == `DECR0 || opcode == `DECR1 || opcode == `DECR2
                             || opcode == `DECR3 || opcode == `DECR4 || opcode == `DECR5
                             || opcode == `DECR6 || opcode == `DECR7)
                    result = alu_in2 - 8'b00000001;
        
        //Addition            
        if(opcode == `ADDAI || opcode == `ADDAD || opcode == `ADDAPR0 || opcode == `ADDAPR1 
                            || opcode == `ADDAR0 || opcode == `ADDAR1 || opcode == `ADDAR2 
                            || opcode == `ADDAR3 || opcode == `ADDAR4 || opcode == `ADDAR5
                            || opcode == `ADDAR6 || opcode == `ADDAR7 )
                begin
                    {ac, result[3:0]} = alu_in1[3:0] + alu_in2[3:0];
                    {cy,result} = alu_in1 + alu_in2;
                    P = ~^result;
                    ov = alu_in1[7] ^ result[7];         
                end
        //Addition with carry     
        if(opcode == `ADDCAI || opcode == `ADDCAD || opcode == `ADDCAPR0 || opcode == `ADDCAPR1 
                            || opcode == `ADDCAR0 )
                begin
                    {ac, result[3:0]} = alu_in1[3:0] + alu_in2[3:0] + psw_in[7];
                    {cy,result} = alu_in1 + alu_in2 + psw_in[7];
                    P = ~^result;
                    ov = alu_in1[7] ^ result[7];
                end                           
        //Or
        if(opcode == `ORLDA || opcode == `ORLDI)
                    result = alu_in1 | alu_in2;
        
        if(opcode == `ORLAD || opcode == `ORLAI)
                    result = alu_in1 | alu_in2;
        
        if(opcode == `ORLAPR0 || opcode == `ORLAPR1 || opcode == `ORLAR0)
                begin
                    result = alu_in1 | alu_in2;
                    P = ~^result;
                end
        //AND
        if(opcode == `ANLDA || opcode == `ANLDI)
                    result = alu_in1 & alu_in2;
                                        
        if(opcode == `ANLAD || opcode == `ANLAI || opcode == `ANLAR0 || opcode == `ANLAR1 || opcode == `ANLAR2
                                                || opcode == `ANLAR3 || opcode == `ANLAR4 || opcode == `ANLAR5
                                                || opcode == `ANLAR6 || opcode == `ANLAR7)
            begin
                result = alu_in1 & alu_in2;
            end
        
        if( opcode == `ANLAPR0 || opcode == `ANLAPR1 )
                begin
                    result = alu_in1 & alu_in2;
                    P = ~^result;
                end      
        //XOR            
        if(opcode == `XRLDA || opcode == `XRLDI)
                    result = alu_in1 ^ alu_in2;
        
        if(opcode == `XRLAPR0 || opcode == `XRLAPR1 
                            || opcode == `XRLAR0 ) 
                begin    
                    result = alu_in1 ^ alu_in2;
                    P = ~^result;
                end       
        
        
        //OR C, bit
        if(opcode == `ORLCB)
                    cy = psw_in[7] | alu_in1;
        //And C, bit
        if(opcode == `ANLCB)
                    cy = psw_in[7] & alu_in1;
        //Divide A, B
        if(opcode == `DIV)
                begin 
                    result = alu_in2 / alu_in1;
                    cy = 0;
                    ov = ~(alu_in1[7] | alu_in1[6] | alu_in1[5] | alu_in1[4] | alu_in1[3] | alu_in1[2] | alu_in1[1] | alu_in1[0]);
                end
        //Subtraction
        if(opcode == `SUBBAI || opcode == `SUBBAD || opcode == `SUBBAPR0 || opcode == `SUBBAPR1 
                            || opcode == `SUBBAR0 )
                 begin
                    {ac, result[3:0]} = alu_in1[3:0] - alu_in2[3:0];
                    {cy,result} = (alu_in1 + ~alu_in2) + 1'b1;
                    P = ~^result;
                    ov = alu_in1[7] ^ result[7];         
                end
        //OR C, !bit
        if(opcode == `ORLCB)
                    cy = psw_in[7] & ~alu_in1; 
        //Increment DPTR
        if(opcode == `INCDPTR)
                    result = alu_in2 + 8'b00000001;
        //Multiply A, B
        if(opcode == `MUL)
                    result = alu_in2 * alu_in1;           
         //And C, !bit
        if(opcode == `ANLCB)
                    result = ~alu_in1[0];
        //Complement bit
        if(opcode == `CPLA)
                    result = ~alu_in2;      
        //Complement carry       
        if(opcode == `CPLC)
                    cy = ~cy;
        //Clear bit
        if(opcode == `CLRA)
                    result = 0;   
        //Clear carry
        if(opcode == `CLRC)
                    cy = 0;
        //Swap A nibbles
        if(opcode == `SWAPA)
                    result = {alu_in2[3], alu_in2[2], alu_in2[1], alu_in2[0], alu_in2[7], alu_in2[6], alu_in2[5], alu_in2[4]};
        //Swap values
        if(opcode == `XCHAD || opcode == `XCHAPR0 || opcode == `XCHAPR1 || opcode == `XCHAR0)
                    result = alu_in2;
         //Set bit
         if(opcode == `SETBB)
                    result = 8'b00000001;
         //Set bit carry
         if(opcode == `SETBC)
                    cy = 1;             
    end 
    
endmodule