`include "apb_ram.v"
`include "apb_interface.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

/*-----apb transaction class--------- */

class apb_transaction extends uvm_sequence_item;
  `uvm_object_utils(apb_transaction)
  
  function new(input string path = "apb_transaction");
    super.new(path);
  endfunction
  
  randc bit [31:0] PADDR, PDATA;
  rand bit PWRITE, PSEL, PENABLE, PRESETn;
  bit PREADY, PSLVERR;
  
  bit [31:0] PRDATA;
  
  constraint addr_cnstr {PADDR inside {[0:31]};}
  constraint data_cnstr {foreach (PDATA[i]) {PDATA[i] == ^i};}
  
endclass : apb_transaction

/*------sequence generation------ */

class apb_generator extends uvm_sequence #(apb_transaction);
  `uvm_object_utils(apb_generator)
  
  apb_transaction apb_tr;
  
  function new(input string path = "apb_generator");
    super.new(path);
  endfunction
  
  task body;
    apb_tr = apb_transaction::type_id::create("apb_tr");
    
    repeat (2) begin
      start_item(apb_tr);
      
      assert (apb_tr.randomize()) $info("Randomization successful");else $error("Randomization Failed!");
      
      finish_item(apb_tr);
    end
    
  endtask

endclass :apb_generator

/*-----apb driver------ */

class apb_driver extends uvm_driver #(apb_transaction);
  `uvm_component_utils(apb_driver)
  
  apb_transaction apb_tr;
  //uvm_analysis_port #(apb_transaction) drv_scb;
  virtual apb_ram_intf apbrintf;
  
  function new(input string path = "apb_driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual apb_ram_intf) :: get(this, "", "apbrintf", apbrintf))
       `uvm_error("DRIVER", "INTERFACE NOT ACCESSIBLE");
    //drv_scb = new("drv_scb", this);
   endfunction
       
   task run_phase(uvm_phase rphase);
     apb_tr = apb_transaction::type_id::create("apb_tr");
     
     forever begin
       seq_item_port.get_next_item(apb_tr);
       //drv_scb.write(apb_tr);
       apbrintf.PRESETn <= apb_tr.PRESETn;
       apbrintf.PWRITE <= apb_tr.PWRITE;
       apbrintf.PSEL <= apb_tr.PSEL;
       apbrintf.PENABLE <= apb_tr.PENABLE;
       apbrintf.PADDR <= apb_tr.PADDR;
       apbrintf.PDATA <= apb_tr.PDATA;
       seq_item_port.item_done(apb_tr);
       
       repeat (10) @(posedge apbrintf.PCLK);
       
     end
     
   endtask
       
endclass : apb_driver
       
/*------APB Monitor------------- */

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  
  function new(input string path = "apb_monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction
    
    virtual apb_ram_intf apbrintf;
    uvm_analysis_port #(apb_transaction) mon_scb;
    apb_transaction apb_tr;
    
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      
      mon_scb = new("mon_scb", this);
      
      if(!uvm_config_db#(virtual apb_ram_intf)::get(this, "", "apbrintf", apbrintf))
        `uvm_error("MONITOR","INTERFACE NOT ACCESSIBLE")
    endfunction
        
    
        virtual task run_phase(uvm_phase phase);
     	apb_tr = apb_transaction::type_id::create("apb_tr");
      
      repeat (10) @(posedge apbrintf.PCLK) begin
       
       apbrintf.PRESETn = apb_tr.PRESETn;
       apbrintf.PWRITE = apb_tr.PWRITE;
       apbrintf.PSEL = apb_tr.PSEL;
       apbrintf.PENABLE = apb_tr.PENABLE;
       apbrintf.PADDR = apb_tr.PADDR;
       apbrintf.PDATA = apb_tr.PDATA;
       apbrintf.PRDATA = apb_tr.PRDATA;
       apbrintf.PREADY = apb_tr.PREADY;
       apbrintf.PSLVERR = apb_tr.PSLVERR;
       
        mon_scb.write(apb_tr);
        
      end
                   
     endtask
    
endclass : apb_monitor
 
/*----APB Scoreboard------------ */
      
class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)
  
  uvm_analysis_imp #(apb_transaction, apb_scoreboard) mon_scb;

  apb_transaction apb_tr_mon;
  
  function new(input string path = "apb_scoreboard", uvm_component pr = null);
    super.new(path, pr);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
  	super.build_phase(phase);
    
    //drv_scb = new("drv_scb", this);
    mon_scb = new("mon_scb", this);
                            
  endfunction
     
 virtual function void write(apb_transaction apb_tr);
  
    begin  
    	apb_tr_mon.PRESETn = apb_tr.PRESETn;
        apb_tr_mon.PWRITE = apb_tr.PWRITE;
        apb_tr_mon.PSEL = apb_tr.PSEL;
        apb_tr_mon.PENABLE = apb_tr.PENABLE;
        apb_tr_mon.PADDR = apb_tr.PADDR;
        apb_tr_mon.PDATA = apb_tr.PDATA;
        apb_tr_mon.PRDATA = apb_tr.PRDATA;
        apb_tr_mon.PREADY = apb_tr.PREADY;
        apb_tr_mon.PSLVERR = apb_tr.PSLVERR;
     end 
      
     if((== apb_tr_mon.PADDR) && (apb_tr_drv.PDATA == apb_tr_mon.PRDATA))
       if((apb_tr_drv.PWRITE == 1'b0) && (apb_tr_mon.PWRITE == 1'b0))
          `uvm_info("SCOREBOARD",$sformatf("TEST PASSED"), UVM_NONE)
        else
          `uvm_info("SCOREBOARD", $sformatf("WRITE OPERATION"), UVM_NONE)
      else
        `uvm_info("SCOREBOARD", $sformatf("TEST FAILED"), UVM_NONE)
        
    endfunction
        
            
endclass :apb_scoreboard
      
/*--APB agent---- */
      
class apb_agent extends uvm_agent;
	`uvm_component_utils(apb_agent)
	
  function new(input string path = "apb_agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  apb_driver apb_drv;
  apb_monitor apb_mon;
  uvm_sequencer#(apb_transaction) apb_sqr;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_drv = apb_driver::type_id::create("apb_drv",this);
    apb_mon = apb_monitor::type_id::create("apb_mon",this);
    apb_sqr = uvm_sequencer#(apb_transaction)::type_id::create("apb_sqr",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    apb_drv.seq_item_port.connect(apb_sqr.seq_item_export);
  endfunction
  

endclass : apb_agent

/*---APB Environment */

class apb_environment extends uvm_env;
  `uvm_component_utils(apb_environment)
	apb_agent apb_ag;
  	apb_scoreboard apb_scb;
  
  function new(input string path = "apb_env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_ag = apb_agent::type_id::create("apb_ag", this);
    apb_scb = apb_scoreboard::type_id::create("apb_scb", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
   // apb_ag.apb_drv.drv_scb.connect(apb_scb.drv_scb);
    apb_ag.apb_mon.mon_scb.connect(apb_scb.mon_scb);
  endfunction
  
endclass : apb_environment
      
/*--APB Test----- */
    
class apb_test extends uvm_test;
  `uvm_component_utils(apb_test);
  
	apb_environment apb_env;
	apb_generator apb_gen;
  
  function new(input string path = "apb_test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_env = apb_environment::type_id::create("apb_env", this);
    apb_gen = apb_generator::type_id::create("apb_gen");
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apb_gen.start(apb_env.apb_ag.apb_sqr);
    #50
    phase.drop_objection(this);
  endtask
  
endclass
      
     
/*-------------TESTBENCH--------------- */
module tb;
  
  apb_ram_intf apbrintf();
  
  APB_RAM apb_ram(.PCLK(apbrintf.PCLK), .PRESETn(apbrintf.PRESETn), .PADDR(apbrintf.PADDR), .PDATA(apbrintf.PDATA), .PSEL(apbrintf.PSEL), .PREADY(apbrintf.PREADY), .PENABLE(apbrintf.PENABLE), .PRDATA(apbrintf.PRDATA), .PSLVERR(apbrintf.PSLVERR), .PWRITE(apbrintf.PWRITE));
  
  
  
   initial apbrintf.PCLK = 1'b0;
  
  always #10 apbrintf.PCLK = ~apbrintf.PCLK;
  
  initial begin
    uvm_config_db#(virtual apb_ram_intf)::set(null, "*", "apbrintf", apbrintf);
    run_test("apb_test");
  end

  initial begin
    $dumpfile("dump_sig.vcd");
    $dumpvars;
  end
