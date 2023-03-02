`timescale 1ns / 1ps

`include "sfr.v"

`define i_null       3'b000
`define i_t0         3'b001
`define i_t1         3'b010
`define i_ex0        3'b011
`define i_rt         3'b100

module datapath(clock,reset,pc_load,pc_load_ret,pc_inc,pc_save,sp_inc,sp_dec,
                psw_load,sp_load,ram_we,a_load,en_stack_out,
                ir1_load,ir2_load,ir3_load,alu_in1_src_sel,alu_in2_src_sel,alu_en,
                ljmp_load,ajmp_load,retjmp_load,it_jmp_load,rjmp_load,a_src_sel,ram_src_sel,stack_src_sel,
                ram_addr_src_sel,rx_src,
                
                psw,opcode,tcon,tmod,tl0,th0,tl1,th1,ie,ckdiv,comp_flag,a_direct,psw_direct,
                sbuf_tx,sbuf_rx_wire,p0,p1,p2,p3,tx_start
    );
    input clock,reset,pc_load,pc_load_ret,pc_inc,pc_save,sp_inc,sp_dec,
          psw_load,a_load,en_stack_out,
          ir1_load,ir2_load,ir3_load,alu_en,ljmp_load,ajmp_load,retjmp_load,rjmp_load;       
    
    input[2:0] it_jmp_load;
    
    //PC
    reg[15:0] pc;
    wire[15:0] pc_next;
    reg[15:0] pc_temp;

    //IR
    output reg[7:0]opcode;
    reg[7:0] operand1;    
    reg[7:0] operand2;
    
    //RAM
    input wire[1:0] ram_addr_src_sel;
    input wire[2:0] ram_src_sel,rx_src;
    input wire ram_we;
    wire[7:0] ram_out;
    wire[7:0] ram_addr;
    wire[7:0] ram_data_in;
    wire[7:0] ram_out_ram;
    reg[7:0] ram_out_sfr;
    
    //ROM
    wire[15:0] rom_addr;
    wire[7:0] rom_out;
    
    //STACK
    input wire[2:0] stack_src_sel;
    input wire sp_load;
    wire [7:0] stack_out;
    reg[3:0] sp;
    wire[7:0] stack_data_in;
       
    //ALU
    wire alu_en;
    wire[7:0] alu_in1, alu_in2;    
    wire[7:0] psw_in, psw_out;
    wire[7:0] result;
    input wire[2:0] alu_in1_src_sel,alu_in2_src_sel;
    output comp_flag;
    
    //SFRs
    
    //P
    output reg[7:0] p0;
    output reg[7:0] p1;
    output reg[7:0] p2;
    output reg[7:0] p3;
    
    //A
    input wire[1:0] a_src_sel;
    wire[7:0] a_bus;
    wire[7:0] a_bus_mux;
    wire[7:0] a;
    reg[7:0] a_temp;
    output reg a_direct;
    
    //PSW
    wire[7:0] psw_bus;
    output wire[7:0] psw;
    reg[7:0] psw_temp;
    output reg psw_direct;
    
    //UART
    output reg[7:0] sbuf_tx;
    input wire[7:0] sbuf_rx_wire;
    output reg tx_start;
    reg[7:0] sbuf_rx;
    
    //TIMER
    output reg[7:0] ckdiv;
    output reg[7:0] tcon;
    output reg[7:0] tmod;
    output reg[7:0] tl0;
    output reg[7:0] tl1;
    output reg[7:0] th0;
    output reg[7:0] th1;
    
    //INTERRUPT
    output reg[7:0] ie;
        
    register_master #(.size(8))A (.load(a_load),.reset(reset),.clock(clock)
                                            ,.dataIn(a_bus),.dataOut(a));
    
    register_master #(.size(8))PSW (.load(psw_load),.reset(reset),.clock(clock)
                                            ,.dataIn(psw_bus),.dataOut(psw));                                      
   
    stack stack_obj(clock,sp_load,sp,stack_data_in,stack_out);
    
    ram ram_obj(clock,ram_we,ram_addr,ram_data_in,ram_out_ram);
    
    rom rom_obj(rom_addr,rom_out);
    
    alu alu_obj(alu_en,opcode,psw_out,psw_in,alu_in1,alu_in2,result,comp_flag);
     
    always@(negedge clock)
    begin
        sbuf_rx = sbuf_rx_wire;
    end
     
    //Update IR
    always@(negedge clock)
    begin
        if(!reset)
            begin       
                if(ir1_load)
                    opcode = rom_out;
                if(ir2_load)
                    operand1 = rom_out;
                if(ir3_load)
                   operand2 = rom_out; 
            end
        else
            begin
                opcode = 8'h00;
                operand1 = 8'h00;
                operand2 = 8'h00;
            end
            
    end
      
    //SFR
    
    //RAM out by SFRs
    always@(negedge clock)
        begin
                case(ram_addr)
                    `P0:
                        begin
                            ram_out_sfr = p0;
                        end
                    `P1:
                        begin
                            ram_out_sfr = p1;
                        end
                    `P2:
                        begin
                            ram_out_sfr = p2;
                        end
                    `P3:
                        begin
                            ram_out_sfr = p3;
                        end
                    `ACC:
                        begin
                            ram_out_sfr = a;
                        end
                    `PSW:
                        begin
                           ram_out_sfr = psw;
                        end
                    `TCON:
                        begin
                            ram_out_sfr = tcon; 
                        end
                    `TMOD:
                        begin
                            ram_out_sfr = tmod;
                        end
                    `TL0:
                        begin
                            ram_out_sfr = tl0;   
                        end
                    `TL1:
                        begin
                            ram_out_sfr = tl1;
                        end
                    `TH0:
                        begin
                            ram_out_sfr = th0;
                        end
                    `TH1:
                        begin
                            ram_out_sfr = th1;
                        end
                    `IE:
                        begin
                            ram_out_sfr = ie;
                        end
                    `CKDIV:
                        begin
                            ram_out_sfr = ckdiv;
                        end
                    `SBUF_TX:
                        begin
                            ram_out_sfr = sbuf_tx;
                        end                    
                    default:
                        begin
                        end 
                endcase
        end 
    
       
    always@(negedge clock)
        begin
            if(!reset)
            begin
            if(ram_we)
                begin
                case(ram_addr)
                    `P0:
                        begin
                            p0 = ram_data_in;
                        end
                    `P1:
                        begin
                            p1 = ram_data_in;
                        end
                    `P2:
                        begin
                            p2 = ram_data_in;
                        end
                    `P3:
                        begin
                            p3 = ram_data_in;
                        end
                    `ACC:
                        begin
                            a_temp = ram_data_in;
                            a_direct = 1;
                        end
                    `PSW:
                        begin
                           psw_temp = ram_data_in;
                           psw_direct = 1; 
                        end
                    `TCON:
                        begin
                            tcon = ram_data_in; 
                        end
                    `TMOD:
                        begin
                            tmod = ram_data_in; 
                        end
                    `TL0:
                        begin
                            tl0 = ram_data_in;     
                        end
                    `TL1:
                        begin
                            tl1 = ram_data_in;
                        end
                    `TH0:
                        begin
                            th0 = ram_data_in;
                        end
                    `TH1:
                        begin
                            th1 = ram_data_in;
                        end
                    `IE:
                        begin
                            ie = ram_data_in;
                        end
                    `CKDIV:
                        begin
                            ckdiv = ram_data_in;
                        end
                    `SBUF_TX:
                        begin
                            tx_start = 1;
                            sbuf_tx = ram_data_in;
                        end                    
                    default:
                        begin
                        end 
                endcase
                end
                else
                    begin
                        tx_start = 0;                       
                        a_direct = 0;
                        psw_direct = 0;
                    end
           end
           else
               begin
                    tl0 = 8'h00;
                    tl1 = 8'h00;  
                    th0 = 8'h00;
                    th1 = 8'h00;
                    tcon = 8'h00;
                    tmod = 8'h00;
                    ie = 8'h00;
                    ckdiv = 8'h00;
               end
        end
    
    always@(negedge clock)
    begin
        if(!reset)
            begin
                if(pc_inc)
                    begin
                       pc = pc + 1;
                    end
                else
                if(pc_load)
                begin
                    if(ljmp_load)
                        begin
                            pc = {operand1,operand2};
                        end
                    else   
                        if(ajmp_load)
                            begin           
                                pc = {5'b00000,opcode[7:5],operand1};
                            end
                        else
                            if(retjmp_load)
                                begin
                                    pc = pc_temp;
                                end
                            else
                            if(rjmp_load)
                                begin
                                    if(operand2[7])
                                        begin
                                            if(operand2[6:0] == 7'b0000000)
                                                begin
                                                    pc = pc - 8'd128;  
                                                end
                                            else
                                                begin
                                                    pc = pc - {1'b0,operand2[6:0]};
                                                end
                                        end
                                    else
                                        begin
                                            pc = pc + operand2;
                                        end                           
                                end
                            else
                                if(it_jmp_load == `i_t0)
                                    begin
                                        pc = 16'h03;
                                    end
                            else
                                if(it_jmp_load == `i_t1)
                                    begin
                                        pc = 16'h21;
                                    end
                            else
                                if(it_jmp_load == `i_ex0)
                                    begin
                                        pc = 16'h3F;
                                    end
                            else
                                if(it_jmp_load == `i_rt)
                                    begin
                                        pc = 16'h5D;
                                    end
                end       
            end
       else
       begin
        pc = 16'h0000;
       end     
    end
    
    always@(negedge clock)
    begin
        if(!reset)
            begin
                if(pc_save)
                    pc_temp = pc - 1;
                else
                    begin
                    if(en_stack_out)
                        begin
                        if(pc_load_ret)
                            begin
                                pc_temp[7:0] = stack_out;                      
                            end
                            
                        if(!pc_load_ret)
                            begin
                                pc_temp[15:8] = stack_out;                          
                            end
                        end
                     end
            end
        else
            begin
                pc_temp = 16'h0000;
            end     
    end
   
    always@(negedge clock)
        begin
            if(!reset)
                begin
                    if(sp_dec)
                        begin
                            sp = sp - 1;
                        end
                    else
                        if(sp_inc)
                            begin
                                sp = sp + 1;
                            end
                end
            else
                begin
                    sp = 4'h0;
                end    
        end
    
    //RAM
    mux_3to1 mux_3to1_RAM_ADDR(8'b00000000,operand1,{3'b000,psw[4:3],rx_src},ram_addr_src_sel,ram_addr); 
    mux_6to1 mux_6to1_RAM(8'b00000000,operand1,ram_out, a, result, operand2, ram_src_sel, ram_data_in);  
    assign ram_out = ram_addr >= 8'h80 ? ram_out_sfr : ram_out_ram;
    
    //ROM
    assign rom_addr = pc;
    
    //STACK
    mux_6to1 mux_6to1_STACK(psw,a,pc_temp[7:0],pc_temp[15:8],pc[7:0],pc_next[15:8], stack_src_sel, stack_data_in); 
    
    //A
    mux_3to1 mux_3to1_A(ram_out, operand1, result, a_src_sel, a_bus_mux);  
    assign a_bus = a_direct ? a_temp : a_bus_mux;
        
    //PSW
    assign psw_bus = psw_direct ? psw_temp : psw_out;
    assign psw_in = psw;
    
    //PC
    assign pc_next = (pc + 16'h0001);

    //ALU
    mux_5to1 mux_5to1_ALU_IN1(operand2,8'b00000000, ram_out, operand1, a, alu_in1_src_sel, alu_in1);
    mux_5to1 mux_5to1_ALU_IN2(operand2,8'b00000000, ram_out, operand1, a, alu_in2_src_sel, alu_in2);
       
    initial 
        begin
            p0 = 8'h00;
            p1 = 8'h00;
            p2 = 8'h00;
            p3 = 8'h00;
            opcode = 8'h00;
            operand1 = 8'h00;
            operand2 = 8'h00;
            pc = 16'h0000;
            pc_temp = 16'h0000;
            sp = 4'b0000;

            tl0 = 8'h00; 
            th0 = 8'h00;
            tcon = 8'h00;
            tmod = 8'h00;
            ie = 8'h00;
            ckdiv = 8'h00; 
        end
 
endmodule
