//----------------------------------------------------------------------------------------------------------------------
// cluster.packer.v
//----------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 100 ps
//----------------------------------------------------------------------------------------------------------------------
// clock 0: generate a cluster size count for each pad; generate cluster primary flags (vpfs)
// clock 1: vpfs and counts are routed through logic, and latched locally in the cluster_truncator and priority768 modules
//
//           cluster_truncator           |  priority encoder
//----------------------------------------------------------------------------------------------------------------------
// clock 2:  (n-1) truncated clusters
// clock 3:  (n-2) truncated clusters    ;  latch 1st cluster result
// clock 4:  (n-3) truncated clusters    ;  latch 2nd cluster result
// clock 7:  (n-4) truncated clusters    ;  latch 3rd cluster result
// clock 8:  (n-5) truncated clusters    ;  latch 4th cluster result
// clock 9:  (n-6) truncated clusters    ;  latch 5th cluster result
// clock 10: (n-7) truncated clusters    ;  latch 6th cluster result
// clock 11:                             ;  latch 7th cluster result
// clock 12: merge16 result stage 1
// clock 13: merge16 result stage 2 returns addresses/counts of first 8 clusters
//----------------------------------------------------------------------------------------------------------------------

//synthesis attribute ALLCLOCKNETS of cluster_packer is "240MHz"

module cluster_packer (
    input  clock4x,
    input  global_reset,
    input  truncate_clusters,

    input  [MXSBITS-1:0] vfat0,
    input  [MXSBITS-1:0] vfat1,
    input  [MXSBITS-1:0] vfat2,
    input  [MXSBITS-1:0] vfat3,
    input  [MXSBITS-1:0] vfat4,
    input  [MXSBITS-1:0] vfat5,
    input  [MXSBITS-1:0] vfat6,
    input  [MXSBITS-1:0] vfat7,
    input  [MXSBITS-1:0] vfat8,
    input  [MXSBITS-1:0] vfat9,
    input  [MXSBITS-1:0] vfat10,
    input  [MXSBITS-1:0] vfat11,
    input  [MXSBITS-1:0] vfat12,
    input  [MXSBITS-1:0] vfat13,
    input  [MXSBITS-1:0] vfat14,
    input  [MXSBITS-1:0] vfat15,
    input  [MXSBITS-1:0] vfat16,
    input  [MXSBITS-1:0] vfat17,
    input  [MXSBITS-1:0] vfat18,
    input  [MXSBITS-1:0] vfat19,
    input  [MXSBITS-1:0] vfat20,
    input  [MXSBITS-1:0] vfat21,
    input  [MXSBITS-1:0] vfat22,
    input  [MXSBITS-1:0] vfat23,

    output [MXCLSTBITS-1:0] cluster0,
    output [MXCLSTBITS-1:0] cluster1,
    output [MXCLSTBITS-1:0] cluster2,
    output [MXCLSTBITS-1:0] cluster3,
    output [MXCLSTBITS-1:0] cluster4,
    output [MXCLSTBITS-1:0] cluster5,
    output [MXCLSTBITS-1:0] cluster6,
    output [MXCLSTBITS-1:0] cluster7
);

parameter MXSBITS    = 64;         // S-bits per vfat
parameter MXKEYS     = 3*MXSBITS;  // S-bits per partition
parameter MXPADS     = 24*MXSBITS; // S-bits per chamber
parameter MXROWS     = 8;          // Eta partitions per chamber
parameter MXCNTBITS  = 3;          // Number of count   bits per cluster
parameter MXADRBITS  = 11;         // Number of address bits per cluster
parameter MXCLSTBITS = 14;         // Number of total   bits per cluster
parameter MXOUTBITS  = 56;         // Number of total   bits per packet
parameter MXCLUSTERS = 8;          // Number of clusters per bx

//----------------------------------------------------------------------------------------------------------------------
// State machine power-up reset + global reset
//----------------------------------------------------------------------------------------------------------------------

  // Startup -- keeps outputs off during powerup
  //---------------------------------------------

  wire [3:0] powerup_dly = 4'd0;

  reg powerup_ff  = 0;
  //srl16e_bbl #(1) u_startup (.clock(clock4x), .ce(!powerup), .adr(powerup_dly),  .d(1'b1), .q(powerup));
  SRL16E u_startup (.CLK(clock4x),.CE(!powerup),.D(1'b1),.A0(powerup_dly[0]),.A1(powerup_dly[1]),.A2(powerup_dly[2]),.A3(powerup_dly[3]),.Q(powerup));
  always @(posedge clock4x) begin
    powerup_ff <= powerup;
  end

  // Reset -- keeps outputs off during reset time
  //--------------------------------------------------------------
  reg reset_done_ff = 1;
  wire [3:0] reset_dly=4'd0;

  //srl16e_bbl #(1) u_reset_dly (.clock(clock4x), .ce(1'b1), .adr(reset_dly),  .d(global_reset), .q(reset_delayed));
  SRL16E u_reset (
    .CLK (clock4x),
    .CE  (1'b1),
    .D   (global_reset),
    .Q   (reset_delayed),
    .A0  (reset_dly[0]),.A1 ( reset_dly[1]),.A2 ( reset_dly[2]),.A3 ( reset_dly[3])
  );

  always @(posedge clock4x) begin
    if       (global_reset && reset_done_ff)                   reset_done_ff <= 1'b0;
    else if (!global_reset && reset_delayed && !reset_done_ff) reset_done_ff <= 1'b1;
    else                                                       reset_done_ff <= reset_done_ff;
  end

  wire ready = powerup_ff && reset_done_ff;
  wire reset = !ready;

//----------------------------------------------------------------------------------------------------------------------
// clock 1: Count cluster multiplicity for each pad
//----------------------------------------------------------------------------------------------------------------------

  // remap vfats into partitions
  //--------------------------------------------------------------------------------

  reg [MXKEYS-1:0] partition [7:0];

  always @(posedge clock4x) begin
    partition[0] <= {vfat2,  vfat1,   vfat0};
    partition[1] <= {vfat5,  vfat4,   vfat3};
    partition[2] <= {vfat8,  vfat7,   vfat6};
    partition[3] <= {vfat11, vfat10,  vfat9};
    partition[4] <= {vfat14, vfat13,  vfat12};
    partition[5] <= {vfat17, vfat16,  vfat15};
    partition[6] <= {vfat20, vfat19,  vfat18};
    partition[7] <= {vfat23, vfat22,  vfat21};
  end

  // zero pad the partition to handle the edge cases for counting
  //--------------------------------------------------------------------------------
  wire [(MXKEYS-1)+8:0] partition_padded [MXROWS-1:0];

  assign partition_padded[0] = {{8{1'b0}}, partition[0]};
  assign partition_padded[1] = {{8{1'b0}}, partition[1]};
  assign partition_padded[2] = {{8{1'b0}}, partition[2]};
  assign partition_padded[3] = {{8{1'b0}}, partition[3]};
  assign partition_padded[4] = {{8{1'b0}}, partition[4]};
  assign partition_padded[5] = {{8{1'b0}}, partition[5]};
  assign partition_padded[6] = {{8{1'b0}}, partition[6]};
  assign partition_padded[7] = {{8{1'b0}}, partition[7]};

  // count cluster size and assign valid pattern flags
  //--------------------------------------------------------------------------------
  reg  [MXPADS  -1:0] vpfs;
  wire [MXPADS*3-1:0] cnts;

  genvar ikey;
  genvar irow;
  genvar ibit;
  generate
    for (irow=0; irow<MXROWS; irow=irow+1) begin: cluster_count_rowloop
    for (ikey=0; ikey<MXKEYS; ikey=ikey+1) begin: cluster_count_keyloop

      consecutive_count ucntseq (
        .clock (clock4x),
        .sbit  (partition_padded[irow][ikey+7:ikey+1]),
        .count (cnts[(MXKEYS*irow*3)+(ikey+1)*3-1:(MXKEYS*irow*3)+ikey*3])
      );

      // first pad is always a cluster if it has an S-bit
      // other pads are cluster if they:
      //    (1) are preceded by a Zero (i.e. they start a cluster)
      // or (2) are preceded by a Size=8 cluster (and cluster truncation is turned off)
      //        if we have size > 16 cluster, the end will get cut off
      always @(posedge clock4x) begin
        if      (ikey==0) vpfs  [(MXKEYS*irow)+ikey] <= partition[irow][ikey];
        else if (ikey <9) vpfs  [(MXKEYS*irow)+ikey] <= partition[irow][ikey:ikey-1]==2'b10;
        else              vpfs  [(MXKEYS*irow)+ikey] <= partition[irow][ikey:ikey-1]==2'b10 || (!truncate_clusters && partition[irow][ikey-1:ikey-9]==9'b111111110) ;
      end

    end // row loop
    end // key_loop
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
// clock 3-12: priority encoding
//----------------------------------------------------------------------------------------------------------------------

  wire [MXADRBITS-1:0] adr_encoder [MXCLUSTERS-1:0];
  wire [MXCNTBITS-1:0] cnt_encoder [MXCLUSTERS-1:0];

  encoder_mux u_encoder_mux (
    .clock4x (clock4x),

    .global_reset (global_reset),

    .vpfs_in (vpfs),
    .cnts_in (cnts),

    .adr0 (adr_encoder[0]),
    .adr1 (adr_encoder[1]),
    .adr2 (adr_encoder[2]),
    .adr3 (adr_encoder[3]),
    .adr4 (adr_encoder[4]),
    .adr5 (adr_encoder[5]),
    .adr6 (adr_encoder[6]),
    .adr7 (adr_encoder[7]),

    .cnt0 (cnt_encoder[0]),
    .cnt1 (cnt_encoder[1]),
    .cnt2 (cnt_encoder[2]),
    .cnt3 (cnt_encoder[3]),
    .cnt4 (cnt_encoder[4]),
    .cnt5 (cnt_encoder[5]),
    .cnt6 (cnt_encoder[6]),
    .cnt7 (cnt_encoder[7])
  );

//----------------------------------------------------------------------------------------------------------------------
// clock 13: build data packet
//----------------------------------------------------------------------------------------------------------------------

  wire [MXCLSTBITS-1:0] cluster [MXCLUSTERS-1:0];
  genvar icluster;
  generate
    for (icluster=0; icluster<MXROWS; icluster=icluster+1) begin: adrloop

      //  14 bit hit format encoding
      //   hit[10:0]  = pad
      //   hit[13:11] = n adjacent pads hit  up to 7
      assign cluster[icluster] = {cnt_encoder[icluster], adr_encoder[icluster]};
    end
  endgenerate


  assign cluster0 = cluster[0];
  assign cluster1 = cluster[1];
  assign cluster2 = cluster[2];
  assign cluster3 = cluster[3];
  assign cluster4 = cluster[4];
  assign cluster5 = cluster[5];
  assign cluster6 = cluster[6];
  assign cluster7 = cluster[7];

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
