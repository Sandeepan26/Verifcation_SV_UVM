`include "uvm_macros.svh"
 import uvm_pkg :: *;

class cache_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(cache_sequence_item)
  
  randc bit [31:0] wr_addr;
  randc bit [31:0] wr_data;  //write address and data
  rand bit wr_en;
  bit [31:0] rd_data; //read address and data
   
  constraint write_addr_constraint {wr_addr == 1000;}
  
  function new(input string path = "cache_sequence_item");
  	super.new(path);
  endfunction

               
endclass
