`timescale 1ns / 1ps

module UART_tb;
    
    
    reg clock,reset,tx_start,rx;
    reg[7:0] SBUF_wire_in;
    wire[7:0] SBUF_wire_out;
    wire tx;
    
    UART UARTobj(clock,reset,rx,SBUF_wire_in,tx_start,
            
                 tx,SBUF_wire_out);
    
    initial 
        begin
            clock = 0;
            reset = 0;
            tx_start = 0;
            rx = 1;
            #1
            clock = ~clock;
            SBUF_wire_in = 8'h81;
            #1
            clock = ~clock;
            tx_start = 1;
            #1
            clock = ~clock;
            rx = 0;
            #1           
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 1;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 0;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 0;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 0;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 1;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 1;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 0;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            rx = 1;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;           
            #1
            clock = ~clock;
            #1
            clock = ~clock;         
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;           
            #1
            clock = ~clock;
            #1
            clock = ~clock;         
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
            #1
            clock = ~clock;
           
        end
    

endmodule
