`include "branch_predictor.sv"
module tb;
  
  reg br;
  reg [31:0] pc;
  wire hit;
  wire [31:0] prdbr;
  
  branch_predictor bprd(br, pc, hit, prdbr);
  
  initial begin
    
    br = 1'b1;
    pc = 1024;
    
    #2
    
    pc = 1024;
    
    #2
    br = 1'b0;
    pc = 1025;
    
    #2
    br = 1'b1;
    pc = 1024;
   
    
    #10 $finish(1);
  end
  
  initial begin
    
    $dumpfile("signals_dump.vcd");
    $dumpvars;
    
  end
  
endmodule
