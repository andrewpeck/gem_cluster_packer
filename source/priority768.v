//`define debug_priority1536
`timescale 1ns / 100 ps

module priority768 (
  input 	clock,
  input   global_reset,

  input   [3:0] latch_delay,
  input         latch_in,

  input   [768  -1:0] vpfs_in,
  input   [768*3-1:0] cnts_in,

  output cluster_found,

  output  [10:0] adr,
  output  [2:0]  cnt
);

parameter MXPADS = 768;

//     //----------------------------------------------------------------------------------------------------------------------
//     // reset
//     //----------------------------------------------------------------------------------------------------------------------
//
//     SRL16E #(.INIT(16'hffff)) u_reset (.CLK(clock),.CE(1'b1),.D(global_reset),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(reset_dly));
//     reg reset=1;
//     always @(posedge clock) reset <= reset_dly;

//----------------------------------------------------------------------------------------------------------------------
// latch_enable
//----------------------------------------------------------------------------------------------------------------------

(* max_fanout = 100 *) reg latch_en=0;
wire [3:0] delay = (latch_delay-1'b1);
SRL16E u_latchdly (.CLK(clock),.CE(1'b1),.D(latch_in),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(latch_dly));
always @(posedge clock) begin
  latch_en <= (latch_delay==0) ? latch_in : latch_dly;
end

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

  (* KEEP = "TRUE" *)
  (* shreg_extract = "no" *)
  reg [2:0] cnts [MXPADS-1:0];
  genvar ipad;
  generate
  for (ipad=0; ipad<MXPADS; ipad=ipad+1) begin:padloop
    always @(posedge clock)
      if (latch_en) cnts [ipad] <= cnts_in [ipad*3+2:ipad*3];
  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
// Parameters and Interconnects
//----------------------------------------------------------------------------------------------------------------------


parameter MXKEYS    = 1536/2;
parameter MXKEYBITS = 10;

wire [ 383:0] vpf_s0;
wire [ 191:0] vpf_s1;
wire [  95:0] vpf_s2;
reg  [  47:0] vpf_s3;
wire [  23:0] vpf_s4;
wire [  11:0] vpf_s5;
wire [   5:0] vpf_s6;
reg  [   2:0] vpf_s7;
reg  [   0:0] vpf_s8;

wire [MXKEYBITS-10:0] key_s0 [383:0];
wire [MXKEYBITS- 9:0] key_s1 [191:0];
wire [MXKEYBITS- 8:0] key_s2 [ 95:0];
reg  [MXKEYBITS- 7:0] key_s3 [ 47:0];
wire [MXKEYBITS- 6:0] key_s4 [ 23:0];
wire [MXKEYBITS- 5:0] key_s5 [ 11:0];
wire [MXKEYBITS- 4:0] key_s6 [  5:0];
reg  [MXKEYBITS- 3:0] key_s7 [  2:0];
reg  [MXKEYBITS- 1:0] key_s8 [  0:0];

wire [2:0] cnt_s0 [383:0];
wire [2:0] cnt_s1 [191:0];
wire [2:0] cnt_s2 [ 95:0];
reg  [2:0] cnt_s3 [ 47:0];
wire [2:0] cnt_s4 [ 23:0];
wire [2:0] cnt_s5 [ 11:0];
wire [2:0] cnt_s6 [  5:0];
reg  [2:0] cnt_s7 [  2:0];
reg  [2:0] cnt_s8 [  0:0];

// Stage 0 : Best 384 of 768
genvar ihit;
generate
for (ihit=0; ihit<384; ihit=ihit+1) begin: s0
  assign {vpf_s0[ihit], cnt_s0[ihit], key_s0[ihit]} = (vpfs_in[ihit*2]) ? {vpfs_in[ihit*2], cnts[ihit*2], 1'b0} : {vpfs_in[ihit*2+1], cnts[ihit*2+1], 1'b1} ;
end
endgenerate


// Stage 1: Best 192 of 384
generate
for (ihit=0; ihit<192; ihit=ihit+1) begin: s1
  assign   {vpf_s1[ihit], cnt_s1[ihit], key_s1[ihit]} = vpf_s0[ihit*2] ?  {vpf_s0[ihit*2  ], cnt_s0[ihit*2], {1'b0,key_s0[ihit*2  ]}} : {vpf_s0[ihit*2+1], cnt_s0[ihit*2+1], {1'b1,key_s0[ihit*2+1]}} ;
end
endgenerate

// Stage 2: Best 192 of 384
generate
for (ihit=0; ihit<96; ihit=ihit+1) begin: s2
  assign {vpf_s2[ihit], cnt_s2[ihit], key_s2[ihit]} = vpf_s1[ihit*2] ?  {vpf_s1[ihit*2  ], cnt_s1[ihit*2], {1'b0,key_s1[ihit*2  ]}} : {vpf_s1[ihit*2+1], cnt_s1[ihit*2+1], {1'b1,key_s1[ihit*2+1]}} ;
end
endgenerate

// Stage 3: Best 96 of 192
generate
for (ihit=0; ihit<48; ihit=ihit+1) begin: s3
  always @(posedge clock) {vpf_s3[ihit], cnt_s3[ihit], key_s3[ihit]} <= vpf_s2[ihit*2] ?  {vpf_s2[ihit*2  ], cnt_s2[ihit*2], {1'b0,key_s2[ihit*2  ]}} : {vpf_s2[ihit*2+1], cnt_s2[ihit*2+1], {1'b1,key_s2[ihit*2+1]}} ;
end
endgenerate

// Stage 4: Best 48 of 96
generate
for (ihit=0; ihit<24; ihit=ihit+1) begin: s4
  assign   {vpf_s4[ihit], cnt_s4[ihit], key_s4[ihit]} = vpf_s3[ihit*2] ?  {vpf_s3[ihit*2  ], cnt_s3[ihit*2], {1'b0,key_s3[ihit*2  ]}} : {vpf_s3[ihit*2+1], cnt_s3[ihit*2+1], {1'b1,key_s3[ihit*2+1]}} ;
end
endgenerate

// stage 5: best 24 of 48
generate
for (ihit=0; ihit<12; ihit=ihit+1) begin: s5
  assign {vpf_s5[ihit], cnt_s5[ihit], key_s5[ihit]} = vpf_s4[ihit*2] ?  {vpf_s4[ihit*2  ], cnt_s4[ihit*2], {1'b0,key_s4[ihit*2  ]}} : {vpf_s4[ihit*2+1], cnt_s4[ihit*2+1], {1'b1,key_s4[ihit*2+1]}} ;
end
endgenerate

// stage 6: best 12 of 24
generate
for (ihit=0; ihit<6; ihit=ihit+1) begin: s6
  assign   {vpf_s6[ihit], cnt_s6[ihit], key_s6[ihit]} = vpf_s5[ihit*2] ?  {vpf_s5[ihit*2  ], cnt_s5[ihit*2], {1'b0,key_s5[ihit*2  ]}} : {vpf_s5[ihit*2+1], cnt_s5[ihit*2+1], {1'b1,key_s5[ihit*2+1]}} ;
end
endgenerate

// stage 7: best 6 of 12
generate
for (ihit=0; ihit<3; ihit=ihit+1) begin: s7
  always @(posedge clock) {vpf_s7[ihit], cnt_s7[ihit], key_s7[ihit]} <= vpf_s6[ihit*2] ?  {vpf_s6[ihit*2  ], cnt_s6[ihit*2], {1'b0,key_s6[ihit*2  ]}} : {vpf_s6[ihit*2+1], cnt_s6[ihit*2+1], {1'b1,key_s6[ihit*2+1]}} ;
end
endgenerate

// Stage 6: Best 1 of 3 Parallel Encoder
always @(*) begin
  if      (vpf_s7[0]) {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[0], cnt_s7[0], {2'b00, key_s7[0]}};
  else if (vpf_s7[1]) {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[1], cnt_s7[1], {2'b01, key_s7[1]}};
  else                {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[2], cnt_s7[2], {2'b10, key_s7[2]}};
end

assign adr = (vpf_s8[0]) ? key_s8[0] : 11'h7FE;
assign cluster_found = vpf_s8[0];
assign cnt = cnt_s8[0];

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
