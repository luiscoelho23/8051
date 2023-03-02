`timescale 1ns / 1ps

module debouncer(clock,button,

                 button_out
    );

input clock, button;
output reg button_out;    
reg[7:0] counter;

initial 
    begin
        counter = 8'b00000000;
        button_out = 1'b0;
    end
    
always@(negedge clock)
    begin
        if(button == 1'b1)
            begin
                if(counter < 8'b11111111)
                    begin
                        counter = counter + 1;
                    end
            end
        else
            begin
                if(counter > 8'b00000000)
                    begin
                        counter = counter - 1;
                    end
            end
                
        if(counter >= 8'b01111111)
            begin
                button_out = 1'b1;
            end
        else
            begin
                button_out = 1'b0;
            end
    end
  
endmodule
