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
  wire   [0:0] cluster_found [1:0];
  wire   [2:0] cnt_enc [1:0];

//----------------------------------------------------------------------------------------------------------------------
// Encoders
//----------------------------------------------------------------------------------------------------------------------

  parameter MXADRBITS = 11;
  parameter MXCNTBITS = 3;

  reg [MXADRBITS*8-1:0] adr_sr [1:0];
  reg [MXCNTBITS*8-1:0] cnt_sr [1:0];
  reg [            7:0] vpf_sr [1:0];


  genvar ienc;
  generate;
  for (ienc=0; ienc<2; ienc=ienc+1) begin: encloop

      initial adr_sr[ienc] <= -1;
      initial cnt_sr[ienc] <= -1;

      // cluster truncator
      //------------------
      truncate_clusters u_truncate (
        .clock        (clock4x),
        .frame_clock  (frame_clock),
        .vpfs_in      (vpfs_in       [768*(ienc+1)-1:768*ienc]),
        .vpfs_out     (vpfs_truncated[768*(ienc+1)-1:768*ienc])
      );

      // 768-bit priority encoder
      //--------------------------
      priority768 u_priority (
        .clock         (clock4x),       // IN  160 MHz clock
        .vpfs_in       (vpfs_truncated[768  *(ienc+1)-1:768  *ienc]),
        .cnts_in       (cnts_in       [768*3*(ienc+1)-1:768*3*ienc]),
        .cnt           (cnt_enc[ienc]),       // OUT 11-bit counts    of first found cluster
        .adr           (adr_enc[ienc]),       // OUT 11-bit addresses of first found cluster
        .cluster_found (cluster_found[ienc])
      );

    always @(posedge clock4x) begin
      adr_sr[ienc] <= {adr_sr[ienc][MXADRBITS*7-1:0], adr_enc[ienc]};
      cnt_sr[ienc] <= {cnt_sr[ienc][MXCNTBITS*7-1:0], cnt_enc[ienc]};
      vpf_sr[ienc] <= {vpf_sr[ienc]            [6:0], cluster_found[ienc]};
    end

end
endgenerate

wire          [15:0] vpf_s1;
wire [MXADRBITS-1:0] adr_s1 [15:0];
wire [MXCNTBITS-1:0] cnt_s1 [15:0];
wire [MXADRBITS-1:0] adr     [7:0];
wire [MXCNTBITS-1:0] cnt     [7:0];

genvar iclust;
generate;
for (iclust=0; iclust<8; iclust=iclust+1) begin: clust_loop
    assign adr_s1  [iclust] = adr_sr[0][MXADRBITS*(8-iclust)-1:MXADRBITS*(7-iclust)] ;
    assign adr_s1[iclust+8] = adr_sr[1][MXADRBITS*(8-iclust)-1:MXADRBITS*(7-iclust)]+11'd768;

    assign cnt_s1  [iclust] = cnt_sr[0][MXCNTBITS*(8-iclust)-1:MXCNTBITS*(7-iclust)];
    assign cnt_s1[iclust+8] = cnt_sr[1][MXCNTBITS*(8-iclust)-1:MXCNTBITS*(7-iclust)];

    assign vpf_s1[iclust]   = vpf_sr[0][7-iclust];
    assign vpf_s1[iclust+8] = vpf_sr[1][7-iclust];
end
endgenerate

merge16 u_merge16 (
    .clock4x(clock4x),

    .vpfs(vpf_s1),

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


    .adr0(adr[0]),
    .adr1(adr[1]),
    .adr2(adr[2]),
    .adr3(adr[3]),
    .adr4(adr[4]),
    .adr5(adr[5]),
    .adr6(adr[6]),
    .adr7(adr[7]),

    .cnt0(cnt[0]),
    .cnt1(cnt[1]),
    .cnt2(cnt[2]),
    .cnt3(cnt[3]),
    .cnt4(cnt[4]),
    .cnt5(cnt[5]),
    .cnt6(cnt[6]),
    .cnt7(cnt[7])
);

//-------------------------------------------------------------------------------------------------------------------
// Outputs
// ------------------------------------------------------------------------------------------------------------------

  always @(posedge frame_clock) begin
      adr0 <= adr[0];
      adr1 <= adr[1];
      adr2 <= adr[2];
      adr3 <= adr[3];
      adr4 <= adr[4];
      adr5 <= adr[5];
      adr6 <= adr[6];
      adr7 <= adr[7];

      cnt0 <= cnt[0];
      cnt1 <= cnt[1];
      cnt2 <= cnt[2];
      cnt3 <= cnt[3];
      cnt4 <= cnt[4];
      cnt5 <= cnt[5];
      cnt6 <= cnt[6];
      cnt7 <= cnt[7];
  end

//----------------------------------------------------------------------------------------------------------------------
endmodule
// ---------------------------------------------------------------------------------------------------------------------
