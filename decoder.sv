//---------------------------------------------------------
// File Name   : decoder.sv
// Function    : picoMIPS instruction decoder 
// Author: rz
// Last revised: 24/06/2024
//---------------------------------------------------------

`include "alucodes.sv"
`include "opcodes.sv"
//---------------------------------------------------------
module decoder
( input logic [3:0] opcode,// top 4 bits of instruction
input logic LT ,
output logic PCincr,PCabsbranch,
output logic [1:0] ALUfunc, 
output logic imm,
output logic show,
output logic w,
output logic sw,
output logic lw);
   
//------------- code starts here ---------
// instruction decoder
//logic takeBranch; // temp variable to control conditional branching
always_comb 
begin	
  // set default output signal values for NOP instruction
   PCincr = 1'b1; // PC increments by default
   PCabsbranch = 1'b0; 
   ALUfunc = `RNOP; 
   imm=1'b0;
   w=1'b0;   
   sw = 1'b0;
   lw = 1'b0;
   show = 1'b0;
   
   case(opcode)     
     `ADD: begin // register-register
	        w = 1'b1; // write result to dest register
			ALUfunc =`RADD;
	      end
     `ADDI: begin // register-immediate
	        w = 1'b1; // write result to dest register
		  imm = 1'b1; // set ctrl signal for imm operand MUX
		  ALUfunc =`RADD;
	      end
	 `MULI:begin
	        w = 1'b1; // write result to dest register
		  imm = 1'b1; // set ctrl signal for imm operand MUX
		  ALUfunc =`RMUL;
	     end
	 `DIVIDED:begin
	       w = 1'b1; // write result to dest register
			ALUfunc =`RDIVIDED;	   
		   end	
				 
	 `LOAD1:begin
	       // lw=1'b1;
			imm=1'b1;
			//w=1'b1;
			ALUfunc =`RADD;
         end
	   `LOAD2:begin
	        lw=1'b1;
			//imm=1'b1;
			w=1'b1;
			//ALUfunc =`RADD;
         end 
		 
     `STORE:begin		
	        sw=1'b1;
			//w=1'b1;
			imm=1'b1;
			ALUfunc =`RADD;
         end
		 
	  `BLT:begin
	       imm=1'b1;
		   if (LT==1'b1)
		     begin
		     PCincr = 1'b0;		
		     PCabsbranch=1'b1;
			 end
		   end
	 `SHOW: begin
	          PCincr = 1'b0;
               show = 1'b1;
              
           end 
   
	default:
	    $error("unimplemented opcode %h",opcode);
 
  endcase // opcode
  
end // always_comb

endmodule //module decoder --------------------------------