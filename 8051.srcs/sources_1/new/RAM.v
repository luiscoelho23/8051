`timescale 1ns / 1ps

//Bus Width
`define RAMADDRBUS   8
`define RAMBUS    8

`define RAMWIDE   8
`define RAMHEIGHT 128

module ram(
	input Clock,
	input WE,
	input [`RAMADDRBUS - 1 : 0]Address,
	input [`RAMADDRBUS - 1 : 0 ]DataIn,
	output[`RAMBUS - 1 : 0 ]RamOut
	);
	
	//RAM Declaration
	reg [`RAMWIDE - 1 :0] RAM [`RAMHEIGHT - 1 :0];
    
    integer index;
    
    initial
    begin
     
        for (index = 0;index < `RAMHEIGHT; index = index + 1)
            RAM[index] = 0;    
               
        $readmemh("RAM.mem", RAM);
    end 
    
	assign RamOut = (Address < 8'h80) ? RAM[Address] : 8'bzzzzzzzz;

    always@(negedge Clock)
            if(WE)
                begin
                    if(Address < 8'h80)   
                        RAM[Address] <= DataIn;
                end
endmodule 
