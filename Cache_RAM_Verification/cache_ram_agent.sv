`include "cache_sequence_scoreboard.sv"

class cache_ram_agent extends uvm_agent;
  
  `uvm_component_utils(cache_ram_agent)
  
  //building an active agent for writing data to cache
  
  cache_sequence_driver cache_drv;
  
  cache_monitor cache_mon;
  
  uvm_sequencer #(cache_sequence_item) cseqr;
  
  function new(string path = "cache_ram_agent", uvm_component pr = null);
    
    super.new(path, pr);
    
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    cache_drv = cache_sequence_driver :: type_id :: create("cache_drv", this);
    
    cache_mon = cache_monitor :: type_id :: create("cache_mon", this);
    
    cseqr = uvm_sequencer #(cache_sequence_item) :: type_id :: create("cseqr", this);
    
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);
    
    cache_drv.seq_item_port.connect(cseqr.seq_item_export);
    
  endfunction
  
endclass
    
