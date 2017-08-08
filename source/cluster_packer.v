`define invert_partitions
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
// clock 13: merge16 result stage 2
// clock 14: merge16 result stage 3 returns addresses/counts of first 8 clusters
//----------------------------------------------------------------------------------------------------------------------

//synthesis attribute ALLCLOCKNETS of cluster_packer is "240MHz"

module cluster_packer (

    input        clock4x,
    input        clock1x,
    input        global_reset,
    output [7:0] cluster_count_o,
    input        truncate_clusters,
    input        oneshot_en, 

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

    output reg [MXCLSTBITS-1:0] cluster0,
    output reg [MXCLSTBITS-1:0] cluster1,
    output reg [MXCLSTBITS-1:0] cluster2,
    output reg [MXCLSTBITS-1:0] cluster3,
    output reg [MXCLSTBITS-1:0] cluster4,
    output reg [MXCLSTBITS-1:0] cluster5,
    output reg [MXCLSTBITS-1:0] cluster6,
    output reg [MXCLSTBITS-1:0] cluster7,


    output overflow
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

  initial cluster0 = 0;
  initial cluster1 = 0;
  initial cluster2 = 0;
  initial cluster3 = 0;
  initial cluster4 = 0;
  initial cluster5 = 0;
  initial cluster6 = 0;
  initial cluster7 = 0;

  // Startup -- keeps outputs off during powerup
  //---------------------------------------------

  wire [3:0] powerup_dly = 4'd12;

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
// clock 0: fire oneshots to prevent stuck bits and shorten the monostables
//----------------------------------------------------------------------------------------------------------------------

  wire [MXSBITS-1:0] vfat_s0 [24:0];
  wire [MXSBITS-1:0] vfat_s1 [24:0];

  assign vfat_s0[0]  = vfat0;
  assign vfat_s0[1]  = vfat1;
  assign vfat_s0[2]  = vfat2;
  assign vfat_s0[3]  = vfat3;
  assign vfat_s0[4]  = vfat4;
  assign vfat_s0[5]  = vfat5;
  assign vfat_s0[6]  = vfat6;
  assign vfat_s0[7]  = vfat7;
  assign vfat_s0[8]  = vfat8;
  assign vfat_s0[9]  = vfat9;
  assign vfat_s0[10] = vfat10;
  assign vfat_s0[11] = vfat11;
  assign vfat_s0[12] = vfat12;
  assign vfat_s0[13] = vfat13;
  assign vfat_s0[14] = vfat14;
  assign vfat_s0[15] = vfat15;
  assign vfat_s0[16] = vfat16;
  assign vfat_s0[17] = vfat17;
  assign vfat_s0[18] = vfat18;
  assign vfat_s0[19] = vfat19;
  assign vfat_s0[20] = vfat20;
  assign vfat_s0[21] = vfat21;
  assign vfat_s0[22] = vfat22;
  assign vfat_s0[23] = vfat23;

  genvar os_vfat;
  genvar os_sbit;
  generate
  for (os_vfat=0; os_vfat<24;      os_vfat=os_vfat+1'b1) begin  : os_vfatloop
    for (os_sbit=0; os_sbit<MXSBITS; os_sbit=os_sbit+1'b1) begin  : os_sbitloop
      x_oneshot sbit_oneshot (
        .d      (vfat_s0[os_vfat][os_sbit]),
        .q      (vfat_s1[os_vfat][os_sbit]),
        .clock  (clock1x), 
        .enable (oneshot_en)
      );
    end
  end
  endgenerate

//----------------------------------------------------------------------------------------------------------------------
// clock 1: Count cluster multiplicity for each pad
//----------------------------------------------------------------------------------------------------------------------

  // remap vfats into partitions
  //--------------------------------------------------------------------------------

  reg [MXKEYS-1:0] partition [7:0];

  always @(posedge clock4x) begin
    `ifdef invert_partitions  // need to make a choice about whether strip-0 is in partition 0 or 7
      partition[7] <= {vfat_s1[16], vfat_s1[8 ],  vfat_s1[0]};
      partition[6] <= {vfat_s1[17], vfat_s1[9 ],  vfat_s1[1]};
      partition[5] <= {vfat_s1[18], vfat_s1[10],  vfat_s1[2]};
      partition[4] <= {vfat_s1[19], vfat_s1[11],  vfat_s1[3]};
      partition[3] <= {vfat_s1[20], vfat_s1[12],  vfat_s1[4]};
      partition[2] <= {vfat_s1[21], vfat_s1[13],  vfat_s1[5]};
      partition[1] <= {vfat_s1[22], vfat_s1[14],  vfat_s1[6]};
      partition[0] <= {vfat_s1[23], vfat_s1[15],  vfat_s1[7]};
    `else
      partition[0] <= {vfat_s1[16], vfat_s1[8 ],  vfat_s1[0]};
      partition[1] <= {vfat_s1[17], vfat_s1[9 ],  vfat_s1[1]};
      partition[2] <= {vfat_s1[18], vfat_s1[10],  vfat_s1[2]};
      partition[3] <= {vfat_s1[19], vfat_s1[11],  vfat_s1[3]};
      partition[4] <= {vfat_s1[20], vfat_s1[12],  vfat_s1[4]};
      partition[5] <= {vfat_s1[21], vfat_s1[13],  vfat_s1[5]};
      partition[6] <= {vfat_s1[22], vfat_s1[14],  vfat_s1[6]};
      partition[7] <= {vfat_s1[23], vfat_s1[15],  vfat_s1[7]};
    `endif
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
  reg  [MXPADS  -1:0] vpfs=0;
  wire [MXPADS*3-1:0] cnts;

  parameter VFAT_V2 = 0;
  genvar ikey;
  genvar irow;
  genvar ibit;
  generate
    for (irow=0; irow<MXROWS; irow=irow+1) begin: cluster_count_rowloop
    for (ikey=0; ikey<MXKEYS; ikey=ikey+1) begin: cluster_count_keyloop

        if (VFAT_V2)  begin
            assign cnts[(MXKEYS*irow*3)+(ikey+1)*3-1:(MXKEYS*irow*3)+ikey*3] = 3'd7;
            always @(posedge clock4x)
              vpfs [(MXKEYS*irow)+ikey] <= partition[irow][ikey];
        end
        else begin
          // first pad is always a cluster if it has an S-bit
          // other pads are cluster if they:
          //    (1) are preceded by a Zero (i.e. they start a cluster)
          // or (2) are preceded by a Size=8 cluster (and cluster truncation is turned off)
          //        if we have size > 16 cluster, the end will get cut off
          always @(posedge clock4x) begin
            if      (ikey==0) vpfs  [(MXKEYS*irow)+ikey] <= partition[irow][ikey];
            else if (ikey <9) vpfs  [(MXKEYS*irow)+ikey] <= partition[irow][ikey:ikey-1]==2'b10;
            else              vpfs  [(MXKEYS*irow)+ikey] <= partition[irow][ikey:ikey-1]==2'b10 || (!truncate_clusters && partition[irow][ikey:ikey-9]==10'b1111111110) ;
          end

          consecutive_count ucntseq (
            .clock (clock4x),
            .sbit  (partition_padded[irow][ikey+7:ikey+1]),
            .count (cnts[(MXKEYS*irow*3)+(ikey+1)*3-1:(MXKEYS*irow*3)+ikey*3])
          );
        end

    end // row loop
    end // key_loop
  endgenerate

  // We count the number of cluster primaries. If it is greater than 8,
  // generate an overflow flag. This can be used to change the fiber's frame
  // separator to flag this to the receiving devices

  wire [7:0] cluster_count;
  count_clusters u_count_clusters (
    .clock4x(clock4x),
    .vpfs(vpfs),
    .cnt   (cluster_count),
    .overflow(overflow_out)
  );

  assign cluster_count_o = reset ? 0 : cluster_count;

  // the output of the overflow flag should be delayed to lineup with the outputs from the priority encoding modules
  parameter [3:0] OVERFLOW_DELAY = 7;
  SRL16E u_overflow_delay (
    .CLK (clock4x),
    .CE  (1'b1),
    .D   (overflow_out),
    .Q   (overflow_dly),
    .A0  (OVERFLOW_DELAY[0]),
    .A1 ( OVERFLOW_DELAY[1]),
    .A2 ( OVERFLOW_DELAY[2]),
    .A3 ( OVERFLOW_DELAY[3])
  );

  reg overflow_ff = 0;
  always @(posedge clock4x)
    overflow_ff <= (reset) ? 1'b0 : overflow_dly;
  assign overflow = overflow_ff;

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
      assign cluster[icluster] = {cnt_encoder[icluster], adr_encoder[icluster] };
    end
  endgenerate

  always @(posedge clock4x) begin
         cluster0 <= (reset) ? {3'd0,11'h7FE} : cluster[0];
         cluster1 <= (reset) ? {3'd0,11'h7FE} : cluster[1];
         cluster2 <= (reset) ? {3'd0,11'h7FE} : cluster[2];
         cluster3 <= (reset) ? {3'd0,11'h7FE} : cluster[3];
         cluster4 <= (reset) ? {3'd0,11'h7FE} : cluster[4];
         cluster5 <= (reset) ? {3'd0,11'h7FE} : cluster[5];
         cluster6 <= (reset) ? {3'd0,11'h7FE} : cluster[6];
         cluster7 <= (reset) ? {3'd0,11'h7FE} : cluster[7];
  end

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
