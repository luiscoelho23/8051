`timescale 1ns / 1ps


module clock_divider(clock,reset,ckdiv,

                     divided_clock
    );
    
input clock,reset;
input [3:0]ckdiv;

reg[15:0] counter;

output reg divided_clock;

initial
    begin
        counter = 0;
        divided_clock = 0;
    end

always@(posedge clock)
    if(!reset)
        begin
            counter = counter + 1;
            case(ckdiv)
                4'b0000:
                    begin
                        divided_clock = ~divided_clock;
                        counter = 0;
                    end 
                4'b0001:
                    begin
                        if(counter == 16'h9C3F)
                            begin
                                divided_clock = ~divided_clock;
                                
                            end
                    end
               4'b0010:
                    begin
                        if(counter == 16'h0003)
                            begin
                                divided_clock = ~divided_clock;
                                
                            end
                    end
               4'b0011:
                    begin
                        if(counter == 16'h03E7)
                            begin
                                divided_clock = ~divided_clock;
                                
                            end
                    end
               4'b0100:
                    begin
                        if(counter == 16'h0063)
                            begin
                                divided_clock = ~divided_clock;                              
                            end    
                    end
            endcase        
        end
    else
        begin
            counter = 0;
            divided_clock = 0;
        end

endmodule
