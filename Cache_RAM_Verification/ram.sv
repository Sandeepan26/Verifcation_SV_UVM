module RAM (input wr, clk, [31:0] address, data, output reg [31:0] mem_data);
  
  reg [31:0] ram [(2**20-1):0] = '{default : {16{2'b01}}};  
  
  always @(posedge clk)
    begin
      if(wr) //wr = 1 for write
      	
        ram[address] <= data;
      
      else     //wr = 0 for read
      	mem_data <= ram[address];
      
    end
  
  
endmodule
