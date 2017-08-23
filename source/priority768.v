//`define debug_priority1536
`timescale 1ns / 100 ps

module priority768 (

  input clock,

  input frame_clock,

  input  [2:0] pass_in,
  output [2:0] pass_out,

  input   [768  -1:0] vpfs_in,
  input   [768*3-1:0] cnts_in,

  output cluster_found,

  output  [10:0] adr,
  output   [2:0] cnt
);

  (* KEEP = "TRUE" *)
  reg [7:0] clock_sampled = 0;
  always @(posedge clock)
    clock_sampled [7:0] <= {clock_sampled[6:0],frame_clock};

  // sorry for the magic number;
  // we are sampling the value of the slow frame clock on our fast 160 MHz clock, looking to latch the inputs at the
  // appropriate time based on looking for a rising edge of the latch clock
  // there are 8 160MHz clocks per 20MHz clock (hence the 8-bit number for the clock-sampled shift register)
  // it should be clear if you draw a timing diagram.. but imagine in two clock cycles clock sampled will be
  // 11110000 which means the next clock will be at the rising edge..

  wire latch_on_next = (clock_sampled == 8'b00111100);

  reg latch_en=0;
  always @(posedge clock)
    latch_en <= latch_on_next;

parameter MXPADS = 768;

//----------------------------------------------------------------------------------------------------------------------
// Input registers and delays
//----------------------------------------------------------------------------------------------------------------------

  reg   [768-1:0] vpfs;
  reg   [2:0] cnts_latch [768-1:0];
  reg   [2:0] cnts       [768-1:0];

  genvar ipad;
  generate
  for (ipad=0; ipad<768; ipad=ipad+1) begin: padloop
    always @(posedge clock) begin
      if (latch_en)
        cnts_latch [ipad] <= cnts_in [ipad*3+2:ipad*3];
    end

    always @(posedge clock)
      cnts[ipad] <= cnts_latch[ipad];
  end
  endgenerate

  always @(posedge clock)
    vpfs <= vpfs_in;

  // Shadow copy of pass counter

  reg [2:0] pass;
  always @(posedge clock)
    pass <= pass_in;


//----------------------------------------------------------------------------------------------------------------------
// Parameters and Interconnects
//----------------------------------------------------------------------------------------------------------------------

  parameter MXKEYS    = 768;
  parameter MXKEYBITS = 10;

  wire [2:0] pass_s0;
  wire [2:0] pass_s1;
  wire [2:0] pass_s2;
  reg  [2:0] pass_s3;
  wire [2:0] pass_s4;
  wire [2:0] pass_s5;
  wire [2:0] pass_s6;
  wire [2:0] pass_s7;
  reg  [2:0] pass_s8;

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

  assign pass_s0 = pass;

  // Stage 1: 192 of 384
  generate
  for (ihit=0; ihit<192; ihit=ihit+1) begin: s1
    assign {vpf_s1[ihit], cnt_s1[ihit], key_s1[ihit]} = vpf_s0[ihit*2] ?  {vpf_s0[ihit*2  ], cnt_s0[ihit*2], {1'b0,key_s0[ihit*2  ]}} : {vpf_s0[ihit*2+1], cnt_s0[ihit*2+1], {1'b1,key_s0[ihit*2+1]}};
  end
  endgenerate

  assign pass_s1 = pass_s0;

  // Stage 2: 96 of 192
  generate
  for (ihit=0; ihit<96; ihit=ihit+1) begin: s2
    assign {vpf_s2[ihit], cnt_s2[ihit], key_s2[ihit]} = vpf_s1[ihit*2] ?  {vpf_s1[ihit*2  ], cnt_s1[ihit*2], {1'b0,key_s1[ihit*2  ]}} : {vpf_s1[ihit*2+1], cnt_s1[ihit*2+1], {1'b1,key_s1[ihit*2+1]}} ;
  end
  endgenerate

  assign pass_s2 = pass_s1;

  // Stage 3: 48 of 96
  generate
  for (ihit=0; ihit<48; ihit=ihit+1) begin: s3
    always @(posedge clock)
    {vpf_s3[ihit], cnt_s3[ihit], key_s3[ihit]} <= vpf_s2[ihit*2] ?  {vpf_s2[ihit*2  ], cnt_s2[ihit*2], {1'b0,key_s2[ihit*2  ]}} : {vpf_s2[ihit*2+1], cnt_s2[ihit*2+1], {1'b1,key_s2[ihit*2+1]}} ;
  end
  endgenerate

  always @(posedge clock)
    pass_s3 <= pass_s2;

  // Stage 4: 24 of 48
  generate
  for (ihit=0; ihit<24; ihit=ihit+1) begin: s4
    assign {vpf_s4[ihit], cnt_s4[ihit], key_s4[ihit]} = vpf_s3[ihit*2] ?  {vpf_s3[ihit*2  ], cnt_s3[ihit*2], {1'b0,key_s3[ihit*2  ]}} : {vpf_s3[ihit*2+1], cnt_s3[ihit*2+1], {1'b1,key_s3[ihit*2+1]}} ;
  end
  endgenerate

  assign pass_s4 = pass_s3;

  // stage 5: 12 of 24
  generate
  for (ihit=0; ihit<12; ihit=ihit+1) begin: s5
    assign {vpf_s5[ihit], cnt_s5[ihit], key_s5[ihit]} = vpf_s4[ihit*2] ?  {vpf_s4[ihit*2  ], cnt_s4[ihit*2], {1'b0,key_s4[ihit*2  ]}} : {vpf_s4[ihit*2+1], cnt_s4[ihit*2+1], {1'b1,key_s4[ihit*2+1]}} ;
  end
  endgenerate

  assign pass_s5 = pass_s4;

  // stage 6: 6 of 12
  generate
  for (ihit=0; ihit<6; ihit=ihit+1) begin: s6
    assign   {vpf_s6[ihit], cnt_s6[ihit], key_s6[ihit]} = vpf_s5[ihit*2] ?  {vpf_s5[ihit*2  ], cnt_s5[ihit*2], {1'b0,key_s5[ihit*2  ]}} : {vpf_s5[ihit*2+1], cnt_s5[ihit*2+1], {1'b1,key_s5[ihit*2+1]}} ;
  end
  endgenerate

  assign pass_s6 = pass_s5;

  // stage 7: 3 of 6
  generate
  for (ihit=0; ihit<3; ihit=ihit+1) begin: s7
    assign {vpf_s7[ihit], cnt_s7[ihit], key_s7[ihit]} = vpf_s6[ihit*2] ?  {vpf_s6[ihit*2  ], cnt_s6[ihit*2], {1'b0,key_s6[ihit*2  ]}} : {vpf_s6[ihit*2+1], cnt_s6[ihit*2+1], {1'b1,key_s6[ihit*2+1]}} ;
  end
  endgenerate

  assign pass_s7 = pass_s6;

  // Stage 6: 1 of 3 Parallel Encoder
  always @(posedge clock) begin
    if      (vpf_s7[0]) {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[0], cnt_s7[0], {2'b00, key_s7[0]}};
    else if (vpf_s7[1]) {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[1], cnt_s7[1], {2'b01, key_s7[1]}};
    else                {vpf_s8[0], cnt_s8[0], key_s8[0]} = {vpf_s7[2], cnt_s7[2], {2'b10, key_s7[2]}};

    pass_s8 = pass_s7;

  end


  assign adr           = {11{~cluster_found}} | key_s8[0];
  assign cluster_found =                        vpf_s8[0];
  assign cnt           = {3{cluster_found}}   & cnt_s8[0];
  assign pass_out      = pass_s7;

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
