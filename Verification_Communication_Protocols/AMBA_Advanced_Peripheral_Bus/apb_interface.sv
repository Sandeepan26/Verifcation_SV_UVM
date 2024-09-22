interface apb_ram_intf();
  
  logic PCLK, PREADY, PRESETn, PWRITE, PENABLE, PSEL, PSLVERR;
  logic [31:0] PADDR, PDATA, PRDATA;
  
endinterface 
