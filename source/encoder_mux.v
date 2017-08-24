//----------------------------------------------------------------------------------------------------------------------
// encoder_mux.v
//
// The cluster_packer is based around two priority encoding modules
// (first8of1536). One encoder handles the S-bits received at "even" bunch
// crossings, while the other handles S-bits received at the "odd" bunch
// crossing.
//
// This module and submodule is only based on a 160 MHz clock, so it is essentially blind to the 40MHz system clock!
//----------------------------------------------------------------------------------------------------------------------

module encoder_mux (

  input frame_clock,

  input clock4x,

  input  [1536-1:0]    vpfs_in,

  input  [1536*3-1:0]  cnts_in,

  output [2:0] cnt0,
  output [2:0] cnt1,
  output [2:0] cnt2,
  output [2:0] cnt3,
  output [2:0] cnt4,
  output [2:0] cnt5,
  output [2:0] cnt6,
  output [2:0] cnt7,

  output [10:0] adr0,
  output [10:0] adr1,
  output [10:0] adr2,
  output [10:0] adr3,
  output [10:0] adr4,
  output [10:0] adr5,
  output [10:0] adr6,
  output [10:0] adr7
);

//----------------------------------------------------------------------------------------------------------------------
// latch_enable
//----------------------------------------------------------------------------------------------------------------------

  wire [10:0] encoder_adr0  [1:0];
  wire [10:0] encoder_adr1  [1:0];
  wire [10:0] encoder_adr2  [1:0];
  wire [10:0] encoder_adr3  [1:0];
  wire [10:0] encoder_adr4  [1:0];
  wire [10:0] encoder_adr5  [1:0];
  wire [10:0] encoder_adr6  [1:0];
  wire [10:0] encoder_adr7  [1:0];
  wire [10:0] encoder_adr8  [1:0];
  wire [10:0] encoder_adr9  [1:0];
  wire [10:0] encoder_adr10 [1:0];
  wire [10:0] encoder_adr11 [1:0];
  wire [10:0] encoder_adr12 [1:0];
  wire [10:0] encoder_adr13 [1:0];
  wire [10:0] encoder_adr14 [1:0];
  wire [10:0] encoder_adr15 [1:0];

  wire  [2:0] encoder_cnt0  [1:0];
  wire  [2:0] encoder_cnt1  [1:0];
  wire  [2:0] encoder_cnt2  [1:0];
  wire  [2:0] encoder_cnt3  [1:0];
  wire  [2:0] encoder_cnt4  [1:0];
  wire  [2:0] encoder_cnt5  [1:0];
  wire  [2:0] encoder_cnt6  [1:0];
  wire  [2:0] encoder_cnt7  [1:0];
  wire  [2:0] encoder_cnt8  [1:0];
  wire  [2:0] encoder_cnt9  [1:0];
  wire  [2:0] encoder_cnt10 [1:0];
  wire  [2:0] encoder_cnt11 [1:0];
  wire  [2:0] encoder_cnt12 [1:0];
  wire  [2:0] encoder_cnt13 [1:0];
  wire  [2:0] encoder_cnt14 [1:0];
  wire  [2:0] encoder_cnt15 [1:0];

  wire  [2:0] encoder_pass [1:0];

  wire [10:0] adr_muxed  [15:0];
  wire  [2:0] cnt_muxed  [15:0];
  wire  [2:0] pass_muxed;

  // multiplex cluster outputs from the two priority encoder modules

  wire [1:0] fclk;
  assign fclk[0] =  frame_clock;
  assign fclk[1] = ~frame_clock;

  // create stable latches on the slow clock to pass to alternating encoders
  reg  [1536-1:0]    vpfs [1:0];
  reg  [1536*3-1:0]  cnts [1:0];
  genvar iencoder;
  generate
  for (iencoder=0; iencoder<2; iencoder=iencoder+1) begin: encloop

    always @(posedge fclk[iencoder]) begin
      vpfs[iencoder] <= vpfs_in;
      cnts[iencoder] <= cnts_in;
    end

    first8of1536 u_first8 (
        .clock4x(clock4x),
        .vpfs_in (vpfs_in),
        .cnts_in (cnts_in),

        .frame_clock (fclk[iencoder]),

        .adr0  (encoder_adr0 [iencoder]),
        .adr1  (encoder_adr1 [iencoder]),
        .adr2  (encoder_adr2 [iencoder]),
        .adr3  (encoder_adr3 [iencoder]),
        .adr4  (encoder_adr4 [iencoder]),
        .adr5  (encoder_adr5 [iencoder]),
        .adr6  (encoder_adr6 [iencoder]),
        .adr7  (encoder_adr7 [iencoder]),
        .adr8  (encoder_adr8 [iencoder]),
        .adr9  (encoder_adr9 [iencoder]),
        .adr10 (encoder_adr10[iencoder]),
        .adr11 (encoder_adr11[iencoder]),
        .adr12 (encoder_adr12[iencoder]),
        .adr13 (encoder_adr13[iencoder]),
        .adr14 (encoder_adr14[iencoder]),
        .adr15 (encoder_adr15[iencoder]),

        .cnt0  (encoder_cnt0 [iencoder]),
        .cnt1  (encoder_cnt1 [iencoder]),
        .cnt2  (encoder_cnt2 [iencoder]),
        .cnt3  (encoder_cnt3 [iencoder]),
        .cnt4  (encoder_cnt4 [iencoder]),
        .cnt5  (encoder_cnt5 [iencoder]),
        .cnt6  (encoder_cnt6 [iencoder]),
        .cnt7  (encoder_cnt7 [iencoder]),
        .cnt8  (encoder_cnt8 [iencoder]),
        .cnt9  (encoder_cnt9 [iencoder]),
        .cnt10 (encoder_cnt10[iencoder]),
        .cnt11 (encoder_cnt11[iencoder]),
        .cnt12 (encoder_cnt12[iencoder]),
        .cnt13 (encoder_cnt13[iencoder]),
        .cnt14 (encoder_cnt14[iencoder]),
        .cnt15 (encoder_cnt15[iencoder]),

        .pass  (encoder_pass[iencoder])

    );
    end
  endgenerate

  reg mux_sel=0;
  always @(posedge clock4x) begin

    // use 6 because there is a 1 clock delay in flopping this, so we lookahead by 1 clock
    if (encoder_pass[0]==6)
      mux_sel<=0;
    else if (encoder_pass[1]==6)
      mux_sel<=1;
    else
      mux_sel<=mux_sel;

  end

  assign pass_muxed    = mux_sel ? (encoder_pass[0])  : (encoder_pass[1]);

  assign cnt_muxed[0]  = mux_sel ? (encoder_cnt0[0])  : (encoder_cnt0[1]);
  assign cnt_muxed[1]  = mux_sel ? (encoder_cnt1[0])  : (encoder_cnt1[1]);
  assign cnt_muxed[2]  = mux_sel ? (encoder_cnt2[0])  : (encoder_cnt2[1]);
  assign cnt_muxed[3]  = mux_sel ? (encoder_cnt3[0])  : (encoder_cnt3[1]);
  assign cnt_muxed[4]  = mux_sel ? (encoder_cnt4[0])  : (encoder_cnt4[1]);
  assign cnt_muxed[5]  = mux_sel ? (encoder_cnt5[0])  : (encoder_cnt5[1]);
  assign cnt_muxed[6]  = mux_sel ? (encoder_cnt6[0])  : (encoder_cnt6[1]);
  assign cnt_muxed[7]  = mux_sel ? (encoder_cnt7[0])  : (encoder_cnt7[1]);
  assign cnt_muxed[8]  = mux_sel ? (encoder_cnt8[0])  : (encoder_cnt8[1]);
  assign cnt_muxed[9]  = mux_sel ? (encoder_cnt9[0])  : (encoder_cnt9[1]);
  assign cnt_muxed[10] = mux_sel ? (encoder_cnt10[0]) : (encoder_cnt10[1]);
  assign cnt_muxed[11] = mux_sel ? (encoder_cnt11[0]) : (encoder_cnt11[1]);
  assign cnt_muxed[12] = mux_sel ? (encoder_cnt12[0]) : (encoder_cnt12[1]);
  assign cnt_muxed[13] = mux_sel ? (encoder_cnt13[0]) : (encoder_cnt13[1]);
  assign cnt_muxed[14] = mux_sel ? (encoder_cnt14[0]) : (encoder_cnt14[1]);
  assign cnt_muxed[15] = mux_sel ? (encoder_cnt15[0]) : (encoder_cnt15[1]);

  assign adr_muxed[0]  = mux_sel ? (encoder_adr0[0])  : (encoder_adr0[1]);
  assign adr_muxed[1]  = mux_sel ? (encoder_adr1[0])  : (encoder_adr1[1]);
  assign adr_muxed[2]  = mux_sel ? (encoder_adr2[0])  : (encoder_adr2[1]);
  assign adr_muxed[3]  = mux_sel ? (encoder_adr3[0])  : (encoder_adr3[1]);
  assign adr_muxed[4]  = mux_sel ? (encoder_adr4[0])  : (encoder_adr4[1]);
  assign adr_muxed[5]  = mux_sel ? (encoder_adr5[0])  : (encoder_adr5[1]);
  assign adr_muxed[6]  = mux_sel ? (encoder_adr6[0])  : (encoder_adr6[1]);
  assign adr_muxed[7]  = mux_sel ? (encoder_adr7[0])  : (encoder_adr7[1]);
  assign adr_muxed[8]  = mux_sel ? (encoder_adr8[0])  : (encoder_adr8[1]);
  assign adr_muxed[9]  = mux_sel ? (encoder_adr9[0])  : (encoder_adr9[1]);
  assign adr_muxed[10] = mux_sel ? (encoder_adr10[0]) : (encoder_adr10[1]);
  assign adr_muxed[11] = mux_sel ? (encoder_adr11[0]) : (encoder_adr11[1]);
  assign adr_muxed[12] = mux_sel ? (encoder_adr12[0]) : (encoder_adr12[1]);
  assign adr_muxed[13] = mux_sel ? (encoder_adr13[0]) : (encoder_adr13[1]);
  assign adr_muxed[14] = mux_sel ? (encoder_adr14[0]) : (encoder_adr14[1]);
  assign adr_muxed[15] = mux_sel ? (encoder_adr15[0]) : (encoder_adr15[1]);

  assign cnt_muxed[0]  = mux_sel ? (encoder_cnt0[0])  : (encoder_cnt0[1]);
  assign cnt_muxed[1]  = mux_sel ? (encoder_cnt1[0])  : (encoder_cnt1[1]);
  assign cnt_muxed[2]  = mux_sel ? (encoder_cnt2[0])  : (encoder_cnt2[1]);
  assign cnt_muxed[3]  = mux_sel ? (encoder_cnt3[0])  : (encoder_cnt3[1]);
  assign cnt_muxed[4]  = mux_sel ? (encoder_cnt4[0])  : (encoder_cnt4[1]);
  assign cnt_muxed[5]  = mux_sel ? (encoder_cnt5[0])  : (encoder_cnt5[1]);
  assign cnt_muxed[6]  = mux_sel ? (encoder_cnt6[0])  : (encoder_cnt6[1]);
  assign cnt_muxed[7]  = mux_sel ? (encoder_cnt7[0])  : (encoder_cnt7[1]);
  assign cnt_muxed[8]  = mux_sel ? (encoder_cnt8[0])  : (encoder_cnt8[1]);
  assign cnt_muxed[9]  = mux_sel ? (encoder_cnt9[0])  : (encoder_cnt9[1]);
  assign cnt_muxed[10] = mux_sel ? (encoder_cnt10[0]) : (encoder_cnt10[1]);
  assign cnt_muxed[11] = mux_sel ? (encoder_cnt11[0]) : (encoder_cnt11[1]);
  assign cnt_muxed[12] = mux_sel ? (encoder_cnt12[0]) : (encoder_cnt12[1]);
  assign cnt_muxed[13] = mux_sel ? (encoder_cnt13[0]) : (encoder_cnt13[1]);
  assign cnt_muxed[14] = mux_sel ? (encoder_cnt14[0]) : (encoder_cnt14[1]);
  assign cnt_muxed[15] = mux_sel ? (encoder_cnt15[0]) : (encoder_cnt15[1]);

  assign adr_muxed[0]  = mux_sel ? (encoder_adr0[0])  : (encoder_adr0[1]);
  assign adr_muxed[1]  = mux_sel ? (encoder_adr1[0])  : (encoder_adr1[1]);
  assign adr_muxed[2]  = mux_sel ? (encoder_adr2[0])  : (encoder_adr2[1]);
  assign adr_muxed[3]  = mux_sel ? (encoder_adr3[0])  : (encoder_adr3[1]);
  assign adr_muxed[4]  = mux_sel ? (encoder_adr4[0])  : (encoder_adr4[1]);
  assign adr_muxed[5]  = mux_sel ? (encoder_adr5[0])  : (encoder_adr5[1]);
  assign adr_muxed[6]  = mux_sel ? (encoder_adr6[0])  : (encoder_adr6[1]);
  assign adr_muxed[7]  = mux_sel ? (encoder_adr7[0])  : (encoder_adr7[1]);
  assign adr_muxed[8]  = mux_sel ? (encoder_adr8[0])  : (encoder_adr8[1]);
  assign adr_muxed[9]  = mux_sel ? (encoder_adr9[0])  : (encoder_adr9[1]);
  assign adr_muxed[10] = mux_sel ? (encoder_adr10[0]) : (encoder_adr10[1]);
  assign adr_muxed[11] = mux_sel ? (encoder_adr11[0]) : (encoder_adr11[1]);
  assign adr_muxed[12] = mux_sel ? (encoder_adr12[0]) : (encoder_adr12[1]);
  assign adr_muxed[13] = mux_sel ? (encoder_adr13[0]) : (encoder_adr13[1]);
  assign adr_muxed[14] = mux_sel ? (encoder_adr14[0]) : (encoder_adr14[1]);
  assign adr_muxed[15] = mux_sel ? (encoder_adr15[0]) : (encoder_adr15[1]);

  wire [2:0] pass_merger;

  merge16 u_merge16 (

      .clock4x(clock4x),

      .pass_in  (pass_muxed),
      .pass_out (pass_merger),

      .adr_in0  ( adr_muxed[0]),
      .adr_in1  ( adr_muxed[1]),
      .adr_in2  ( adr_muxed[2]),
      .adr_in3  ( adr_muxed[3]),
      .adr_in4  ( adr_muxed[4]),
      .adr_in5  ( adr_muxed[5]),
      .adr_in6  ( adr_muxed[6]),
      .adr_in7  ( adr_muxed[7]),
      .adr_in8  ( adr_muxed[8]),
      .adr_in9  ( adr_muxed[9]),
      .adr_in10 ( adr_muxed[10]),
      .adr_in11 ( adr_muxed[11]),
      .adr_in12 ( adr_muxed[12]),
      .adr_in13 ( adr_muxed[13]),
      .adr_in14 ( adr_muxed[14]),
      .adr_in15 ( adr_muxed[15]),

      .cnt_in0  ( cnt_muxed[0]),
      .cnt_in1  ( cnt_muxed[1]),
      .cnt_in2  ( cnt_muxed[2]),
      .cnt_in3  ( cnt_muxed[3]),
      .cnt_in4  ( cnt_muxed[4]),
      .cnt_in5  ( cnt_muxed[5]),
      .cnt_in6  ( cnt_muxed[6]),
      .cnt_in7  ( cnt_muxed[7]),
      .cnt_in8  ( cnt_muxed[8]),
      .cnt_in9  ( cnt_muxed[9]),
      .cnt_in10 ( cnt_muxed[10]),
      .cnt_in11 ( cnt_muxed[11]),
      .cnt_in12 ( cnt_muxed[12]),
      .cnt_in13 ( cnt_muxed[13]),
      .cnt_in14 ( cnt_muxed[14]),
      .cnt_in15 ( cnt_muxed[15]),


      .adr0_o(adr0),
      .adr1_o(adr1),
      .adr2_o(adr2),
      .adr3_o(adr3),
      .adr4_o(adr4),
      .adr5_o(adr5),
      .adr6_o(adr6),
      .adr7_o(adr7),

      .cnt0_o(cnt0),
      .cnt1_o(cnt1),
      .cnt2_o(cnt2),
      .cnt3_o(cnt3),
      .cnt4_o(cnt4),
      .cnt5_o(cnt5),
      .cnt6_o(cnt6),
      .cnt7_o(cnt7)
  );

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
