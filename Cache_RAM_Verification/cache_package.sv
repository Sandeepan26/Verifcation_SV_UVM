package cache_ram;

typedef struct {	
  	reg valid;
  	reg [19:0] tag;
    reg [31:0] data;
} cache_block;

endpackage
