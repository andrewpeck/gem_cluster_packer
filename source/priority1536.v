//`define debug_priority1536
`timescale 1ns / 100 ps

module priority1536 (
  input 	clock,
  input   global_reset,

  input   [3:0] delay,

  input   [MXPADS  -1:0] vpfs,
  input   [MXPADS*3-1:0] cnts,

  output  [10:0] adr,
  output  [2:0]  cnt
);

parameter MXPADS = 1536;

//----------------------------------------------------------------------------------------------------------------------
// reset
//----------------------------------------------------------------------------------------------------------------------

SRL16E u00 (.CLK(clock),.CE(1'b1),.D(global_reset),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(reset_dly));
reg reset=1;
always @(posedge clock) reset <= reset_dly;

//----------------------------------------------------------------------------------------------------------------------
// phase
//----------------------------------------------------------------------------------------------------------------------

(* max_fanout = 20 *) reg [2:0] phase=3'd0;
always @(posedge clock) begin
  phase <= (reset) ? 3'd0 : phase+1'b1;
end


//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------
  wire [1535:0] vpfs_in;
  `ifdef debug_priority1536
    reg [1535:0] vpf_ff;
    always @ (posedge clock) vpf_ff <= vpfs;
    assign vpfs_in = vpf_ff;
  `else
    assign vpfs_in = vpfs;
  `endif

//----------------------------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------------------------

  (* KEEP = "TRUE" *)
  (* shreg_extract = "no" *)
  reg [2:0] cnts_in [MXPADS-1:0];
  genvar ipad;
  generate
  for (ipad=0; ipad<MXPADS; ipad=ipad+1) begin:padloop
    always @(posedge clock)
     if (phase==3'd0) cnts_in [ipad] <= cnts[ipad*3+2:ipad*3];
  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
// Parameters and Interconnects
//----------------------------------------------------------------------------------------------------------------------


parameter MXKEYS    = 1536;
parameter MXKEYBITS = 11;

wire [ 767:0] vpf_s0;
wire [ 383:0] vpf_s1;
wire [ 191:0] vpf_s2;
reg  [  95:0] vpf_s3;
wire [  47:0] vpf_s4;
wire [  23:0] vpf_s5;
wire [  11:0] vpf_s6;
wire [   5:0] vpf_s7;
wire [   2:0] vpf_s8;
reg  [   0:0] vpf_s9;

wire [MXKEYBITS-11:0] key_s0 [767:0];
wire [MXKEYBITS-10:0] key_s1 [383:0];
wire [MXKEYBITS- 9:0] key_s2 [191:0];
reg  [MXKEYBITS- 8:0] key_s3 [ 95:0];
wire [MXKEYBITS- 7:0] key_s4 [ 47:0];
wire [MXKEYBITS- 6:0] key_s5 [ 23:0];
wire [MXKEYBITS- 5:0] key_s6 [ 11:0];
wire [MXKEYBITS- 4:0] key_s7 [  5:0];
wire [MXKEYBITS- 3:0] key_s8 [  2:0];
reg  [MXKEYBITS- 1:0] key_s9 [  0:0];

wire [2:0] cnt_s0 [767:0];
wire [2:0] cnt_s1 [383:0];
wire [2:0] cnt_s2 [191:0];
reg  [2:0] cnt_s3 [ 95:0];
wire [2:0] cnt_s4 [ 47:0];
wire [2:0] cnt_s5 [ 23:0];
wire [2:0] cnt_s6 [ 11:0];
wire [2:0] cnt_s7 [  5:0];
wire [2:0] cnt_s8 [  2:0];
reg  [2:0] cnt_s9 [  0:0];

// Stage 0 : Best 768 of 1536
genvar ihit;
generate
for (ihit=0; ihit<768; ihit=ihit+1) begin: s0
  //assign {vpf_s0[ihit], key_s0[ihit]} = (vpfs_in[ihit*2+1]) ?  {vpfs_in[ihit*2+1],1'b1} :{vpfs_in[ihit*2],  1'b0};
  //assign {vpf_s0[ihit], key_s0[ihit]} = (vpfs_in[ihit*2]) ? {vpfs_in[ihit*2],  1'b0} : {vpfs_in[ihit*2+1],1'b1} ;
  assign {vpf_s0[ihit], cnt_s0[ihit], key_s0[ihit]} = (vpfs_in[ihit*2]) ? {vpfs_in[ihit*2], cnts_in[ihit*2], 1'b0} : {vpfs_in[ihit*2+1], cnts_in[ihit*2+1], 1'b1} ;
end
endgenerate


// Stage 1: Best 384 of 768
generate
for (ihit=0; ihit<384; ihit=ihit+1) begin: s1
  //assign {vpf_s1[ihit], key_s1[ihit]} = vpf_s0[ihit*2+1] ?  {vpf_s0[ihit*2+1], {1'b1,key_s0[ihit*2+1]}} :{vpf_s0[ihit*2  ], {1'b0,key_s0[ihit*2  ]}};
  //assign {vpf_s1[ihit], key_s1[ihit]} = vpf_s0[ihit*2] ?  {vpf_s0[ihit*2  ], {1'b0,key_s0[ihit*2  ]}} : {vpf_s0[ihit*2+1], {1'b1,key_s0[ihit*2+1]}} ;
  assign   {vpf_s1[ihit], cnt_s1[ihit], key_s1[ihit]} = vpf_s0[ihit*2] ?  {vpf_s0[ihit*2  ], cnt_s0[ihit*2], {1'b0,key_s0[ihit*2  ]}} : {vpf_s0[ihit*2+1], cnt_s0[ihit*2+1], {1'b1,key_s0[ihit*2+1]}} ;
end
endgenerate

// Stage 2: Best 192 of 384
generate
for (ihit=0; ihit<192; ihit=ihit+1) begin: s2
  //assign {vpf_s2[ihit], key_s2[ihit]} = vpf_s1[ihit*2+1] ?  {vpf_s1[ihit*2+1], {1'b1,key_s1[ihit*2+1]}}: {vpf_s1[ihit*2  ], {1'b0,key_s1[ihit*2  ]}};
  //assign {vpf_s2[ihit], key_s2[ihit]} = vpf_s1[ihit*2] ?   {vpf_s1[ihit*2  ], {1'b0,key_s1[ihit*2  ]}} : {vpf_s1[ihit*2+1], {1'b1,key_s1[ihit*2+1]}};
  assign {vpf_s2[ihit], cnt_s2[ihit], key_s2[ihit]} = vpf_s1[ihit*2] ?  {vpf_s1[ihit*2  ], cnt_s1[ihit*2], {1'b0,key_s1[ihit*2  ]}} : {vpf_s1[ihit*2+1], cnt_s1[ihit*2+1], {1'b1,key_s1[ihit*2+1]}} ;
  //always @(posedge clock)   {vpf_s2[ihit], cnt_s2[ihit], key_s2[ihit]} <= vpf_s1[ihit*2] ?  {vpf_s1[ihit*2  ], cnt_s1[ihit*2], {1'b0,key_s1[ihit*2  ]}} : {vpf_s1[ihit*2+1], cnt_s1[ihit*2+1], {1'b1,key_s1[ihit*2+1]}} ;
end
endgenerate

// Stage 3: Best 96 of 192
generate
for (ihit=0; ihit<96; ihit=ihit+1) begin: s3
  //assign {vpf_s3[ihit], key_s3[ihit]} = vpf_s2[ihit*2+1] ?  {vpf_s2[ihit*2+1], {1'b1,key_s2[ihit*2+1]}}: {vpf_s2[ihit*2  ], {1'b0,key_s2[ihit*2  ]}};
  //assign {vpf_s3[ihit], key_s3[ihit]} = vpf_s2[ihit*2] ?   {vpf_s2[ihit*2  ], {1'b0,key_s2[ihit*2  ]}} : {vpf_s2[ihit*2+1], {1'b1,key_s2[ihit*2+1]}};
  //assign   {vpf_s3[ihit], cnt_s3[ihit], key_s3[ihit]} = vpf_s2[ihit*2] ?  {vpf_s2[ihit*2  ], cnt_s2[ihit*2], {1'b0,key_s2[ihit*2  ]}} : {vpf_s2[ihit*2+1], cnt_s2[ihit*2+1], {1'b1,key_s2[ihit*2+1]}} ;
  always @(posedge clock) {vpf_s3[ihit], cnt_s3[ihit], key_s3[ihit]} <= vpf_s2[ihit*2] ?  {vpf_s2[ihit*2  ], cnt_s2[ihit*2], {1'b0,key_s2[ihit*2  ]}} : {vpf_s2[ihit*2+1], cnt_s2[ihit*2+1], {1'b1,key_s2[ihit*2+1]}} ;
end
endgenerate

// Stage 4: Best 48 of 96
generate
for (ihit=0; ihit<48; ihit=ihit+1) begin: s4
  //assign {vpf_s4[ihit], key_s4[ihit]} = vpf_s3[ihit*2+1] ?  {vpf_s3[ihit*2+1], {1'b1,key_s3[ihit*2+1]}}: {vpf_s3[ihit*2  ], {1'b0,key_s3[ihit*2  ]}};
  //assign {vpf_s4[ihit], key_s4[ihit]} = vpf_s3[ihit*2] ?   {vpf_s3[ihit*2  ], {1'b0,key_s3[ihit*2  ]}} : {vpf_s3[ihit*2+1], {1'b1,key_s3[ihit*2+1]}};
  assign   {vpf_s4[ihit], cnt_s4[ihit], key_s4[ihit]} = vpf_s3[ihit*2] ?  {vpf_s3[ihit*2  ], cnt_s3[ihit*2], {1'b0,key_s3[ihit*2  ]}} : {vpf_s3[ihit*2+1], cnt_s3[ihit*2+1], {1'b1,key_s3[ihit*2+1]}} ;
end
endgenerate

// stage 5: best 24 of 48
generate
for (ihit=0; ihit<24; ihit=ihit+1) begin: s5
  //assign {vpf_s5[ihit], key_s5[ihit]} = vpf_s4[ihit*2+1]  ?  {vpf_s4[ihit*2+1], {1'b1,key_s4[ihit*2+1]}}: {vpf_s4[ihit*2  ], {1'b0,key_s4[ihit*2  ]}};
  //assign {vpf_s5[ihit], key_s5[ihit]} = vpf_s4[ihit*2]  ?   {vpf_s4[ihit*2  ], {1'b0,key_s4[ihit*2  ]}} : {vpf_s4[ihit*2+1], {1'b1,key_s4[ihit*2+1]}};
  //always @(posedge clock) {vpf_s5[ihit], cnt_s5[ihit], key_s5[ihit]} = vpf_s4[ihit*2] ?  {vpf_s4[ihit*2  ], cnt_s4[ihit*2], {1'b0,key_s4[ihit*2  ]}} : {vpf_s4[ihit*2+1], cnt_s4[ihit*2+1], {1'b1,key_s4[ihit*2+1]}} ;
  assign {vpf_s5[ihit], cnt_s5[ihit], key_s5[ihit]} = vpf_s4[ihit*2] ?  {vpf_s4[ihit*2  ], cnt_s4[ihit*2], {1'b0,key_s4[ihit*2  ]}} : {vpf_s4[ihit*2+1], cnt_s4[ihit*2+1], {1'b1,key_s4[ihit*2+1]}} ;
end
endgenerate

// stage 6: best 12 of 24
generate
for (ihit=0; ihit<12; ihit=ihit+1) begin: s6
  //assign {vpf_s6[ihit], key_s6[ihit]} = vpf_s5[ihit*2+1]  ?  {vpf_s5[ihit*2+1], {1'b1,key_s5[ihit*2+1]}}: {vpf_s5[ihit*2  ], {1'b0,key_s5[ihit*2  ]}};
  //assign {vpf_s6[ihit], key_s6[ihit]} = vpf_s5[ihit*2]  ?   {vpf_s5[ihit*2  ], {1'b0,key_s5[ihit*2  ]}} : {vpf_s5[ihit*2+1], {1'b1,key_s5[ihit*2+1]}};
  assign   {vpf_s6[ihit], cnt_s6[ihit], key_s6[ihit]} = vpf_s5[ihit*2] ?  {vpf_s5[ihit*2  ], cnt_s5[ihit*2], {1'b0,key_s5[ihit*2  ]}} : {vpf_s5[ihit*2+1], cnt_s5[ihit*2+1], {1'b1,key_s5[ihit*2+1]}} ;
end
endgenerate

// stage 7: best 6 of 12
generate
for (ihit=0; ihit<6; ihit=ihit+1) begin: s7
  //assign {vpf_s7[ihit], key_s7[ihit]} = vpf_s6[ihit*2+1]  ?  {vpf_s6[ihit*2+1], {1'b1,key_s6[ihit*2+1]}}: {vpf_s6[ihit*2  ], {1'b0,key_s6[ihit*2  ]}};
  //assign {vpf_s7[ihit], key_s7[ihit]} = vpf_s6[ihit*2]  ?   {vpf_s6[ihit*2  ], {1'b0,key_s6[ihit*2  ]}} : {vpf_s6[ihit*2+1], {1'b1,key_s6[ihit*2+1]}};
  assign   {vpf_s7[ihit], cnt_s7[ihit], key_s7[ihit]} = vpf_s6[ihit*2] ?  {vpf_s6[ihit*2  ], cnt_s6[ihit*2], {1'b0,key_s6[ihit*2  ]}} : {vpf_s6[ihit*2+1], cnt_s6[ihit*2+1], {1'b1,key_s6[ihit*2+1]}} ;
end
endgenerate

// stage 8: best 3 of 6
generate
for (ihit=0; ihit<3; ihit=ihit+1) begin: s8
  //assign {vpf_s8[ihit], key_s8[ihit]} = vpf_s7[ihit*2+1]  ?  {vpf_s7[ihit*2+1], {1'b1,key_s7[ihit*2+1]}}: {vpf_s7[ihit*2  ], {1'b0,key_s7[ihit*2  ]}};
  //assign {vpf_s8[ihit], key_s8[ihit]} = vpf_s7[ihit*2]  ?   {vpf_s7[ihit*2  ], {1'b0,key_s7[ihit*2  ]}} : {vpf_s7[ihit*2+1], {1'b1,key_s7[ihit*2+1]}};
  assign   {vpf_s8[ihit], cnt_s8[ihit], key_s8[ihit]} = vpf_s7[ihit*2] ?  {vpf_s7[ihit*2  ], cnt_s7[ihit*2], {1'b0,key_s7[ihit*2  ]}} : {vpf_s7[ihit*2+1], cnt_s7[ihit*2+1], {1'b1,key_s7[ihit*2+1]}} ;
//  always@(posedge clock) {vpf_s8[ihit], key_s8[ihit]} <= vpf_s7[ihit*2]  ?   {vpf_s7[ihit*2  ], {1'b0,key_s7[ihit*2  ]}} : {vpf_s7[ihit*2+1], {1'b1,key_s7[ihit*2+1]}};
end
endgenerate

// Stage 6: Best 1 of 3 Parallel Encoder
always @(*) begin
  //if      (vpf_s8[2]) key_s9[0] = {2'b10, key_s8[2]};
  //else if (vpf_s8[1]) key_s9[0] = {2'b01, key_s8[1]};
  //else                key_s9[0] = {2'b00, key_s8[0]};
  if      (vpf_s8[0]) {vpf_s9[0], cnt_s9[0], key_s9[0]} = {vpf_s8[0], cnt_s8[0], {2'b00, key_s8[0]}};
  else if (vpf_s8[1]) {vpf_s9[0], cnt_s9[0], key_s9[0]} = {vpf_s8[1], cnt_s8[1], {2'b01, key_s8[1]}};
  else                {vpf_s9[0], cnt_s9[0], key_s9[0]} = {vpf_s8[2], cnt_s8[2], {2'b10, key_s8[2]}};
end

//reg[10:0] adr_ff;
//always @(posedge clock)
//  adr_ff <= key_s9[0];
//assign adr = adr_ff;
//assign adr = (vpf_s9) ? adr_ff[0] : 11'h7FE;
//assign adr = key_s9[0];

assign adr = (vpf_s9[0]) ? key_s9[0] : 11'h7FE;
assign cnt = cnt_s9[0];

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
