`timescale 1ns / 1ps

//Bus Width
`define STACKADDRBUS   4
`define STACKBUS    8

`define STACKWIDE   8
`define STACKHEIGHT 16

module stack(
	input Clock,
	input WE,
	input [`STACKADDRBUS - 1 : 0]Address,
	input [`STACKBUS - 1 : 0 ]DataIn,
	output[`STACKBUS - 1 : 0 ]StackOut
	);
	
	//STACK Declaration
	reg [`STACKWIDE - 1 :0] STACK [`STACKHEIGHT - 1 :0];

	assign StackOut = STACK[Address];
	
	//STACK Initialization
	integer index;
    
    initial
        begin
       
            for (index = 0;index < `STACKHEIGHT; index = index + 1)
                STACK[index] = 8'h00;
        
        end

    always@(negedge Clock)
            if(WE)
                if(Address < 8'h80)   
                    STACK[Address] <= DataIn;
endmodule 