`timescale 1ns / 100 ps

module first8of1536 (

    input clock4x,

    input frame_clock,

    input  [1536  -1:0] vpfs_in,
    input  [1536*3-1:0] cnts_in,

    output reg [2:0]      cnt0,
    output reg [2:0]      cnt1,
    output reg [2:0]      cnt2,
    output reg [2:0]      cnt3,
    output reg [2:0]      cnt4,
    output reg [2:0]      cnt5,
    output reg [2:0]      cnt6,
    output reg [2:0]      cnt7,

    output reg [10:0]      adr0,
    output reg [10:0]      adr1,
    output reg [10:0]      adr2,
    output reg [10:0]      adr3,
    output reg [10:0]      adr4,
    output reg [10:0]      adr5,
    output reg [10:0]      adr6,
    output reg [10:0]      adr7
);


//----------------------------------------------------------------------------------------------------------------------
// Interconnects
//----------------------------------------------------------------------------------------------------------------------

  wire [2:0] cnts_unrolled [1535:0]; 
  genvar ipad; 
  generate
    for (ipad=0; ipad<1536; ipad=ipad+1) begin:padloop
      assign cnts_unrolled [ipad] = cnts_in [ipad*3+2:ipad*3];
    end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
// Signals
//----------------------------------------------------------------------------------------------------------------------

  wire [1535:0] vpfs_truncated;
  wire   [10:0] adr_enc [1:0];
  wire   [0:0]  vpf_enc [1:0];
  wire   [2:0]  cnt_enc [1:0];

//----------------------------------------------------------------------------------------------------------------------
// Encoders
//----------------------------------------------------------------------------------------------------------------------

  parameter MXADRBITS = 11;
  parameter MXCNTBITS = 3;

  reg [MXADRBITS-1:0] adr_latch [1:0][7:0];
  reg [MXCNTBITS-1:0] cnt_latch [1:0][7:0];
  reg [          0:0] vpf_latch [1:0][7:0];

  // carry along a marker showing the ith cluster which is being processed-- used for sync
  wire [2:0] pass_truncate      [1:0];
  wire [2:0] pass_encoder       [1:0];
  reg  [2:0] pass_encoder_latch ;
  reg  [2:0] pass_encoder_s1    ;
  wire [2:0] pass_merger        ;


  genvar ienc;
  generate;
  for (ienc=0; ienc<2; ienc=ienc+1) begin: encloop

      // cluster truncator
      //------------------
      truncate_clusters u_truncate (
        .clock        (clock4x),
        .frame_clock  (frame_clock),
        .vpfs_in      (vpfs_in       [768*(ienc+1)-1:768*ienc]),
        .vpfs_out     (vpfs_truncated[768*(ienc+1)-1:768*ienc]),
        .pass         (pass_truncate[ienc])
      );

      // 768-bit priority encoder
      //--------------------------
      priority768 u_priority (
        .pass_in       (pass_truncate[ienc]),
        .pass_out      (pass_encoder[ienc]),
        .clock         (clock4x),       // IN  160 MHz clock
        .frame_clock  (frame_clock),
        .vpfs_in       (vpfs_truncated[768  *(ienc+1)-1:768  *ienc]),
        .cnts_in       (cnts_in       [768*3*(ienc+1)-1:768*3*ienc]),
        .cnt           (cnt_enc[ienc]),       // OUT 11-bit counts    of first found cluster
        .adr           (adr_enc[ienc]),       // OUT 11-bit addresses of first found cluster
        .cluster_found (vpf_enc[ienc])
      );

    genvar i;
    for (i=0; i<8; i=i+1) begin: latchloop
    always @(posedge clock4x) begin
      if (pass_encoder[ienc]==i) begin
        adr_latch[ienc][i] <= adr_enc[ienc];
        cnt_latch[ienc][i] <= cnt_enc[ienc];
        vpf_latch[ienc][i] <= vpf_enc[ienc];
      end
    end
    end

end
endgenerate

always @(posedge clock4x) begin
end

reg  [MXADRBITS-1:0] adr_s1 [15:0];
reg  [MXCNTBITS-1:0] cnt_s1 [15:0];

wire [MXADRBITS-1:0] adr_merged [7:0];
wire [MXCNTBITS-1:0] cnt_merged [7:0];

  // latch outputs of priority encoder when it produces its 8 results, stable for merger

always @(posedge clock4x) begin

  pass_encoder_latch  <= pass_encoder[0];
  pass_encoder_s1     <= pass_encoder[0];

  if (pass_encoder[0]==3'd7) begin

      adr_s1  [0]  <= adr_latch[0][0];
      adr_s1  [1]  <= adr_latch[0][1];
      adr_s1  [2]  <= adr_latch[0][2];
      adr_s1  [3]  <= adr_latch[0][3];
      adr_s1  [4]  <= adr_latch[0][4];
      adr_s1  [5]  <= adr_latch[0][5];
      adr_s1  [6]  <= adr_latch[0][6];
      adr_s1  [7]  <= adr_enc  [0]   ; // lookahead on #7

      adr_s1  [8]  <= adr_latch[1][0] + (vpf_latch[1][0] * 11'd768);
      adr_s1  [9]  <= adr_latch[1][1] + (vpf_latch[1][1] * 11'd768);
      adr_s1  [10] <= adr_latch[1][2] + (vpf_latch[1][2] * 11'd768);
      adr_s1  [11] <= adr_latch[1][3] + (vpf_latch[1][3] * 11'd768);
      adr_s1  [12] <= adr_latch[1][4] + (vpf_latch[1][4] * 11'd768);
      adr_s1  [13] <= adr_latch[1][5] + (vpf_latch[1][5] * 11'd768);
      adr_s1  [14] <= adr_latch[1][6] + (vpf_latch[1][6] * 11'd768);
      adr_s1  [15] <= adr_enc  [1]    + (vpf_enc  [1]    * 11'd768); // lookahead on #7

      cnt_s1  [0]  <= cnt_latch[0][0];
      cnt_s1  [1]  <= cnt_latch[0][1];
      cnt_s1  [2]  <= cnt_latch[0][2];
      cnt_s1  [3]  <= cnt_latch[0][3];
      cnt_s1  [4]  <= cnt_latch[0][4];
      cnt_s1  [5]  <= cnt_latch[0][5];
      cnt_s1  [6]  <= cnt_latch[0][6];
      cnt_s1  [7]  <= cnt_enc  [0]   ; // lookahead on #7

      cnt_s1  [7]   <= cnt_latch[1][0];
      cnt_s1  [8]   <= cnt_latch[1][1];
      cnt_s1  [9]   <= cnt_latch[1][2];
      cnt_s1  [10]  <= cnt_latch[1][3];
      cnt_s1  [11]  <= cnt_latch[1][4];
      cnt_s1  [12]  <= cnt_latch[1][5];
      cnt_s1  [13]  <= cnt_latch[1][6];
      cnt_s1  [14]  <= cnt_enc  [1]   ; // lookahead on #7

  end
end


merge16 u_merge16 (
    .clock4x(clock4x),

    .pass_in (pass_encoder_s1),
    .pass_out (pass_merger),

    .adr_in0  ( adr_s1[0]),
    .adr_in1  ( adr_s1[1]),
    .adr_in2  ( adr_s1[2]),
    .adr_in3  ( adr_s1[3]),
    .adr_in4  ( adr_s1[4]),
    .adr_in5  ( adr_s1[5]),
    .adr_in6  ( adr_s1[6]),
    .adr_in7  ( adr_s1[7]),
    .adr_in8  ( adr_s1[8]),
    .adr_in9  ( adr_s1[9]),
    .adr_in10 ( adr_s1[10]),
    .adr_in11 ( adr_s1[11]),
    .adr_in12 ( adr_s1[12]),
    .adr_in13 ( adr_s1[13]),
    .adr_in14 ( adr_s1[14]),
    .adr_in15 ( adr_s1[15]),

    .cnt_in0  ( cnt_s1[0]),
    .cnt_in1  ( cnt_s1[1]),
    .cnt_in2  ( cnt_s1[2]),
    .cnt_in3  ( cnt_s1[3]),
    .cnt_in4  ( cnt_s1[4]),
    .cnt_in5  ( cnt_s1[5]),
    .cnt_in6  ( cnt_s1[6]),
    .cnt_in7  ( cnt_s1[7]),
    .cnt_in8  ( cnt_s1[8]),
    .cnt_in9  ( cnt_s1[9]),
    .cnt_in10 ( cnt_s1[10]),
    .cnt_in11 ( cnt_s1[11]),
    .cnt_in12 ( cnt_s1[12]),
    .cnt_in13 ( cnt_s1[13]),
    .cnt_in14 ( cnt_s1[14]),
    .cnt_in15 ( cnt_s1[15]),


    .adr0_o(adr_merged[0]),
    .adr1_o(adr_merged[1]),
    .adr2_o(adr_merged[2]),
    .adr3_o(adr_merged[3]),
    .adr4_o(adr_merged[4]),
    .adr5_o(adr_merged[5]),
    .adr6_o(adr_merged[6]),
    .adr7_o(adr_merged[7]),

    .cnt0_o(cnt_merged[0]),
    .cnt1_o(cnt_merged[1]),
    .cnt2_o(cnt_merged[2]),
    .cnt3_o(cnt_merged[3]),
    .cnt4_o(cnt_merged[4]),
    .cnt5_o(cnt_merged[5]),
    .cnt6_o(cnt_merged[6]),
    .cnt7_o(cnt_merged[7])
);

//-------------------------------------------------------------------------------------------------------------------
// Outputs
// ------------------------------------------------------------------------------------------------------------------

  always @(*) begin
    adr0 <= adr_merged[0];
    adr1 <= adr_merged[1];
    adr2 <= adr_merged[2];
    adr3 <= adr_merged[3];
    adr4 <= adr_merged[4];
    adr5 <= adr_merged[5];
    adr6 <= adr_merged[6];
    adr7 <= adr_merged[7];

    cnt0 <= cnt_merged[0];
    cnt1 <= cnt_merged[1];
    cnt2 <= cnt_merged[2];
    cnt3 <= cnt_merged[3];
    cnt4 <= cnt_merged[4];
    cnt5 <= cnt_merged[5];
    cnt6 <= cnt_merged[6];
    cnt7 <= cnt_merged[7];
  end

//----------------------------------------------------------------------------------------------------------------------
endmodule
// ---------------------------------------------------------------------------------------------------------------------
