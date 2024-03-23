interface cache_ram_interface;
  
  bit clk, wr_en;
  logic [31:0] cache_request_data;
  logic [31:0] cache_request_addr;
  logic [31:0] cache_read_data;
  
 
  
endinterface
