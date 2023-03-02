`timescale 1ns / 1ps

`include "opcodes.v"

`define s_fetch1   3'b000
`define s_wait     3'b001
`define s_fetch2   3'b010
`define s_decode   3'b011
`define s_fetch3   3'b100
`define s_execute1 3'b101
`define s_execute2 3'b110
`define s_load     3'b111

`define alu_a        3'b000
`define alu_operand1 3'b001
`define alu_ram_out  3'b010
`define alu_clear    3'b011
`define alu_operand2 3'b100

`define ram_r0       3'b000
`define ram_r1       3'b001
`define ram_r2       3'b010
`define ram_r3       3'b011
`define ram_r4       3'b100
`define ram_r5       3'b101
`define ram_r6       3'b110
`define ram_r7       3'b111

`define a_result     2'b00
`define a_operand1   2'b01
`define a_ram_out    2'b10

`define i_null       3'b000
`define i_t0         3'b001
`define i_t1         3'b010
`define i_ex0        3'b011
`define i_rt         3'b100
 

module controlunit(clock,reset,psw_in,opcode,tf0,tf1,ie,comp_flag,a_direct,psw_direct,ex0,rxtx,
                    
                    pc_load,pc_load_ret,pc_inc,pc_save,sp_inc,sp_dec,
                    psw_load,sp_load,ram_we,a_load,en_stack_out,
                    ir1_load,ir2_load,ir3_load,alu_in1_src_sel,alu_in2_src_sel,alu_en,ljmp_load,
                    ajmp_load,retjmp_load,it_jmp_load,rjmp_load,a_src_sel,ram_src_sel,stack_src_sel,
                    ram_addr_src_sel,rx_src
                    );
                    
input clock,reset,tf0,tf1,comp_flag,a_direct,psw_direct,ex0,rxtx;
input [7:0] psw_in,opcode,ie;

output reg[1:0] a_src_sel,ram_addr_src_sel;
output reg[2:0] stack_src_sel,ram_src_sel,rx_src,alu_in1_src_sel,alu_in2_src_sel,it_jmp_load;

output reg pc_load,pc_load_ret,pc_inc,sp_inc,sp_dec,
           psw_load,sp_load,ram_we,a_load,en_stack_out,
           ir1_load,ir2_load,ir3_load,alu_en,ljmp_load,ajmp_load,retjmp_load,rjmp_load,pc_save
           ;

wire ea,et0,et1,ext0;
reg it0,it1,xit0,irt,it_reset,it_jmp;
 
reg[2:0] state;
reg[2:0] next_state;  

always@(negedge clock)
begin
    if(!reset)
        begin
            if(rxtx)
                begin
                    irt = 1;
                end
            if(ex0)
                begin
                    xit0 = 1;
                end
            if(tf1)
                begin
                    it1 = 1;
                end
            if(tf0)
                begin
                    it0 = 1;
                end          
        else
            begin
                if(it_reset)
                    begin
                        irt = 0;
                        xit0 = 0;
                        it0 = 0;
                        it1 = 0;
                    end
            end
        end
    else
        begin
            irt = 0;
            it1 = 0;
            it0 = 0;
            xit0 = 0;
        end
end

always@(negedge clock)
begin
if(!reset)
    begin
            case(state)
                `s_fetch1:
                    begin                       
                        if(ea && (et0 || et1 || ext0) && (it0 || it1|| xit0))
                            begin
                                it_jmp = 1;                                
                                pc_save = 1;
                            end
                        else
                            begin
                                it_jmp = 0;
                                pc_save = 0;
                            end
                             
                        a_load = 0;
                        psw_load = 0;
                        ram_we = 0;
                        
                        sp_inc = 0;
                        sp_load = 0;
                        sp_dec = 0;
                        pc_inc = 0;
                        pc_load = 0;
                        
                        it_jmp_load = `i_null;
                        
                        ljmp_load = 0;
                        ajmp_load = 0;
                        rjmp_load = 0;
                        retjmp_load = 0;
                        en_stack_out = 0;
                        
                        rx_src = 3'b000;
                        ram_addr_src_sel = 2'b11;
                        ram_src_sel = 3'b000;
                        
                        stack_src_sel = 3'b000;
                        
                        alu_in1_src_sel = 2'b11;
                        alu_in2_src_sel = 2'b11;
                        alu_en = 0;
            
                        it_reset = 0;
                        ir1_load = 1;      
                        next_state = `s_wait;
                    end
                `s_wait:
                    begin
                        pc_inc = 1;
                        ir1_load = 0;
                        next_state = `s_fetch2;
                    end
                `s_fetch2:
                    begin
                        pc_inc = 0;
                        ir2_load = 1;
                        next_state = `s_decode; 
                    end
                `s_decode:
                    begin
                        ir2_load = 0;
                        pc_inc = 1;
                        next_state = `s_fetch3; 
                        if(it_jmp)
                            begin
                                pc_save = 0;
                                stack_src_sel = 3'b010;
                            end
                        else
                        case(opcode)
                            `RR:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = `a_result;
                                end
                            `INCA:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = `a_result;
                                end
                            `INCR0:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = `ram_r0;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `INCR1:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b001;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `INCR2:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b010;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `INCR3:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b011;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `INCR4:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b100;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `INCR5:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b101;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `INCR6:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b110;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `INCR7:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b111;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end                           
                            `LCALL:
                                begin
                                    stack_src_sel = 3'b000;
                                end
                            `RRC:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `DECA:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `DECR0:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b000;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `DECR1:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b001;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `DECR2:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b010;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `DECR3:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b011;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `DECR4:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b100;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `DECR5:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b101;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `DECR6:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b110;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `DECR7:
                                begin
                                   alu_in1_src_sel = `alu_clear;
                                   alu_in2_src_sel = `alu_ram_out;
                                   rx_src = 3'b111;
                                   ram_addr_src_sel = 2'b00;
                                   ram_src_sel = 3'b001;
                                end
                            `RL:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAI:
                                begin
                                    alu_in1_src_sel = `alu_operand1;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAD:
                                begin
                                    ram_addr_src_sel = 2'b01;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;                                    
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR0:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b000;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR1:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b001;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR2:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b010;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR3:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b011;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR4:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b100;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR5:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b101;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR6:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b110;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ADDAR7:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b111;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end 
                            `RLC:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ORLDI:
                                begin
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                    ram_addr_src_sel = 2'b01;
                                    ram_src_sel = 3'b001;     
                                end 
                            `ORLAI:
                                begin
                                    alu_in1_src_sel = `alu_operand1;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end    
                            `ORLAD:
                                begin
                                    ram_addr_src_sel = 2'b01;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;                           
                                end
                            `ANLDI:
                                begin
                                   alu_in1_src_sel = `alu_ram_out;
                                   alu_in2_src_sel = `alu_operand1;
                                   ram_addr_src_sel = 2'b01;
                                   ram_src_sel = 3'b001; 
                                end
                            `ANLAI:
                                begin
                                    alu_in1_src_sel = `alu_operand1;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAD:
                                begin
                                    ram_addr_src_sel = 2'b01;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR0:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b00;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR1:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b001;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR2:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b010;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR3:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b011;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR4:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b100;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR5:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b101;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR6:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b110;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            `ANLAR7:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b111;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end 
                            `JZ:
                                begin
                                    alu_in2_src_sel = `alu_a;
                                    alu_in1_src_sel = `alu_clear;
                                end
                            `XRLDI:
                                begin
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand2;
                                    ram_addr_src_sel = 2'b01;
                                    ram_src_sel = 3'b001;   
                                end 
                            `JNZ:
                                begin
                                    alu_in2_src_sel = `alu_a;
                                    alu_in1_src_sel = `alu_clear;
                                end
                            `MOVDI:
                                begin
                                    ram_addr_src_sel = 2'b01;
                                    ram_src_sel = 3'b000;
                                end
                            `SUBBAI:
                                begin
                                    alu_in1_src_sel = `alu_a;
                                    alu_in2_src_sel = `alu_operand1;
                                    a_src_sel = 2'b00;
                                end
                            `SUBBAD:
                                begin
                                    ram_addr_src_sel = 2'b01;
                                    alu_in1_src_sel = `alu_a;
                                    alu_in2_src_sel = `alu_ram_out;
                                    a_src_sel = 2'b00;
                                end
                            `CJNEAIO:
                                begin
                                    alu_in1_src_sel = `alu_a;
                                    alu_in2_src_sel = `alu_operand1;    
                                end
                            `CJNER0IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b000;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end  
                            `CJNER1IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b001;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end 
                            `CJNER2IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b010;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end 
                            `CJNER3IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b011;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end 
                            `CJNER4IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b100;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end 
                            `CJNER5IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b101;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end
                            `CJNER6IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b110;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end
                            `CJNER7IO:
                                begin
                                    ram_addr_src_sel = 2'b00;
                                    rx_src = 3'b111;
                                    alu_in1_src_sel = `alu_ram_out;
                                    alu_in2_src_sel = `alu_operand1;
                                end           
                            `CLRA:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end 
                            `CPLA:
                                begin
                                    alu_in1_src_sel = `alu_clear;
                                    alu_in2_src_sel = `alu_a;
                                    a_src_sel = 2'b00;
                                end
                            default:
                                begin
                                end      
                        endcase                                              
                    end
                 `s_fetch3:
                    begin
                        pc_inc = 0;
                        ir3_load = 1;              
                        next_state = `s_execute1;
                        if(it_jmp)
                            begin
                                sp_load = 1;
                            end
                        else
                        case(opcode)
                            `LCALL:
                                begin 
                                    sp_load = 1;
                                end
                            `RET:
                                begin
                                    sp_dec = 1;
                                end 
                            default:
                                begin
                                end 
                        endcase 
                    end
                 `s_execute1:
                    begin       
                        pc_inc = 1;      
                        ir3_load = 0;               
                        next_state = `s_execute2;
                        if(it_jmp)
                            begin
                                stack_src_sel = 3'b011;                                  
                                sp_inc = 1;
                                sp_load = 0;
                                if(it0)
                                    it_jmp_load = `i_t0;
                                if(it1)
                                    it_jmp_load = `i_t1;
                                if(xit0)
                                    it_jmp_load = `i_ex0;
                                if(irt)
                                    it_jmp_load = `i_rt;
                            end
                        else
                        case(opcode)
                            `NOP:
                                begin
                                end                      
                            `AJMP0:
                                begin
                                    ajmp_load = 1;                                
                                end
                            `LJMP:
                                begin
                                    ljmp_load = 1;                                       
                                end
                            `RR:
                                begin
                                    alu_en = 1;
                                end
                            `INCA:
                                begin                               
                                    alu_en = 1;
                                end
    //                            `INCD:
    //                            `INCPR0:
    //                            `INCPR1:
                            `INCR0:
                                begin
                                    alu_en = 1;
                                end
                            `INCR1:
                                begin
                                    alu_en = 1;
                                end
                            `INCR2:
                                begin
                                    alu_en = 1;
                                end
                            `INCR3:
                                begin
                                    alu_en = 1;
                                end
                            `INCR4:
                                begin
                                    alu_en = 1;
                                end
                            `INCR5:
                                begin
                                    alu_en = 1;
                                end
                            `INCR6:
                                begin
                                    alu_en = 1;
                                end
                            `INCR7:
                                begin
                                    alu_en = 1;
                                end
    //                            `JBC:
    //                            `ACALL0:
                            `LCALL:
                                begin
                                    stack_src_sel = 3'b001;                                  
                                    sp_inc = 1;
                                    sp_load = 0;
                                    ljmp_load = 1;                 
                                end
                            `RRC:
                                begin
                                    alu_en = 1;
                                end                           
                            `DECA:
                                begin
                                    alu_en = 1;
                                end
    //                            `DECD:
    //                            `DECPR0:    
    //                            `DECPR1:    
                            `DECR0:
                                begin
                                    alu_en = 1;
                                end
                            `DECR1:
                                begin
                                    alu_en = 1;
                                end
                            `DECR2:
                                begin
                                    alu_en = 1;
                                end
                            `DECR3:
                                begin
                                    alu_en = 1;
                                end
                            `DECR4:
                                begin
                                    alu_en = 1;
                                end
                            `DECR5:
                                begin
                                    alu_en = 1;
                                end
                            `DECR6:
                                begin
                                    alu_en = 1;
                                end
                            `DECR7:
                                begin
                                    alu_en = 1;
                                end    
    //                            `JB:        
                            `AJMP1:
                                begin
                                    ajmp_load = 1;
                                end     
                            `RET:
                                begin
                                    retjmp_load = 1;
                                    sp_dec = 0;
                                    en_stack_out = 1;
                                    pc_load_ret = 1;
                                end       
                            `RL:
                                begin
                                    alu_en = 1;
                                end        
                            `ADDAI:
                                begin
                                    alu_en = 1;
                                end                                 
                            `ADDAD:
                                begin
                                    alu_en = 1;
                                end     
    //                            `ADDAPR0:   
    //                            `ADDAPR1:   
                            `ADDAR0:
                                begin
                                    alu_en = 1;
                                end
                            `ADDAR1:
                                begin
                                    alu_en = 1;
                                end
                            `ADDAR2:
                                begin
                                    alu_en = 1;
                                end 
                            `ADDAR3:
                                begin
                                    alu_en = 1;
                                end 
                            `ADDAR4:
                                begin
                                    alu_en = 1;
                                end 
                            `ADDAR5:
                                begin
                                    alu_en = 1;
                                end
                            `ADDAR6:
                                begin
                                    alu_en = 1;
                                end
                            `ADDAR7:
                                begin
                                    alu_en = 1;
                                end      
    //                            `JNB:       
    //                            `ACALL1:    
    //                            `RETI:      
                            `RLC:
                                begin
                                    alu_en = 1;
                                end        
    //                            `ADDCAI:    
    //                            `ADDCAD:    
    //                            `ADDCAPR0:  
    //                            `ADDCAPR1:  
    //                            `ADDCARX:   
    //                            `JC:        
                            `AJMP2:
                                begin
                                    ajmp_load = 1;
                                end     
    //                            `ORLDA:     
                            `ORLDI:
                                begin
                                    alu_en = 1;
                                end     
                            `ORLAI:
                                begin
                                    alu_en = 1;
                                end     
                            `ORLAD:
                                begin
                                    alu_en = 1;
                                end     
    //                            `ORLAPR0:   
    //                            `ORLAPR1:   
    //                            `ORLARX:    
    //                            `JNC:       
    //                            `ACALL2:    
    //                            `ANLDA:     
                            `ANLDI:
                                begin
                                    alu_en = 1;
                                end     
                            `ANLAI:
                                begin
                                    alu_en = 1;
                                end      
                            `ANLAD:
                                begin
                                    alu_en = 1;
                                end      
    //                            `ANLAPR0:   
    //                            `ANLAPR1:   
                            `ANLAR0:
                                begin
                                    alu_en = 1;
                                end
                            `ANLAR1:
                                begin
                                    alu_en = 1;
                                end
                            `ANLAR2:
                                begin
                                    alu_en = 1;
                                end
                            `ANLAR3:
                                begin
                                    alu_en = 1;
                                end
                            `ANLAR4:
                                begin
                                    alu_en = 1;
                                end
                            `ANLAR5:
                                begin
                                    alu_en = 1;
                                end
                            `ANLAR6:
                                begin
                                    alu_en = 1;
                                end
                            `ANLAR7:
                                begin
                                    alu_en = 1;
                                end   
                            `JZ:
                                begin
                                    if(comp_flag == 1)
                                        begin
                                            rjmp_load = 1;
                                        end
                                end     
                            `AJMP3:
                                begin
                                    ajmp_load = 1;
                                end                                                                 
    //                            `XRLDA:                                     
                            `XRLDI:
                                begin
                                    alu_en = 1;
                                end                                     
    //                            `XRLAI:                                     
    //                            `XRLAD:                                     
    //                            `XRLAPR0:                                  
    //                            `XRLAPR1:                                  
    //                            `XRLARX:                                   
                            `JNZ:
                                begin
                                    if(!comp_flag)
                                        begin
                                            rjmp_load = 1;
                                        end
                                end                                       
    //                            `ACALL3:                                    
    //                            `ORLCB:                                    
    //                            `JMPADPTR:                                  
                            `MOVAI:
                                begin
                                    a_src_sel = 2'b01;                                 
                                end                                                               
                            `MOVDI:
                                begin
                                    ram_we = 1;
                                end                                    
    //                            `MOVPR0I:                                  
    //                            `MOVPR1I:                                   
                            `MOVR0I:
                                begin
                                    rx_src = 3'b000;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end
                            `MOVR1I:
                                begin
                                    rx_src = 3'b001;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end
                            `MOVR2I:
                                begin
                                    rx_src = 3'b010;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end
                            `MOVR3I:
                                begin
                                    rx_src = 3'b011;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end
                            `MOVR4I:
                                begin
                                    rx_src = 3'b100;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end
                            `MOVR5I:
                                begin
                                    rx_src = 3'b101;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end
                            `MOVR6I:
                                begin
                                    rx_src = 3'b110;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end
                            `MOVR7I:
                                begin
                                    rx_src = 3'b111;
                                    ram_addr_src_sel = 2'b00;
                                    ram_src_sel = 3'b100; 
                                end                                          
    //                            `SJMP:                                    
                            `AJMP4:
                                begin
                                    ajmp_load = 1;
                                end                                   
    //                            `ANLCB:                                    
    //                            `MOVCAPC:                                  
    //                            `DIV:                                      
    //                            `MOVDD:                               
    //                            `MOVDPR0:                                 
    //                            `MOVDPR1:                                  
    //                            `MOVDRX:                                   
    //                            `MOVDPTRI:                                 
    //                            `ACALL4:                                  
    //                            `MOVBC:                                   
    //                            `MOVCADPTR:                               
                            `SUBBAI:
                                begin
                                    alu_en = 1;
                                end                                   
                            `SUBBAD:
                                begin
                                    alu_en = 1;
                                end                                  
    //                            `SUBBAPR0:                                
    //                            `SUBBAPR1:                                
    //                            `SUBBARX:                                   
    //                            `ORLCNB:                                  
                            `AJMP5:
                                begin
                                    ajmp_load = 1;
                                end                                   
    //                            `MOVCB:                                   
    //                            `INCDPTR:                                 
    //                            `MUL:                                     
    //                            `RESERVED:                               
    //                            `MOVPR0D:                               
    //                            `MOVPR1D:                                  
    //                            `MOVRXD:                                      
    //                            `ANLCNB:                                  
    //                            `ACALL5:                                  
    //                            `CPLB:                                    
    //                            `CPLC:                                   
                            `CJNEAIO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end                                     
    //                            `CJNEADO:                                      
    //                            `CJNEPR0IO:                                     
    //                            `CJNEPR1IO:                                     
                            `CJNER0IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end
                            `CJNER1IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end
                            `CJNER2IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end
                            `CJNER3IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end
                            `CJNER4IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end
                            `CJNER5IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end
                            `CJNER6IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end
                            `CJNER7IO:
                                begin
                                    if(!comp_flag)
                                        rjmp_load = 1;    
                                end                                     
    //                            `PUSHD:                                         
                            `AJMP6:
                                begin
                                    ajmp_load = 1;
                                end                                        
    //                            `CLRB:                                          
    //                            `CLRC:                                          
    //                            `SWAPA:
    //                            `XCHAD:                                        
    //                            `XCHAPR0:                                      
    //                            `XCHAPR1:                                      
    //                            `XCHARX:                                   
    //                            `POPD:                                     
    //                            `ACALL6:                                      
    //                            `SETBB:                                         
    //                            `SETBC:                                         
    //                            `DAA:                                           
    //                            `DJNZDO:                                        
    //                            `XCHDAPR0:                                     
    //                            `XCHDAPR1:                                      
    //                            `DJNZRXO:                                    
    //                            `MOVXADPTR:                                    
                            `AJMP7:
                                begin
                                    ajmp_load = 1;
                                end                                   
    //                            `MOVXAPR0:                                   
    //                            `MOVXAPR1:                                   
                            `CLRA:
                                begin
                                    alu_en = 1;
                                end                                   
                            `MOVAD:
                                begin
                                    ram_addr_src_sel = 2'b01;
                                    a_src_sel = 2'b10;
                                end                                   
    //                            `MOVAPR0:                                   
    //                            `MOVAPR1:                                   
    //                            `MOVARX:                                   
    //                            `MOVXDPTRA:                                   
    //                            `ACALL7:                                   
    //                            `MOVXPR0:                                  
    //                            `MOVXPR1:                                  
                            `CPLA:
                                begin
                                    alu_en = 1;
                                end                                 
    //                            `MOVDA:                                        
    //                            `MOVPR0A:                                  
    //                            `MOVPR1A:                                  
    //                            `MOVRXA:
                                                                           
                                default:
                                    begin
                                        next_state = `s_fetch1;
                                    end
                        endcase                       
                    end                 
                 `s_execute2:
                    begin
                       pc_inc = 0;
                       next_state = `s_load;
                       if(it_jmp)
                            begin
                                sp_load = 1;
                                sp_inc = 0;
                            end
                        else
                       case(opcode)
                            `LCALL:
                                begin
                                    sp_load = 1;
                                    sp_inc = 0;
                                end
                            `RET:
                                begin
                                    en_stack_out = 0;
                                    sp_dec = 1;
                                end 
                            default:
                               begin
                               end        
                        endcase
                    end
                 `s_load:
                    begin
                        pc_inc = 0;
                        next_state = `s_fetch1;
                        if(it_jmp)
                            begin
                                sp_inc = 1;
                                pc_load = 1;
                                it_reset = 1;
                            end
                        else
                        case(opcode)                           
                            `AJMP0:
                                begin
                                    pc_load = 1;
                                end
                            `LJMP:
                                begin
                                    pc_load = 1;
                                end
                            `RR:
                                begin                                  
                                    a_load = 1;
                                end
                            `INCA:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `INCR0:
                                begin
                                    ram_we = 1;
                                end
                            `INCR1:
                                begin
                                    ram_we = 1;
                                end
                            `INCR2:
                                begin
                                    ram_we = 1;
                                end
                            `INCR3:
                                begin
                                    ram_we = 1;
                                end
                            `INCR4:
                                begin
                                    ram_we = 1;
                                end
                            `INCR5:
                                begin
                                    ram_we = 1;
                                end
                            `INCR6:
                                begin
                                    ram_we = 1;
                                end
                            `INCR7:
                                begin
                                    ram_we = 1;
                                end                        
                            `LCALL:
                                begin
                                    sp_inc = 1;
                                    pc_load = 1;
                                end
                            `RRC:
                                begin
                                    a_load = 1;
                                end 
                            `DECA:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `DECR0:
                                begin
                                    ram_we = 1;
                                end
                            `DECR1:
                                begin
                                    ram_we = 1;
                                end
                            `DECR2:
                                begin
                                    ram_we = 1;
                                end
                            `DECR3:
                                begin
                                    ram_we = 1;
                                end
                            `DECR4:
                                begin
                                    ram_we = 1;
                                end
                            `DECR5:
                                begin
                                    ram_we = 1;
                                end
                            `DECR6:
                                begin
                                    ram_we = 1;
                                end
                            `DECR7:
                                begin
                                    ram_we = 1;
                                end                        
                            `AJMP1:
                                begin
                                    pc_load = 1;
                                    ajmp_load = 1;
                                end
                            `RET:
                                begin
                                    en_stack_out = 1;
                                    pc_load = 1;
                                    pc_load_ret = 0;
                                end 
                            `RL:
                                begin
                                    a_load = 1;
                                end
                            `ADDAI:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAD:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR0:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR1:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR2:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR3:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR4:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR5:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR6:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `ADDAR7:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end                  
                            `RLC:
                                begin
                                    a_load = 1;
                                end
                            `AJMP2:
                                begin
                                    pc_load = 1;
                                    ajmp_load = 1;
                                end
                            `ORLDI:
                                begin
                                    ram_we = 1;     
                                end
                            `ORLAI:
                                begin
                                    a_load = 1;
                                end     
                            `ORLAD:
                                begin
                                    a_load = 1;
                                end
                            `ANLDI:
                                begin
                                   ram_we = 1;
                                end
                            `ANLAI:
                                begin
                                    a_load = 1;
                                end      
                            `ANLAD:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR0:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR1:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR2:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR3:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR4:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR5:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR6:
                                begin
                                    a_load = 1;
                                end
                            `ANLAR7:
                                begin
                                    a_load = 1;
                                end
                            `JZ:
                                begin
                                    if(comp_flag)
                                        begin
                                            pc_load = 1;
                                        end
                                end       
                            `AJMP3:
                                begin
                                    pc_load = 1;
                                end
                            `XRLDI:
                                begin
                                    ram_we = 1;
                                end
                            `JNZ:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end
                                end                          
                            `MOVAI:
                                begin
                                    a_load = 1;                                                                  
                                end
                            `MOVDI:
                                begin
                                    if(a_direct)
                                        begin
                                            a_load = 1;
                                        end
                                    
                                    if(psw_direct)
                                        begin
                                            psw_load = 1;
                                        end
                                end
                            `MOVR0I:
                                begin
                                    ram_we = 1; 
                                end
                            `MOVR1I:
                                begin
                                    ram_we = 1; 
                                end
                            `MOVR2I:
                                begin
                                    ram_we = 1; 
                                end
                            `MOVR3I:
                                begin
                                    ram_we = 1; 
                                end
                            `MOVR4I:
                                begin
                                    ram_we = 1; 
                                end
                            `MOVR5I:
                                begin
                                    ram_we = 1; 
                                end
                            `MOVR6I:
                                begin
                                    ram_we = 1; 
                                end
                            `MOVR7I:
                                begin
                                    ram_we = 1; 
                                end  
                            `AJMP4:
                                begin
                                    pc_load = 1;
                                end
                            `SUBBAI:
                                begin
                                    a_load = 1;
                                    psw_load = 1;
                                end
                            `AJMP5:
                                begin
                                    pc_load = 1;
                                end
                            `CJNEAIO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end       
                                end
                            `CJNER0IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end
                            `CJNER1IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end
                            `CJNER2IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end
                            `CJNER3IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end
                            `CJNER4IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end                             
                            `CJNER5IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end
                            `CJNER6IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end
                            `CJNER7IO:
                                begin
                                    if(!comp_flag)
                                        begin
                                            pc_load = 1;
                                        end   
                                end     
                            `AJMP6:
                                begin
                                    pc_load = 1;
                                end
                            `AJMP7:
                                begin
                                    pc_load = 1;
                                end
                            `CLRA:
                                begin
                                    a_load = 1;
                                end
                            `MOVAD:
                                begin
                                    a_load = 1;
                                end
                            `CPLA:
                                begin
                                    a_load = 1;
                                end           
                                
                            default:
                                begin                               
                                end                       
                        endcase                        
                    end                                  
                 default:
                    begin
                    next_state = `s_fetch1;
                    end
                  
            endcase
       end
       else
        begin
            next_state = 3'b000;
            
            ir1_load = 0;
            ir2_load = 0;
            ir3_load = 0;
            
            it_jmp_load = `i_null;
            ljmp_load = 0;
            ajmp_load = 0;
            rjmp_load = 0;
            retjmp_load = 0;
            
            sp_inc = 0;
            sp_dec = 0;
            sp_load = 0;
            pc_inc = 0;
            pc_load = 0;
            pc_load_ret = 0;
    
            alu_en = 0;
            alu_in1_src_sel = 2'b11;
            alu_in2_src_sel = 2'b11;
            
            a_load = 0;
            a_src_sel = 2'b00;
            
            stack_src_sel = 3'b000;
            
            rx_src = 3'b000;
            ram_addr_src_sel = 2'b11;
            ram_src_sel = 3'b000;
    
            psw_load = 0;

            it_jmp = 0;
        end
   end
    
always@(posedge clock)
begin
    if(reset)
        begin
            state = `s_fetch1;
        end
    else
        state = next_state;
end

assign ea = ie[7];

assign et0 = ie[1];
assign et1 = ie[3];
assign ext0 = ie[0];

initial
    begin
        state = 3'b000;
        next_state = 3'b000;
        
        ir1_load = 0;
        ir2_load = 0;
        ir3_load = 0;
        
        it_jmp_load = `i_null;
        ljmp_load = 0;
        ajmp_load = 0;
        rjmp_load = 0;
        retjmp_load = 0;
        
        sp_inc = 0;
        sp_dec = 0;
        sp_load = 0;
        pc_inc = 0;
        pc_load = 0;
        pc_load_ret = 0;

        alu_en = 0;
        alu_in1_src_sel = 2'b11;
        alu_in2_src_sel = 2'b11;
        
        a_load = 0;
        a_src_sel = 2'b00;
        
        stack_src_sel = 3'b000;
        
        rx_src = 3'b000;
        ram_addr_src_sel = 2'b11;
        ram_src_sel = 3'b000;

        psw_load = 0;
        
        it0 = 0;
        it_jmp = 0;        
end 

endmodule