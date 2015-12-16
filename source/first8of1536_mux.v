module first8of1536_mux (
  input clock4x,
  input global_reset,

  input  [1535:0]    vpfs,

  output [10:0]      adr0,
  output [10:0]      adr1,
  output [10:0]      adr2,
  output [10:0]      adr3,
  output [10:0]      adr4,
  output [10:0]      adr5,
  output [10:0]      adr6,
  output [10:0]      adr7
);


reg [2:0] phase=3'd0;
wire cycle = phase[2];
always @(posedge clock4x) begin
  phase <= (global_reset) ? 3'd0 : phase+1'b1;
end

wire [10:0] adr0_a, adr1_a, adr2_a, adr3_a, adr4_a, adr5_a, adr6_a, adr7_a;
wire [10:0] adr0_b, adr1_b, adr2_b, adr3_b, adr4_b, adr5_b, adr6_b, adr7_b;

reg  [1535:0] vpfs_b;
wire [1535:0] vpfs_dly;
srl16e_bbl #(1536) upatdly (.clock(clock4x),.ce(1'b1),.adr(4'd2),.d(vpfs),.q(vpfs_dly));
always @(posedge clock4x) vpfs_b <= vpfs_dly;

assign adr0 = (cycle==1'b0) ? adr0_a : adr0_b;
assign adr1 = (cycle==1'b0) ? adr1_a : adr1_b;
assign adr2 = (cycle==1'b0) ? adr2_a : adr2_b;
assign adr3 = (cycle==1'b0) ? adr3_a : adr3_b;
assign adr4 = (cycle==1'b0) ? adr4_a : adr4_b;
assign adr5 = (cycle==1'b0) ? adr5_a : adr5_b;
assign adr6 = (cycle==1'b0) ? adr6_a : adr6_b;
assign adr7 = (cycle==1'b0) ? adr7_a : adr7_b;

first8of1536 u_first8_a (
    .global_reset(global_reset),
    .clock4x(clock4x),
    .vpfs(vpfs),
    .delay(4'd3),
    .adr0(adr0_a),
    .adr1(adr1_a),
    .adr2(adr2_a),
    .adr3(adr3_a),
    .adr4(adr4_a),
    .adr5(adr5_a),
    .adr6(adr6_a),
    .adr7(adr7_a)
);

first8of1536 u_first8_b (
    .clock4x(clock4x),
    .delay(4'd7),
    .global_reset(global_reset),
    .vpfs(vpfs),
    .adr0(adr0_b),
    .adr1(adr1_b),
    .adr2(adr2_b),
    .adr3(adr3_b),
    .adr4(adr4_b),
    .adr5(adr5_b),
    .adr6(adr6_b),
    .adr7(adr7_b)
);

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
