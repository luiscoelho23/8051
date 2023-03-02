`timescale 1ns / 1ps

module timer(Clock,Reset,TCON,TMOD,TL_in,TH_in,TF,TR);

input Clock,Reset;

input[7:0] TL_in,TH_in;
output TF,TR;

input wire [1:0] TCON;
input wire TMOD;
reg[7:0] TL, TH;
reg TF,TR;
  
initial
    begin
        TL = 0;
        TR = 0;
        TF = 0;
        TR = 0;
    end

always@(posedge Clock)
begin
    TR = TCON[0];    
    if(Reset)
        begin
            TL = 0;
            TH = 0;
            TF = 0;
            TR = 0;
        end
    else
        if(!TR)
            begin
                TL = TL_in;
                              
                if(!TMOD)
                    begin
                    TH = 0;
                    end
                else
                    begin
                    TH = TH_in;
                    end
                TL = 0;
                TF = 0;
            end
        else 
            begin
                case(TMOD)
                    1'b0:
                        begin
                            if(TH == 8'b1111111 && TL == 8'b11111111)
                                begin
                                    TL = 0;
                                    TH = 0;
                                    TF = 1;          
                                end
                            else 
                                begin
                                    if(TL == 8'b11111111)
                                    begin
                                        TL = 0;
                                        TH = TH + 1;
                                        TF = 0;
                                    end
                                    else
                                    begin
                                        TL = TL + 1;
                                        TF = 0;
                                    end
                                end
                        end     
                    1'b1:
                        begin
                            if(TH == 8'b00000000)
                                begin
                                    TH = 8'b11111111;
                                end
                            if(TL == TH)
                                begin
                                    TL = 0;
                                    TF = 1;          
                                end
                            else
                                begin
                                    TL = TL + 1;
                                    TF = 0;
                                end 
                        end  
                    default:
                        begin
                        end
                endcase    
            end             
end
endmodule
