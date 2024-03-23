`timescale 1ps/1fs

`include "cache_ram_test.sv"


module verification_testbench;
 
  cache_ram_interface cr_intf();
  
  mem_top m_top(.clk(cr_intf.clk), .wen(cr_intf.wr_en), .cpu_addr(cr_intf.cache_request_addr), .cpu_dat(cr_intf.cache_request_data), .cache_dat(cr_intf.cache_read_data));
 
  always #10 cr_intf.clk = ~cr_intf.clk;
  
  initial begin
    
    cr_intf.clk = 1'b0;
    
    uvm_config_db #(virtual cache_ram_interface) :: set(null, "*", "crintf", cr_intf);
    
    
    run_test("cache_test");
    
  end
  
  
endmodule
