`timescale 1ns / 1ps

`include "opcodes.v"

module alu_src_sel(clock,reset,alu_src_sel_en,opcode,a,operand1,ram_out

    ,alu_in1,alu_in2
    );
    
input clock,reset,alu_src_sel_en;
input[7:0] opcode,a,operand1,ram_out;

output reg[7:0] alu_in1, alu_in2;

initial
    begin
        alu_in1 = 8'b00000000;
        alu_in2 = 8'b00000000;
    end

always@(alu_src_sel_en)
begin
    case(opcode)
        //Shift Right
        `RR:
            begin
                alu_in1 = 8'b00000000;
                alu_in2 = a;
            end
        //Shift Left    
        `RL:
            begin
                alu_in1 = 8'b00000000;
                alu_in2 = a;
            end 
           
        //Increment
        `INCA:
            begin
                alu_in1 = 8'b00000000;
                alu_in2 = a;
            end
         
        `INCD ||`INCPR0 ||`INCPR1 ||`INCRX :
            begin
                //result = alu_in2 + 8'b00000001;
            end
                     
        //Shift Right with carry
        `RRC:
            begin
                alu_in1 = 8'b00000000;
                alu_in2 = a;
            end
        //Shift Left with carry
        `RLC:
            begin
                alu_in1 = 8'b00000000;
                alu_in2 = a;
            end
        //Decrement  
        `DECA:
            begin
                alu_in1 = 8'b00000000;
                alu_in2 = a;
            end   
        `DECD ||`DECPR0 ||`DECPR1 ||`DECRX:
            begin
                //result = alu_in2 - 8'b00000001;
            end
        
        //Addition           
        `ADDAI:  
            begin
                alu_in1 = a;
                alu_in2 = operand1;         
             end
        `ADDAD:
                begin
                alu_in1 = a;
                alu_in2 = ram_out;        
             end
        //`ADDAPR0:
        //`ADDAPR1:
        //`ADDARX:
         
        //Addition with carry    
        `ADDCAI || `ADDCAD || `ADDCAPR0 || `ADDCAPR1 || `ADDCARX:
             begin
                //{ac, result[3:0]} = alu_in1[3:0] + alu_in2[3:0] + psw_in[7];
                //{cy,result} = alu_in1 + alu_in2 + psw_in[7];
                //P = ~^result;
                //ov = alu_in1[7] ^ result[7];
             end                           
        //Or
        `ORLAI:
            begin
                alu_in1 = a;
                alu_in2 = operand1;
            end
        `ORLAD:
            begin
                alu_in1 = a;
                alu_in2 = ram_out;
            end
        
        `ORLAPR0 || `ORLAPR1 || `ORLARX:
            begin
                //result = alu_in1 | alu_in2;
                //P = ~^result;
            end
        //AND
        `ANLAI:
            begin
                alu_in1 = a;
                alu_in2 = operand1;
            end
        `ANLAD:
            begin
                alu_in1 = a;
                alu_in2 = ram_out;
            end
        `ANLAPR0 || `ANLAPR1 || `ANLARX:
            begin
                //result = alu_in1 & alu_in2;
                //P = ~^result;
            end      
        //XOR          
        `XRLDA || `XRLDI:
            begin
                //result = alu_in1 ^ alu_in2;
            end    
                
        
        `XRLAPR0 || `XRLAPR1 || `XRLARX:
            begin    
                //result = alu_in1 ^ alu_in2;
                //P = ~^result;
            end       
        //OR C, bit
        `ORLCB:
            begin
                //cy = psw_in[7] | alu_in1;
            end
        //And C, bit
        `ANLCB:
            begin
                //cy = psw_in[7] & alu_in1;
            end
        //Divide A, B
        `DIV:
            begin 
                //result = alu_in2 / alu_in1;
                //cy = 0;
                //ov = ~(alu_in1[7] | alu_in1[6] | alu_in1[5] | alu_in1[4] | alu_in1[3] | alu_in1[2] | alu_in1[1] | alu_in1[0]);
            end
        //Subtraction
        `SUBBAI: 
             begin
                alu_in1 = a;
                alu_in2 = operand1;           
             end
         //|| `SUBBAD || `SUBBAPR0 || `SUBBAPR1 || `SUBBARX:
            
        //OR C, !bit
        `ORLCB:
            begin
                //cy = psw_in[7] & ~alu_in1;
            end 
        //Increment DPTR
        `INCDPTR:
            begin
                //result = alu_in2 + 8'b00000001;
            end
        //Multiply A, B
        `MUL:
            begin
                //result = alu_in2 * alu_in1;
            end           
         //And C, !bit
        `ANLCB:
            begin
                //result = ~alu_in1[0];
            end
        //Complement bit
        `CPLB:
            begin
                //result = alu_in1[0];
            end
        //Complement carry
        `CPLC:
            begin
                //result = ~alu_in2;
            end
        //Clear bit
        `CLRB:
            begin
                //result = 0; 
            end  
        //Clear carry
        `CLRC:
            begin
                //cy = 0;
            end
        //Swap A nibbles
        `SWAPA:
            begin
                //result = {alu_in2[3], alu_in2[2], alu_in2[1], alu_in2[0], alu_in2[7], alu_in2[6], alu_in2[5], alu_in2[4]};
            end
        //Swap values
        `XCHAD || `XCHAPR0 || `XCHAPR1 || `XCHARX:
            begin
                //result = alu_in2;
            end
        //Set bit
        `SETBB:
            begin
                //result = 8'b00000001;
            end
        //Set bit carry
        `SETBC:
            begin
                //cy = 1;
            end     
          //Clear A
        `CLRA:
            begin
            end
        `CPLA:
            begin
                alu_in1 = 8'b00000000;
                alu_in2 = a;
            end   
    endcase 
end

endmodule
