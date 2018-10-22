
// overcome limitation that the Spartan-6 and prior generations to not allow routing a clock into logic, but we can replicate it with a
// "logic accessible clock" which is recovered from the clock but available on the fabric

module lac (
  input clock,
  input clock4x,
  output clock_lac,
  output strobe
);

reg lac_pos=0;
reg lac_neg=0;

(* max_fanout = 16 *) reg strobe_int;
(* max_fanout = 16 *) wire clock_lac_int;

always @(posedge clock) lac_pos <= ~lac_pos;
always @(negedge clock) lac_neg <= ~lac_neg;

assign clock_lac_int = lac_pos ^ lac_neg;

assign clock_lac = clock_lac_int;
assign strobe    = strobe_int;

reg [3:0] clock_sampled;
always @(posedge clock4x) begin
  clock_sampled <= {clock_sampled[2:0], clock_lac};
  strobe_int   <= (clock_sampled==4'b0110);
end



endmodule
