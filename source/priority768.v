//`define debug_priority1536
`timescale 1ns / 100 ps

module priority768 (

  input clock,

  input   [768  -1:0] vpfs_in,
  input   [768*3-1:0] cnts_in,

  output cluster_found,

  output  [10:0] adr,
  output   [2:0] cnt
);

parameter MXPADS = 768;

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

  // register vpfs by 1 for fanout

  // delay counts by 2 clock to align with data coming out of truncator
  reg [2:0] cnts [MXPADS-1:0];
  reg [MXPADS-1:0] vpfs;
  wire   [768*3-1:0] cnts_dly;

  genvar ipad;
  generate
  for (ipad=0; ipad<MXPADS; ipad=ipad+1) begin:padloop

  SRL16E cntdly0 (
    .CE  (1'b1),
    .CLK (clock),
    .D   (cnts_in [ipad*3+0]),
    .Q   (cnts_dly[ipad*3+0]),
    .A0  (1'b0),
    .A1  (1'b0),
    .A2  (1'b0),
    .A3  (1'b0)
  );

  SRL16E cntdly1 (
    .CE  (1'b1),
    .CLK (clock),
    .D   (cnts_in [ipad*3+1]),
    .Q   (cnts_dly[ipad*3+1]),
    .A0  (1'b0),
    .A1  (1'b0),
    .A2  (1'b0),
    .A3  (1'b0)
  );

  SRL16E cntdly2 (
    .CE  (1'b1),
    .CLK (clock),
    .D   (cnts_in [ipad*3+2]),
    .Q   (cnts_dly[ipad*3+2]),
    .A0  (1'b0),
    .A1  (1'b0),
    .A2  (1'b0),
    .A3  (1'b0)
  );

  always @(posedge clock)
    cnts[ipad] <= cnts_dly [ipad*3+2:ipad*3];

  always @(posedge clock)
    vpfs[ipad] <= vpfs_in[ipad];

  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
// Parameters and Interconnects
//----------------------------------------------------------------------------------------------------------------------

parameter MXKEYS    = 768;
parameter MXKEYBITS = 10;

wire [ 383:0] vpf_s0;
wire [ 191:0] vpf_s1;
wire [  95:0] vpf_s2;
reg  [  47:0] vpf_s3;
wire [  23:0] vpf_s4;
wire [  11:0] vpf_s5;
wire [   5:0] vpf_s6;
wire [   2:0] vpf_s7;
reg  [   0:0] vpf_s8;

wire [MXKEYBITS-10:0] key_s0 [383:0];
wire [MXKEYBITS- 9:0] key_s1 [191:0];
wire [MXKEYBITS- 8:0] key_s2 [ 95:0];
reg  [MXKEYBITS- 7:0] key_s3 [ 47:0];
wire [MXKEYBITS- 6:0] key_s4 [ 23:0];
wire [MXKEYBITS- 5:0] key_s5 [ 11:0];
wire [MXKEYBITS- 4:0] key_s6 [  5:0];
wire [MXKEYBITS- 3:0] key_s7 [  2:0];
reg  [MXKEYBITS- 1:0] key_s8 [  0:0];

wire [2:0] cnt_s0 [383:0];
wire [2:0] cnt_s1 [191:0];
wire [2:0] cnt_s2 [ 95:0];
reg  [2:0] cnt_s3 [ 47:0];
wire [2:0] cnt_s4 [ 23:0];
wire [2:0] cnt_s5 [ 11:0];
wire [2:0] cnt_s6 [  5:0];
wire [2:0] cnt_s7 [  2:0];
reg  [2:0] cnt_s8 [  0:0];

// Stage 0 : 384 of 768
genvar ihit;
generate
for (ihit=0; ihit<384; ihit=ihit+1) begin: s0
  assign {vpf_s0[ihit], cnt_s0[ihit], key_s0[ihit]} = (vpfs[ihit*2]) ? {vpfs[ihit*2], cnts[ihit*2], 1'b0} : {vpfs[ihit*2+1], cnts[ihit*2+1], 1'b1} ;
end
endgenerate


// Stage 1: 192 of 384
generate
for (ihit=0; ihit<192; ihit=ihit+1) begin: s1
  assign {vpf_s1[ihit], cnt_s1[ihit], key_s1[ihit]} = vpf_s0[ihit*2] ?  {vpf_s0[ihit*2  ], cnt_s0[ihit*2], {1'b0,key_s0[ihit*2  ]}} : {vpf_s0[ihit*2+1], cnt_s0[ihit*2+1], {1'b1,key_s0[ihit*2+1]}};
end
endgenerate

// Stage 2: 192 of 384
generate
for (ihit=0; ihit<96; ihit=ihit+1) begin: s2
  assign {vpf_s2[ihit], cnt_s2[ihit], key_s2[ihit]} = vpf_s1[ihit*2] ?  {vpf_s1[ihit*2  ], cnt_s1[ihit*2], {1'b0,key_s1[ihit*2  ]}} : {vpf_s1[ihit*2+1], cnt_s1[ihit*2+1], {1'b1,key_s1[ihit*2+1]}} ;
end
endgenerate

// Stage 3: 96 of 192
generate
for (ihit=0; ihit<48; ihit=ihit+1) begin: s3
  always @(posedge clock)
  {vpf_s3[ihit], cnt_s3[ihit], key_s3[ihit]} <= vpf_s2[ihit*2] ?  {vpf_s2[ihit*2  ], cnt_s2[ihit*2], {1'b0,key_s2[ihit*2  ]}} : {vpf_s2[ihit*2+1], cnt_s2[ihit*2+1], {1'b1,key_s2[ihit*2+1]}} ;
end
endgenerate

// Stage 4: 48 of 96
generate
for (ihit=0; ihit<24; ihit=ihit+1) begin: s4
  assign {vpf_s4[ihit], cnt_s4[ihit], key_s4[ihit]} = vpf_s3[ihit*2] ?  {vpf_s3[ihit*2  ], cnt_s3[ihit*2], {1'b0,key_s3[ihit*2  ]}} : {vpf_s3[ihit*2+1], cnt_s3[ihit*2+1], {1'b1,key_s3[ihit*2+1]}} ;
end
endgenerate

// stage 5: 24 of 48
generate
for (ihit=0; ihit<12; ihit=ihit+1) begin: s5
  assign {vpf_s5[ihit], cnt_s5[ihit], key_s5[ihit]} = vpf_s4[ihit*2] ?  {vpf_s4[ihit*2  ], cnt_s4[ihit*2], {1'b0,key_s4[ihit*2  ]}} : {vpf_s4[ihit*2+1], cnt_s4[ihit*2+1], {1'b1,key_s4[ihit*2+1]}} ;
end
endgenerate

// stage 6: 12 of 24
generate
for (ihit=0; ihit<6; ihit=ihit+1) begin: s6
  assign   {vpf_s6[ihit], cnt_s6[ihit], key_s6[ihit]} = vpf_s5[ihit*2] ?  {vpf_s5[ihit*2  ], cnt_s5[ihit*2], {1'b0,key_s5[ihit*2  ]}} : {vpf_s5[ihit*2+1], cnt_s5[ihit*2+1], {1'b1,key_s5[ihit*2+1]}} ;
end
endgenerate

// stage 7: 6 of 12
generate
for (ihit=0; ihit<3; ihit=ihit+1) begin: s7
  assign {vpf_s7[ihit], cnt_s7[ihit], key_s7[ihit]} = vpf_s6[ihit*2] ?  {vpf_s6[ihit*2  ], cnt_s6[ihit*2], {1'b0,key_s6[ihit*2  ]}} : {vpf_s6[ihit*2+1], cnt_s6[ihit*2+1], {1'b1,key_s6[ihit*2+1]}} ;
end
endgenerate

// Stage 6: 1 of 3 Parallel Encoder
always @(*) begin
  if      (vpf_s7[0]) {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[0], cnt_s7[0], {2'b00, key_s7[0]}};
  else if (vpf_s7[1]) {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[1], cnt_s7[1], {2'b01, key_s7[1]}};
  else                {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[2], cnt_s7[2], {2'b10, key_s7[2]}};
end

assign adr           =                      key_s8[0];
assign cluster_found =                      vpf_s8[0];
assign cnt           = {3{cluster_found}} & cnt_s8[0];

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
