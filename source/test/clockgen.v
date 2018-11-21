`timescale 1ns / 100 ps

module clockgen (
  output clock40,
  output clock80,
  output clock160,
  output clock200
);

// LHC Clock
reg clock1x = 0;
reg clock5x = 0;
reg clock1x_180=0;
reg clock2x_180=0;

wire   clock2x      = clock1x ^ clock1x_180;
wire   clock4x      = clock2x ^ clock2x_180;

always      clock1x      = #12.5 ~clock1x;
always      clock5x      = #5.0  ~clock5x;
always @(*) clock1x_180  = #6.25  clock1x;
always @(*) clock2x_180  = #3.125 clock2x;


// outputs
assign clock40  = clock1x;
assign clock80  = clock2x;
assign clock160 = clock4x;
assign clock200 = clock5x;

endmodule
