
`include "cache_sequence_driver.sv"

class cache_monitor extends uvm_monitor;
  `uvm_component_utils(cache_monitor)
  
  uvm_analysis_port #(cache_sequence_item) monitor_to_scoreboard; //analysis port is used to broadcast transaction to multiple ports.
  
  cache_sequence_item cache_item;
  
  virtual cache_ram_interface crintf;
  
  function new(input string path = "cache_monitor", uvm_component parent = null);
    
    super.new(path, parent);
    
    cache_item = cache_sequence_item :: type_id :: create("cache_item");
    
    monitor_to_scoreboard = new ("monitor_to_scoreboard", this);
    
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual cache_ram_interface) :: get(this, "", "crintf", crintf))
      `uvm_info("Cache Monitor", $sformatf("Interface Accessible, Monitor proceeding with sending the transaction to scorbeoard"), UVM_NONE)
      
    else
      `uvm_error("Cache Monitor", "Interface not accessible, cannot proceed with transaction to the scoreboard");
    
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
      
      cache_item.wr_data = crintf.cache_request_data;
      cache_item.wr_addr = crintf.cache_request_addr;
      cache_item.wr_en = crintf.wr_en;
      cache_item.rd_data = crintf.cache_read_data;
      
      `uvm_info("Cache Monitor", $sformatf("Data received from the cache as address_sent : %b \t read_write : %b \t data_read_from_memory :%b\t", cache_item.wr_addr, cache_item.wr_en, cache_item.rd_data), UVM_NONE)
      
      monitor_to_scoreboard.write(cache_item);  //writing to analysis port after receiving transaction
 
    end
  endtask  
  
endclass
