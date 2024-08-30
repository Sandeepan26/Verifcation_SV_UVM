
module dff(input clk, d, rst, output reg q);
  
  always@(posedge clk) begin
    if(rst)
      q <= 1'b0;
    else
      q <= d;
  end
  
endmodule

/*--INTERFACE------ */

interface dff_intf();
  logic clk, d, rst, q;
endinterface
