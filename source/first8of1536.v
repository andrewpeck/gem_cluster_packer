`timescale 1ns / 100 ps

module first8of1536 (

    input clock4x,

    input latch_pulse, // this should go high when new vpfs are ready

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

  reg [MXADRBITS-1:0] adr_latch [1:0][3:0];
  reg [MXCNTBITS-1:0] cnt_latch [1:0][3:0];
  reg [          0:0] vpf_latch [1:0][3:0];

  // carry along a marker showing the ith cluster which is being processed-- used for sync
  wire [2:0] pass_truncate      [1:0];
  wire [2:0] pass_encoder       [1:0];
  reg  [2:0] pass_encoder_latch ;


  genvar ienc;
  generate;
  for (ienc=0; ienc<2; ienc=ienc+1) begin: encloop

      // cluster truncator
      //------------------
      truncate_clusters u_truncate (
        .clock        (clock4x),
        .latch_pulse  (latch_pulse),
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
        .latch_pulse   (latch_pulse),
        .vpfs_in       (vpfs_truncated[768  *(ienc+1)-1:768  *ienc]),
        .cnts_in       (cnts_in       [768*3*(ienc+1)-1:768*3*ienc]),
        .cnt           (cnt_enc[ienc]),       // OUT 11-bit counts    of first found cluster
        .adr           (adr_enc[ienc]),       // OUT 11-bit addresses of first found cluster
        .cluster_found (vpf_enc[ienc])
      );

    genvar i;
    for (i=0; i<4; i=i+1) begin: latchloop
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

reg  [MXADRBITS-1:0] adr_s1 [7:0];
reg  [MXCNTBITS-1:0] cnt_s1 [7:0];

// latch outputs of priority encoder when it produces its 8 results, stable for merger

assign pass = pass_encoder_latch;

always @(posedge clock4x) begin

  pass_encoder_latch  <= pass_encoder[0];

  if (pass_encoder[0]==3'd3) begin

      adr_s1  [0]  <= adr_latch[0][0];
      adr_s1  [1]  <= adr_latch[0][1];
      adr_s1  [2]  <= adr_latch[0][2];
      adr_s1  [3]  <= adr_enc  [0]   ; // lookahead on #7

      adr_s1  [4]  <= adr_latch[1][0] + (vpf_latch[1][0] * 11'd768);
      adr_s1  [5]  <= adr_latch[1][1] + (vpf_latch[1][1] * 11'd768);
      adr_s1  [6]  <= adr_latch[1][2] + (vpf_latch[1][2] * 11'd768);
      adr_s1  [7]  <= adr_enc  [1]    + (vpf_enc  [1]    * 11'd768); // lookahead on #7

      cnt_s1  [0]  <= cnt_latch[0][0];
      cnt_s1  [1]  <= cnt_latch[0][1];
      cnt_s1  [2]  <= cnt_latch[0][2];
      cnt_s1  [3]  <= cnt_enc  [0]   ; // lookahead on #7

      cnt_s1  [4]  <= cnt_latch[1][0];
      cnt_s1  [5]  <= cnt_latch[1][1];
      cnt_s1  [6]  <= cnt_latch[1][2];
      cnt_s1  [7]  <= cnt_enc  [1]   ; // lookahead on #7

  end
end

//-------------------------------------------------------------------------------------------------------------------
// Outputs
// ------------------------------------------------------------------------------------------------------------------

  always @(*) begin
    adr0  <= adr_s1[0];
    adr1  <= adr_s1[1];
    adr2  <= adr_s1[2];
    adr3  <= adr_s1[3];
    adr4  <= adr_s1[4];
    adr5  <= adr_s1[5];
    adr6  <= adr_s1[6];
    adr7  <= adr_s1[7];

    cnt0  <= cnt_s1[0];
    cnt1  <= cnt_s1[1];
    cnt2  <= cnt_s1[2];
    cnt3  <= cnt_s1[3];
    cnt4  <= cnt_s1[4];
    cnt5  <= cnt_s1[5];
    cnt6  <= cnt_s1[6];
    cnt7  <= cnt_s1[7];
  end

//----------------------------------------------------------------------------------------------------------------------
endmodule
// ---------------------------------------------------------------------------------------------------------------------
