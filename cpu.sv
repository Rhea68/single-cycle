`include "alucodes.sv"
module cpu #( parameter n = 8,Psize = 5) // data bus width
(input logic clk,  
  input logic nreset, // master reset
 output logic outport
);       

// declarations of local signals that connect CPU modules
// ALU
logic [n-1:0]Wdata;
logic [1:0] ALUfunc; // ALU function

logic imm; // immediate operand signal
logic [n-1:0] b; // output from imm MUX
logic show;


logic [n-1:0] Rdata1, Rdata2; // Register data
logic w,sw,lw; // register write control
logic LT;
logic PCincr,PCabsbranch; // program counter control
logic [Psize-1 : 0]ProgAddress;
// Program Memory
parameter Isize = n+12; // Isize - instruction width
logic [Isize-1:0] I; // I - instruction code
logic [n-1:0] dout;
logic [n-1:0]result;
logic [7:0] mem [17:0];
//logic i;
//------------- code starts here ---------
// module instantiations
pc  #(.Psize(Psize)) progCounter (
        .clk(clk),
        .nreset(nreset),
        .PCincr(PCincr),
        .PCabsbranch(PCabsbranch),
        //.PCrelbranch(PCrelbranch),
        .Branchaddr(I[Psize-1:0]), 
        .PCout(ProgAddress));

prog #(.Psize(Psize),.Isize(Isize)) 
      progMemory (.ProgAddress(ProgAddress),.I(I));

decoder  D (.opcode(I[Isize-1:Isize-4]),
            .PCincr(PCincr),		
            .PCabsbranch(PCabsbranch), 
            //.PCrelbranch(PCrelbranch),
			//.readyin(readyin),
			.show(show),
		    .ALUfunc(ALUfunc),
		    .imm(imm),
		   // .fetch(fetch),
		    .w(w),
			.sw(sw),
			.lw(lw),
			.LT(LT));

regs   #(.n(n))  gpr(
        .clk(clk),
		.nreset(nreset),
		//.i(i),
		.w(w),
        .Wdata(Wdata),
		//.sw(sw),
		//.fetch(fetch),
		.Raddr1(I[Isize-5:Isize-8]),  // reg %d number
		.Raddr2(I[Isize-9:Isize-12]), // reg %s number
        .Rdata1(Rdata1),
		.Rdata2(Rdata2)
		);
		

alu    #(.n(n))  iu(
       .a(Rdata1),
	   .b(b),
	   .result(result),
       .ALUfunc(ALUfunc)
       ); // ALU result -> destination reg
	   
branch   #(.n(n))  br(
       .Rdata1(Rdata1),
	   .Rdata2(Rdata2),
       .LT(LT)
	   );
	   
ram    #(.n(n))  ar(
       .RAMAddress(result),
       .clk(clk),
	   //.nreset(nreset),
	   .din(Rdata2),
	   .sw(sw),
	   .show(show),
	   .dout(dout)
	   ); 

// create MUX for immediate operand
assign b = (imm ? I[n-1:0] : Rdata2);

assign Wdata=(lw)? dout: result;

always_ff @(posedge clk or negedge nreset)
begin
	if (!nreset) // sync reset
                outport <= 1'b0;
	else if(show)
                outport <= 1'b1;
end
endmodule