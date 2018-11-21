module merge16_light (
  input clock4x,

  input      mux_pulse_in,
  output reg mux_pulse_out,

  input [MXADRBITS-1:0] adr_in0,
  input [MXADRBITS-1:0] adr_in1,
  input [MXADRBITS-1:0] adr_in2,
  input [MXADRBITS-1:0] adr_in3,
  input [MXADRBITS-1:0] adr_in4,
  input [MXADRBITS-1:0] adr_in5,
  input [MXADRBITS-1:0] adr_in6,
  input [MXADRBITS-1:0] adr_in7,
  input [MXADRBITS-1:0] adr_in8,
  input [MXADRBITS-1:0] adr_in9,
  input [MXADRBITS-1:0] adr_in10,
  input [MXADRBITS-1:0] adr_in11,
  input [MXADRBITS-1:0] adr_in12,
  input [MXADRBITS-1:0] adr_in13,
  input [MXADRBITS-1:0] adr_in14,
  input [MXADRBITS-1:0] adr_in15,

  input [MXCNTBITS-1:0] cnt_in0,
  input [MXCNTBITS-1:0] cnt_in1,
  input [MXCNTBITS-1:0] cnt_in2,
  input [MXCNTBITS-1:0] cnt_in3,
  input [MXCNTBITS-1:0] cnt_in4,
  input [MXCNTBITS-1:0] cnt_in5,
  input [MXCNTBITS-1:0] cnt_in6,
  input [MXCNTBITS-1:0] cnt_in7,
  input [MXCNTBITS-1:0] cnt_in8,
  input [MXCNTBITS-1:0] cnt_in9,
  input [MXCNTBITS-1:0] cnt_in10,
  input [MXCNTBITS-1:0] cnt_in11,
  input [MXCNTBITS-1:0] cnt_in12,
  input [MXCNTBITS-1:0] cnt_in13,
  input [MXCNTBITS-1:0] cnt_in14,
  input [MXCNTBITS-1:0] cnt_in15,

  input  vpf_in0,
  input  vpf_in1,
  input  vpf_in2,
  input  vpf_in3,
  input  vpf_in4,
  input  vpf_in5,
  input  vpf_in6,
  input  vpf_in7,
  input  vpf_in8,
  input  vpf_in9,
  input  vpf_in10,
  input  vpf_in11,
  input  vpf_in12,
  input  vpf_in13,
  input  vpf_in14,
  input  vpf_in15,

  output reg [MXADRBITS-1:0] adr0_o,
  output reg [MXADRBITS-1:0] adr1_o,
  output reg [MXADRBITS-1:0] adr2_o,
  output reg [MXADRBITS-1:0] adr3_o,
  output reg [MXADRBITS-1:0] adr4_o,
  output reg [MXADRBITS-1:0] adr5_o,
  output reg [MXADRBITS-1:0] adr6_o,
  output reg [MXADRBITS-1:0] adr7_o,

  output reg [MXCNTBITS-1:0] cnt0_o,
  output reg [MXCNTBITS-1:0] cnt1_o,
  output reg [MXCNTBITS-1:0] cnt2_o,
  output reg [MXCNTBITS-1:0] cnt3_o,
  output reg [MXCNTBITS-1:0] cnt4_o,
  output reg [MXCNTBITS-1:0] cnt5_o,
  output reg [MXCNTBITS-1:0] cnt6_o,
  output reg [MXCNTBITS-1:0] cnt7_o
);

parameter MXADRBITS=11;
parameter MXCNTBITS=3;

`define input_latch 1

//----------------------------------------------------------------------------------------------------------------------
// vectorize inputs
//----------------------------------------------------------------------------------------------------------------------

  reg [MXADRBITS-1:0] adr [15:0];   reg [MXCNTBITS-1:0] cnt [15:0]; reg [16:0] vpf;
  reg mux_pulse;

  `ifdef input_latch
    always @(posedge clock4x) begin
  `else
    always @(*) begin
  `endif

    adr[0]  <=  adr_in0;           vpf[0]  <= vpf_in0;        cnt[0]  <= cnt_in0;
    adr[1]  <=  adr_in1;           vpf[1]  <= vpf_in1;        cnt[1]  <= cnt_in1;
    adr[2]  <=  adr_in2;           vpf[2]  <= vpf_in2;        cnt[2]  <= cnt_in2;
    adr[3]  <=  adr_in3;           vpf[3]  <= vpf_in3;        cnt[3]  <= cnt_in3;
    adr[4]  <=  adr_in4;           vpf[4]  <= vpf_in4;        cnt[4]  <= cnt_in4;
    adr[5]  <=  adr_in5;           vpf[5]  <= vpf_in5;        cnt[5]  <= cnt_in5;
    adr[6]  <=  adr_in6;           vpf[6]  <= vpf_in6;        cnt[6]  <= cnt_in6;
    adr[7]  <=  adr_in7;           vpf[7]  <= vpf_in7;        cnt[7]  <= cnt_in7;
    adr[8]  <=  adr_in8;           vpf[8]  <= vpf_in8;        cnt[8]  <= cnt_in8;
    adr[9]  <=  adr_in9;           vpf[9]  <= vpf_in9;        cnt[9]  <= cnt_in9;
    adr[10] <=  adr_in10;          vpf[10] <= vpf_in10;       cnt[10] <= cnt_in10;
    adr[11] <=  adr_in11;          vpf[11] <= vpf_in11;       cnt[11] <= cnt_in11;
    adr[12] <=  adr_in12;          vpf[12] <= vpf_in12;       cnt[12] <= cnt_in12;
    adr[13] <=  adr_in13;          vpf[13] <= vpf_in13;       cnt[13] <= cnt_in13;
    adr[14] <=  adr_in14;          vpf[14] <= vpf_in14;       cnt[14] <= cnt_in14;
    adr[15] <=  adr_in15;          vpf[15] <= vpf_in15;       cnt[15] <= cnt_in15;

    mux_pulse <= mux_pulse_in;

  end

  always @(posedge clock4x) begin

     if     (vpf[7:0] == 8'b00000001) begin
      {adr0_o,cnt0_o} <= {adr[0],  cnt[0]};
      {adr1_o,cnt1_o} <= {adr[8],  cnt[8]};
      {adr2_o,cnt2_o} <= {adr[9],  cnt[9]};
      {adr3_o,cnt3_o} <= {adr[10], cnt[10]};
      {adr4_o,cnt4_o} <= {adr[11], cnt[11]};
      {adr5_o,cnt5_o} <= {adr[12], cnt[12]};
      {adr6_o,cnt6_o} <= {adr[13], cnt[13]};
      {adr7_o,cnt7_o} <= {adr[14], cnt[14]};
    end
    else if (vpf[7:0] == 8'b00000011) begin
      {adr0_o,cnt0_o} <= {adr[0],  cnt[0]};
      {adr1_o,cnt1_o} <= {adr[1],  cnt[1]};
      {adr2_o,cnt2_o} <= {adr[8],  cnt[8]};
      {adr3_o,cnt3_o} <= {adr[9],  cnt[9]};
      {adr4_o,cnt4_o} <= {adr[10], cnt[10]};
      {adr5_o,cnt5_o} <= {adr[11], cnt[11]};
      {adr6_o,cnt6_o} <= {adr[12], cnt[12]};
      {adr7_o,cnt7_o} <= {adr[13], cnt[13]};
    end
    else if (vpf[7:0] == 8'b00000111) begin
      {adr0_o,cnt0_o} <= {adr[0], cnt[0]};
      {adr1_o,cnt1_o} <= {adr[1], cnt[1]};
      {adr2_o,cnt2_o} <= {adr[2], cnt[2]};
      {adr3_o,cnt3_o} <= {adr[8], cnt[8]};
      {adr4_o,cnt4_o} <= {adr[8], cnt[8]};
      {adr5_o,cnt5_o} <= {adr[8], cnt[8]};
      {adr6_o,cnt6_o} <= {adr[8], cnt[8]};
      {adr7_o,cnt7_o} <= {adr[8], cnt[8]};
    end
    else if (vpf[7:0] == 8'b00001111) begin
      {adr0_o,cnt0_o} <= {adr[0], cnt[0]};
      {adr1_o,cnt1_o} <= {adr[1], cnt[1]};
      {adr2_o,cnt2_o} <= {adr[2], cnt[2]};
      {adr3_o,cnt3_o} <= {adr[3], cnt[3]};
      {adr4_o,cnt4_o} <= {adr[8], cnt[8]};
      {adr5_o,cnt5_o} <= {adr[8], cnt[8]};
      {adr6_o,cnt6_o} <= {adr[8], cnt[8]};
      {adr7_o,cnt7_o} <= {adr[8], cnt[8]};
    end
    else if (vpf[7:0] == 8'b00011111) begin
      {adr0_o,cnt0_o} <= {adr[0], cnt[0]};
      {adr1_o,cnt1_o} <= {adr[1], cnt[1]};
      {adr2_o,cnt2_o} <= {adr[2], cnt[2]};
      {adr3_o,cnt3_o} <= {adr[3], cnt[3]};
      {adr4_o,cnt4_o} <= {adr[4], cnt[4]};
      {adr5_o,cnt5_o} <= {adr[8], cnt[8]};
      {adr6_o,cnt6_o} <= {adr[8], cnt[8]};
      {adr7_o,cnt7_o} <= {adr[8], cnt[8]};
    end
    else if (vpf[7:0] == 8'b00111111) begin
      {adr0_o,cnt0_o} <= {adr[0], cnt[0]};
      {adr1_o,cnt1_o} <= {adr[1], cnt[1]};
      {adr2_o,cnt2_o} <= {adr[2], cnt[2]};
      {adr3_o,cnt3_o} <= {adr[3], cnt[3]};
      {adr4_o,cnt4_o} <= {adr[4], cnt[4]};
      {adr5_o,cnt5_o} <= {adr[5], cnt[5]};
      {adr6_o,cnt6_o} <= {adr[8], cnt[8]};
      {adr7_o,cnt7_o} <= {adr[8], cnt[8]};
    end
    else if (vpf[7:0] == 8'b01111111) begin
      {adr0_o,cnt0_o} <= {adr[0], cnt[0]};
      {adr1_o,cnt1_o} <= {adr[1], cnt[1]};
      {adr2_o,cnt2_o} <= {adr[2], cnt[2]};
      {adr3_o,cnt3_o} <= {adr[3], cnt[3]};
      {adr4_o,cnt4_o} <= {adr[4], cnt[4]};
      {adr5_o,cnt5_o} <= {adr[5], cnt[5]};
      {adr6_o,cnt6_o} <= {adr[6], cnt[6]};
      {adr7_o,cnt7_o} <= {adr[8], cnt[8]};
    end
    else if (vpf[7:0] == 8'b11111111) begin
      {adr0_o,cnt0_o} <= {adr[0], cnt[0]};
      {adr1_o,cnt1_o} <= {adr[1], cnt[1]};
      {adr2_o,cnt2_o} <= {adr[2], cnt[2]};
      {adr3_o,cnt3_o} <= {adr[3], cnt[3]};
      {adr4_o,cnt4_o} <= {adr[4], cnt[4]};
      {adr5_o,cnt5_o} <= {adr[5], cnt[5]};
      {adr6_o,cnt6_o} <= {adr[6], cnt[6]};
      {adr7_o,cnt7_o} <= {adr[7], cnt[7]};
    end

    mux_pulse_out <= mux_pulse;
  end

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
