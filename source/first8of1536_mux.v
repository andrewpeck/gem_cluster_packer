module first8of1536_mux (
  input clock4x,
  input global_reset,

  input  [1536-1:0]    vpfs,

  input  [1536*3-1:0]  cnts,

  output [2:0]      cnt0,
  output [2:0]      cnt1,
  output [2:0]      cnt2,
  output [2:0]      cnt3,
  output [2:0]      cnt4,
  output [2:0]      cnt5,
  output [2:0]      cnt6,
  output [2:0]      cnt7,

  output [10:0]      adr0,
  output [10:0]      adr1,
  output [10:0]      adr2,
  output [10:0]      adr3,
  output [10:0]      adr4,
  output [10:0]      adr5,
  output [10:0]      adr6,
  output [10:0]      adr7
);


parameter [2:0] offset = 3'd2;

reg [2:0] phase=offset;
wire cycle = phase[2];
always @(posedge clock4x) begin
  phase <= (global_reset) ? offset : phase+1'b1;
end

wire [10:0] adr0_a, adr1_a, adr2_a, adr3_a, adr4_a, adr5_a, adr6_a, adr7_a;
wire [10:0] adr0_b, adr1_b, adr2_b, adr3_b, adr4_b, adr5_b, adr6_b, adr7_b;
wire  [2:0] cnt0_a, cnt1_a, cnt2_a, cnt3_a, cnt4_a, cnt5_a, cnt6_a, cnt7_a;
wire  [2:0] cnt0_b, cnt1_b, cnt2_b, cnt3_b, cnt4_b, cnt5_b, cnt6_b, cnt7_b;

assign {cnt0,adr0} = (cycle==1'b0) ? {cnt0_a, adr0_a} : {cnt0_b, adr0_b};
assign {cnt1,adr1} = (cycle==1'b0) ? {cnt1_a, adr1_a} : {cnt1_b, adr1_b};
assign {cnt2,adr2} = (cycle==1'b0) ? {cnt2_a, adr2_a} : {cnt2_b, adr2_b};
assign {cnt3,adr3} = (cycle==1'b0) ? {cnt3_a, adr3_a} : {cnt3_b, adr3_b};
assign {cnt4,adr4} = (cycle==1'b0) ? {cnt4_a, adr4_a} : {cnt4_b, adr4_b};
assign {cnt5,adr5} = (cycle==1'b0) ? {cnt5_a, adr5_a} : {cnt5_b, adr5_b};
assign {cnt6,adr6} = (cycle==1'b0) ? {cnt6_a, adr6_a} : {cnt6_b, adr6_b};
assign {cnt7,adr7} = (cycle==1'b0) ? {cnt7_a, adr7_a} : {cnt7_b, adr7_b};

first8of1536 u_first8_a (
    .global_reset(global_reset),
    .clock4x(clock4x),
    .vpfs (vpfs),
    .cnts (cnts),
    .delay(4'd0),

    .adr0(adr0_a),
    .adr1(adr1_a),
    .adr2(adr2_a),
    .adr3(adr3_a),
    .adr4(adr4_a),
    .adr5(adr5_a),
    .adr6(adr6_a),
    .adr7(adr7_a),

    .cnt0(cnt0_a),
    .cnt1(cnt1_a),
    .cnt2(cnt2_a),
    .cnt3(cnt3_a),
    .cnt4(cnt4_a),
    .cnt5(cnt5_a),
    .cnt6(cnt6_a),
    .cnt7(cnt7_a)
);

first8of1536 u_first8_b (
    .clock4x(clock4x),
    .delay(4'd3),
    .global_reset(global_reset),
    .vpfs (vpfs),
    .cnts (cnts),

    .adr0(adr0_b),
    .adr1(adr1_b),
    .adr2(adr2_b),
    .adr3(adr3_b),
    .adr4(adr4_b),
    .adr5(adr5_b),
    .adr6(adr6_b),
    .adr7(adr7_b),

    .cnt0(cnt0_b),
    .cnt1(cnt1_b),
    .cnt2(cnt2_b),
    .cnt3(cnt3_b),
    .cnt4(cnt4_b),
    .cnt5(cnt5_b),
    .cnt6(cnt6_b),
    .cnt7(cnt7_b)
);

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
