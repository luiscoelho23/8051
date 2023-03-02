`timescale 1ns / 1ps

module UART(clock,reset,rx,SBUF_wire_in,tx_start,
            
            tx,SBUF_wire_out
    );
    
input clock,reset,rx,tx_start;
input wire[7:0] SBUF_wire_in;

output reg tx;
output wire[7:0] SBUF_wire_out;

reg start_tx;
reg tx_done;
reg tx_stop;
reg rx_on;
reg tx_on;

reg[4:0] counter_tx;
reg[4:0] counter_rx;
reg[7:0] SBUF_tx;
reg[7:0] SBUF_rx;

initial
    begin
        tx = 1'b1;  
        tx_stop = 0;
        rx_on = 0;
        tx_on = 0;
        tx_done = 0;
        start_tx = 0;
        counter_tx = 0;
        counter_rx = 0;
        SBUF_tx = 0;
        SBUF_rx = 0;
    end

assign SBUF_wire_out = rx_on ? 8'bzzzzzzzz : SBUF_rx;

always@(posedge tx_start,posedge tx_stop)
begin
    if(reset)   
    begin
        if(tx_stop && !tx_done)
            begin
                tx_done = 1;                
                start_tx = 0;
            end
        else
            begin 
                if(tx_start)
                    begin
                        start_tx = 1;
                        tx_done = 0;
                    end
            end
    end
    else
    begin
        start_tx = 0;
        tx_done = 0;
    end
end
    
always@(posedge clock)
    begin
    if(reset)   
    begin
        if(!tx_on && start_tx && counter_tx == 0)
            begin              
                tx_stop = 0;
                tx_on = 1;
                SBUF_tx = SBUF_wire_in;
                tx = 1'b0;
            end
        else       
        if(tx_on)
            begin
                if(counter_tx < 4'd8)
                    begin
                        tx <= SBUF_tx[counter_tx];
                        counter_tx <= counter_tx + 1;
                    end
                else
                    begin
                        tx_stop = 1;
                        tx = 1'b1;
                        tx_on = 0;
                        counter_tx = 0;
                    end        
            end
      end
      else
      begin
        tx_stop = 0;
        tx = 1'b1;
        tx_on = 0;
        counter_tx = 0;
        SBUF_tx = 0;
      end
   end
   
always@(negedge clock)
begin
    if(!reset)
    begin
            
        if(!rx && counter_rx == 0)
            begin
                rx_on = 1;
            end 
        else
        if(rx_on)
            begin
                if(counter_rx < 4'd8)
                    begin
                        SBUF_rx[counter_rx] <= rx;
                        counter_rx <= counter_rx + 1;    
                    end
                else
                    begin
                        rx_on = 0;
                        counter_rx = 0;
                    end
            end 
    end 
    else
    begin
        rx_on = 0;
        counter_rx = 0;
        SBUF_rx = 0;
    end              
end
    
endmodule
