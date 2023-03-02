`timescale 1ns / 1ps

module top(clock,reset_button,ex0_button,

             tx,p0
          );
    
input clock,reset_button;

input  ex0_button;
output  tx;
output wire[7:0] p0;
wire[7:0] p1;
wire[7:0] p2;
wire[7:0] p3;


wire[7:0] sbuf_tx;
wire[7:0] sbuf_rx;
wire[7:0] opcode;
wire[7:0] ram_out;
wire[7:0] psw;
wire[7:0] tcon;
wire[7:0] tmod;
wire[7:0] th1,tl1;
wire[7:0] th0;
wire[7:0] tl0,ie,ckdiv;
wire[1:0] a_src_sel;
wire[2:0] alu_in1_src_sel,alu_in2_src_sel,it_jmp_load;
wire[1:0] ram_addr_src_sel;
wire[2:0] ram_src_sel,stack_src_sel,rx_src;
wire tr0,tr1;
wire tf0,tf1;
wire reset,reset_button,ex0,ex0_button;
wire a_direct, a_load;

reg uart_clock;
reg rxtx;

initial
    begin  
        rxtx = 0; 
        uart_clock = 0;
    end

always@(posedge tf1)
    begin
        uart_clock = ~uart_clock; 
    end

debouncer debouncer_ex0(clock,ex0_button,ex0);
debouncer debouncer_reset(clock,reset_button,reset);

datapath datapath_obj(
         clock,reset,pc_load,pc_load_ret,pc_inc,pc_save,sp_inc,sp_dec,
         psw_load,sp_load,ram_we,a_load,en_stack_out,
         ir1_load,ir2_load,ir3_load,alu_in1_src_sel,alu_in2_src_sel,alu_en,
         ljmp_load,ajmp_load,retjmp_load,it_jmp_load,rjmp_load,a_src_sel,ram_src_sel,stack_src_sel,
         ram_addr_src_sel,rx_src,
                
         psw,opcode,tcon,tmod,tl0,th0,tl1,th1,ie,ckdiv,comp_flag,a_direct,psw_direct,
         sbuf_tx,sbuf_rx,p0,p1,p2,p3,tx_start
         );
                
controlunit controlunit_obj(
            clock,reset,psw,opcode,tf0,tf1,ie,comp_flag,a_direct,psw_direct,ex0,rxtx,
                    
            pc_load,pc_load_ret,pc_inc,pc_save,sp_inc,sp_dec,
            psw_load,sp_load,ram_we,a_load,en_stack_out,
            ir1_load,ir2_load,ir3_load,alu_in1_src_sel,alu_in2_src_sel,alu_en,ljmp_load,
            ajmp_load,retjmp_load,it_jmp_load,rjmp_load,a_src_sel,ram_src_sel,stack_src_sel,
            ram_addr_src_sel,rx_src      
                          ); 
 
clock_divider clock_divider_t0(clock,reset,ckdiv[3:0],divided_clock_t0);
clock_divider clock_divider_t1(clock,reset,ckdiv[7:4],divided_clock_t1);
                         
timer timer0(divided_clock_t0,reset,tcon[5:4],tmod[0],tl0,th0,tf0,tr0);  
timer timer1(divided_clock_t1,reset,tcon[7:6],tmod[4],tl1,th1,tf1,tr1);

UART uart_obj(uart_clock,reset,rx,sbuf_tx,tx_start,
            
              tx,sbuf_rx);   


                      
                   
endmodule
