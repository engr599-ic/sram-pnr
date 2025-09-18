// OpenRAM SRAM model
// Words: 1024
// Word size: 8

module sram_8_1024_sky130A(
// Port 0: RW
    clk,csb0,web0,addr0,din0,dout0
  );

  input  clk; // clock
  input   csb0; // active low chip select
  input  web0; // active low write control
  input [9:0]  addr0;
  input [7:0]  din0;
  output [7:0] dout0;

  reg  csb0_reg;
  reg  web0_reg;
  reg [9:0]  addr0_reg;
  reg [7:0]  din0_reg;
  reg [7:0]  dout0;

  // All inputs are registers
  always @(posedge clk)
  begin
    csb0_reg = csb0;
    web0_reg = web0;
    addr0_reg = addr0;
    din0_reg = din0;
  end

reg [7:0] mem [0:1023];

  // Memory Write Block Port 0
  // Write Operation : When web0 = 0, csb0 = 0
  always @ (negedge clk)
  begin : MEM_WRITE0
    if ( !csb0_reg && !web0_reg )
        mem[addr0_reg] = din0_reg;
  end

  // Memory Read Block Port 0
  // Read Operation : When web0 = 1, csb0 = 0
  always @ (negedge clk)
  begin : MEM_READ0
    if (!csb0_reg && web0_reg)
       dout0 <= mem[addr0_reg];
  end

endmodule
