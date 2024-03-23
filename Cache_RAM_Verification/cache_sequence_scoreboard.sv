`include "cache_sequence_monitor.sv"

class cache_data_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(cache_data_scoreboard)
  
  cache_sequence_item cache_item;
  
  bit [31:0] wr_address, wr_data, rd_data;
  bit we;
  
  uvm_analysis_imp #(cache_sequence_item, cache_data_scoreboard) scoreboard_read;
  
  function new(string path = "cache_data_scoreboard", uvm_component parent = null);
	
    super.new(path, parent);
  
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    scoreboard_read = new("scoreboard_read", this);
    
  endfunction
  
  function void write (cache_sequence_item cache_item);
  
    if(cache_item.wr_en == 1'b0)
      
    	if(cache_item.rd_data == {16{2'b01}})
       		`uvm_info("Cache Scoreboard", "Successful Cache Read", UVM_NONE)
    	else 
          
    	`uvm_info("Cache_Scoreboard", "Cache Read Unsuccessful", UVM_NONE)
    else
    	`uvm_info("Cache_Scoreboard", "Write transaction initiated to memory", UVM_NONE)
      
  endfunction
  
endclass
