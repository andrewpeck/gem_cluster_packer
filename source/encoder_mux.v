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

  input clock4x,
  input global_reset,

  input  [1536-1:0]    vpfs_in,

  input  [1536*3-1:0]  cnts_in,

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


//----------------------------------------------------------------------------------------------------------------------
// latch_enable
//----------------------------------------------------------------------------------------------------------------------

reg [2:0] phase=3'd0;
reg latch=0;
always @(posedge clock4x) begin
  phase <= (global_reset) ? 1'b0 : phase+1'b1;
  latch <= (phase==3'd0);
end

parameter [3:0] mux_sel_delay=3;
(* max_fanout = 100 *) reg mux_sel;
SRL16E u_mux_seldly (.CLK(clock4x),.CE(1'b1),.D(phase[2]),.A0(mux_sel_delay[0]),.A1(mux_sel_delay[1]),.A2(mux_sel_delay[2]),.A3(mux_sel_delay[3]),.Q(mux_sel_dly));
always @(posedge clock4x) mux_sel <= (mux_sel_dly);

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

// multiplex cluster outputs from the two priority encoder modules
assign {cnt0,adr0} = mux_sel ? {vec_cnt0[0], vec_adr0[0]} : {vec_cnt0[1], vec_adr0[1]}; // {vec_cnt0[0], vec_adr0[0]}]};
assign {cnt1,adr1} = mux_sel ? {vec_cnt1[0], vec_adr1[0]} : {vec_cnt1[1], vec_adr1[1]}; // {vec_cnt1[0], vec_adr1[0]}]};
assign {cnt2,adr2} = mux_sel ? {vec_cnt2[0], vec_adr2[0]} : {vec_cnt2[1], vec_adr2[1]}; // {vec_cnt2[0], vec_adr2[0]}]};
assign {cnt3,adr3} = mux_sel ? {vec_cnt3[0], vec_adr3[0]} : {vec_cnt3[1], vec_adr3[1]}; // {vec_cnt3[0], vec_adr3[0]}]};
assign {cnt4,adr4} = mux_sel ? {vec_cnt4[0], vec_adr4[0]} : {vec_cnt4[1], vec_adr4[1]}; // {vec_cnt4[0], vec_adr4[0]}]};
assign {cnt5,adr5} = mux_sel ? {vec_cnt5[0], vec_adr5[0]} : {vec_cnt5[1], vec_adr5[1]}; // {vec_cnt5[0], vec_adr5[0]}]};
assign {cnt6,adr6} = mux_sel ? {vec_cnt6[0], vec_adr6[0]} : {vec_cnt6[1], vec_adr6[1]}; // {vec_cnt6[0], vec_adr6[0]}]};
assign {cnt7,adr7} = mux_sel ? {vec_cnt7[0], vec_adr7[0]} : {vec_cnt7[1], vec_adr7[1]}; // {vec_cnt7[0], vec_adr7[0]}]};

genvar iencoder;
generate
for (iencoder=0; iencoder<2; iencoder=iencoder+1) begin: encloop
first8of1536 u_first8_a (
    .global_reset(global_reset),
    .clock4x(clock4x),
    .vpfs_in (vpfs_in),
    .cnts_in (cnts_in),
    .latch_in (latch),
    .latch_delay(iencoder*4'd4),

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
