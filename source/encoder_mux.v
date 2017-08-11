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

  wire [10:0] vec_adr0 [1:0];
  wire [10:0] vec_adr1 [1:0];
  wire [10:0] vec_adr2 [1:0];
  wire [10:0] vec_adr3 [1:0];
  wire [10:0] vec_adr4 [1:0];
  wire [10:0] vec_adr5 [1:0];
  wire [10:0] vec_adr6 [1:0];
  wire [10:0] vec_adr7 [1:0];

  wire  [2:0] vec_cnt0 [1:0];
  wire  [2:0] vec_cnt1 [1:0];
  wire  [2:0] vec_cnt2 [1:0];
  wire  [2:0] vec_cnt3 [1:0];
  wire  [2:0] vec_cnt4 [1:0];
  wire  [2:0] vec_cnt5 [1:0];
  wire  [2:0] vec_cnt6 [1:0];
  wire  [2:0] vec_cnt7 [1:0];

  reg mux_sel = 0;
  always @(posedge frame_clock)
    mux_sel <= !mux_sel;

  // multiplex cluster outputs from the two priority encoder modules

   reg clock_sampled = 0;
   always @(posedge clock4x)
     clock_sampled <= frame_clock;

   parameter [3:0] adr = 4'd6;

   SRL16E clkdly (
     .CE  (1'b1),
     .CLK (clock4x),
     .D   (clock_sampled),
     .Q   (clock_sampled_dly),
     .A0  (adr[0]),
     .A1  (adr[1]),
     .A2  (adr[2]),
     .A3  (adr[3])
   );

  reg clock_lac = 0;
  always @(posedge clock4x)
    clock_lac <= clock_sampled_dly;

  assign {cnt0,adr0} = clock_lac ? {vec_cnt0[0], vec_adr0[0]} : {vec_cnt0[1], vec_adr0[1]}; // {vec_cnt0[0], vec_adr0[0]}]};
  assign {cnt1,adr1} = clock_lac ? {vec_cnt1[0], vec_adr1[0]} : {vec_cnt1[1], vec_adr1[1]}; // {vec_cnt1[0], vec_adr1[0]}]};
  assign {cnt2,adr2} = clock_lac ? {vec_cnt2[0], vec_adr2[0]} : {vec_cnt2[1], vec_adr2[1]}; // {vec_cnt2[0], vec_adr2[0]}]};
  assign {cnt3,adr3} = clock_lac ? {vec_cnt3[0], vec_adr3[0]} : {vec_cnt3[1], vec_adr3[1]}; // {vec_cnt3[0], vec_adr3[0]}]};
  assign {cnt4,adr4} = clock_lac ? {vec_cnt4[0], vec_adr4[0]} : {vec_cnt4[1], vec_adr4[1]}; // {vec_cnt4[0], vec_adr4[0]}]};
  assign {cnt5,adr5} = clock_lac ? {vec_cnt5[0], vec_adr5[0]} : {vec_cnt5[1], vec_adr5[1]}; // {vec_cnt5[0], vec_adr5[0]}]};
  assign {cnt6,adr6} = clock_lac ? {vec_cnt6[0], vec_adr6[0]} : {vec_cnt6[1], vec_adr6[1]}; // {vec_cnt6[0], vec_adr6[0]}]};
  assign {cnt7,adr7} = clock_lac ? {vec_cnt7[0], vec_adr7[0]} : {vec_cnt7[1], vec_adr7[1]}; // {vec_cnt7[0], vec_adr7[0]}]};


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

        .adr0(vec_adr0[iencoder]),
        .adr1(vec_adr1[iencoder]),
        .adr2(vec_adr2[iencoder]),
        .adr3(vec_adr3[iencoder]),
        .adr4(vec_adr4[iencoder]),
        .adr5(vec_adr5[iencoder]),
        .adr6(vec_adr6[iencoder]),
        .adr7(vec_adr7[iencoder]),

        .cnt0(vec_cnt0[iencoder]),
        .cnt1(vec_cnt1[iencoder]),
        .cnt2(vec_cnt2[iencoder]),
        .cnt3(vec_cnt3[iencoder]),
        .cnt4(vec_cnt4[iencoder]),
        .cnt5(vec_cnt5[iencoder]),
        .cnt6(vec_cnt6[iencoder]),
        .cnt7(vec_cnt7[iencoder])
    );
    end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
