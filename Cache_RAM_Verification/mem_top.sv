`include "cache_design.sv"
`include "ram.sv"
`include "cache_ram_interface.sv"


//Top module to instantiate cache and ram

module mem_top(input clk, wen, [31:0] cpu_addr, [31:0] cpu_dat, output [31:0]cache_dat);
  
  wire wr_cache_mem;
  wire [31:0] cache_addr_mem, cache_dat_request, cache_to_mem_addr, mem_to_cache_data;
  
  assign cache_dat = cache_dat_request; //assign cache data requested to cache from cache to output port
    
  cache_mem cache_inst(.clk(clk), .w_e(wen), .cpu_address(cpu_addr), .cpu_data(cpu_dat), .mem_to_cache_data(mem_to_cache_data), .wr_mem(wr_cache_mem), .cache_data_out(cache_dat_request), .cache_to_mem_data(cache_addr_mem), .cache_to_mem_address(cache_to_mem_addr) );
  
  RAM RAM_inst(.clk(clk), .wr(wr_cache_mem), .address(cache_to_mem_addr), .data(cache_addr_mem), .mem_data(mem_to_cache_data));
  
endmodule
