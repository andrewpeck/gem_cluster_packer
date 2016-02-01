//----------------------------------------------------------------------------------------------------------------------
// truncate_clusters.v
//----------------------------------------------------------------------------------------------------------------------
//
// This module is designed to Truncate LSB 1s from a 1536 bit number, and is
// capable of running at 160 MHz.
//
// The details:
//
// At each clock cycle, the least-significant 1 becomes 0, using a simple
// property of integers: subtracting 1 from a number will always affect the
// least-significant set 1-bit. Using just arithmetic, with this trick we can
// take some starting number, and generate a copy of it that has the
// least-significant 1 changed to a zero.
//
// e.g.
// let a        = 101100100  // our starting number
//    ~a        = 010011011  // bitwise inversion
//     b = ~a+1 = 010011100  // b is exactly the twos complement of a, which we know to be the same as (-a) ! :)
//    ~b        = 101100011  //
//     a & b    = 000000100  // one hot of first one set
//     a &~b    = 101100000  // copy of a with the first non-zero bit set to zero. Voila!
//
// or as a one line expression,
//     c = a & ~(~a+1), or equivalently
//     c = a & ~(  -a), or equivalently
//     c = a & ~({1536{1'b1}}-a), etc., I'm sure there are more.
//
// But alas, the point: we can Zero out bits without knowing the position of
// the bit, So this so-called cluster-truncator can run independently of
// a priority encoder that is finding the position of the bit. This allows the
// cluster truncation to be the timing critical step (running at 160 MHz)
// while the larger amount of logic in the priority encoder can be pipelined,
// to run over 2 or 3 clock cycles, which adds an overall latency but still
// allows the priority encoding to be done at 160MHz without imposing much of
// any constraint on the priority encoding logic.
//----------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
`timescale 1ns / 100 ps
//synthesis attribute ALLCLOCKNETS of truncate_clusters is "240MHz"
//----------------------------------------------------------------------------------------------------------------------

module truncate_clusters (
  input           clock,
  input     global_reset,

  input       latch_in,
  input [3:0] latch_delay,

  input  [767:0] vpfs_in,
  output [767:0] vpfs_out
);

parameter MXSEGS  = 12;
parameter SEGSIZE = 768/MXSEGS;

// latch enable
//----------------------------------------------------------------------------------------------------------------------

//(* max_fanout = 100 *)
reg latch_en=0;
wire [3:0] latch_delay_offs = latch_delay - 1'b1;
SRL16E u_latchdly (.CLK(clock),.CE(1'b1),.D(latch_in),.A0(latch_delay_offs[0]),.A1(latch_delay_offs[1]),.A2(latch_delay_offs[2]),.A3(latch_delay_offs[3]),.Q(latch_dly));
always @(posedge clock)
  latch_en <= (latch_delay==1'b0) ? (latch_in) : (latch_dly);

wire [SEGSIZE-1:0] segment           [MXSEGS-1:0];
wire [SEGSIZE-1:0] segment_copy      [MXSEGS-1:0];
wire [0:0]         segment_keep      [MXSEGS-1:0];
wire [0:0]         segment_active    [MXSEGS-1:0];
reg  [SEGSIZE-1:0] segment_ff        [MXSEGS-1:0];

genvar iseg;
generate;
for (iseg=0; iseg<MXSEGS; iseg=iseg+1) begin: segloop
  initial segment_ff      [iseg] = {SEGSIZE{1'b0}};

  // remap cluster inputs into Segments
  assign segment[iseg]        = {vpfs_in [(iseg+1)*SEGSIZE-1:iseg*SEGSIZE]};

  // mark segment as active it has any clusters
  assign segment_active[iseg] = |segment_ff[iseg];

  // copy of segment with least significant 1 removed
  assign segment_copy[iseg]      =  segment_ff[iseg] & ({SEGSIZE{segment_keep[iseg]}} | ~(~segment_ff[iseg]+1));

  // with latch_en, our ff latches the incoming clusters, otherwise we latch the copied segments
  always @(posedge clock) begin
    if   (latch_en) segment_ff[iseg] <= segment      [iseg];
    else            segment_ff[iseg] <= segment_copy [iseg];
  end
end
endgenerate

// Segments should be kept if any preceeding segment has ANY sbit.. there are
// a lot of very different (logically equivalent) ways to write this. But
// there is a balance between logic depth and routing time that needs to be
// found.
//
//    this is the best that I've found so far, but there will probably be
//    something better. But something to keep in mind: the synthesis speed
//    estimates are not very accurate for this, since it is so dependent on
//    the post-PAR routing times.  I've seen many times that a faster
//    configuration in synthesis will be slower in post-PAR, so if you want to
//    experiment effectively you have to go through the pain of doing PAR
//    and looking at the timing report

// segments are kept (untruncated) if any preceeding segment has clusters

//251MHz
//assign segment_keep [15]  =  segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
//assign segment_keep [14]  =  segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
//assign segment_keep [13]  =  segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
//assign segment_keep [12]  =  segment_active[11] | segment_active[10] | segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
//255.448
assign segment_keep [11]  =  segment_active[10] | segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [10]  =  segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [9]   =  segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [8]   =  segment_active[7] | segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
//251.762
assign segment_keep [7]   =  segment_active[6] | segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [6]   =  segment_active[5] | segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [5]   =  segment_active[4] | segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [4]   =  segment_active[3] | segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [3]   =  segment_active[2] | segment_active[1] | segment_active[0];
assign segment_keep [2]   =  segment_active[1] | segment_active[0];
assign segment_keep [1]   =  segment_active[0];
assign segment_keep [0]   =  0;

//----------------------------------------------------------------------------------------------------------------------
// Synthesis Estimate: 80 MHz
//----------------------------------------------------------------------------------------------------------------------
// assign segment_keep [23] =  segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [22] =                       segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [21] =                                            segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [20] =                                                                 segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [19] =                                                                                      segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [18] =                                                                                                           segment_active[17] | segment_keep[17];
//
// assign segment_keep [17] =  segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [16] =                       segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];

// assign segment_keep [15] =                                            segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [14] =                                                                 segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [13] =                                                                                      segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [12] =                                                                                                           segment_active[11] | segment_keep[11];
//
//
// assign segment_keep [11] =  segment_active[10] | segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [10] =                       segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [9]  =                                           segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [8]  =                                                               segment_active[7] | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [7]  =                                                                                   segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [6]  =                                                                                                       segment_active[5] | segment_keep[5];
//
// assign segment_keep [5]  =  segment_active[4] | segment_active[3] | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [4]  =  segment_active[3] | segment_active[2] | segment_active[1]  | segment_active[0];
// assign segment_keep [3]  =  segment_active[2] | segment_active[1] | segment_active[0];
// assign segment_keep [2]  =  segment_active[1] | segment_active[0];
// assign segment_keep [1]  =  segment_active[0];
// assign segment_keep [0]  =  0;


//----------------------------------------------------------------------------------------------------------------------
// Synthesis Estimate: 232.585 MHz
//----------------------------------------------------------------------------------------------------------------------
/*
assign segment_keep [23] =  segment_active[22] | segment_active[21] | segment_active[20] | segment_keep[20];
assign segment_keep [22] =                       segment_active[21] | segment_active[20] | segment_keep[20];
assign segment_keep [21] =                                            segment_active[20] | segment_keep[20];
assign segment_keep [20] =                                            segment_active[19] | segment_keep[19];

assign segment_keep [19] =  segment_active[18] | segment_active[17] | segment_active[16] | segment_keep[16];
assign segment_keep [18] =                       segment_active[17] | segment_active[16] | segment_keep[16];
assign segment_keep [17] =                                            segment_active[16] | segment_keep[16];
assign segment_keep [16] =                                            segment_active[15] | segment_keep[15];

assign segment_keep [15] =  segment_active[14] | segment_active[13] | segment_active[12] | segment_keep[12];
assign segment_keep [14] =                       segment_active[13] | segment_active[12] | segment_keep[12];
assign segment_keep [13] =                                            segment_active[12] | segment_keep[12];
assign segment_keep [12] =                                            segment_active[11] | segment_keep[11];

assign segment_keep [11] =  segment_active[10] | segment_active[9]  | segment_active[8]  | segment_keep[8];
assign segment_keep [10] =                       segment_active[9]  | segment_active[8]  | segment_keep[8];
assign segment_keep [9]  =                                            segment_active[8]  | segment_keep[8];
assign segment_keep [8]  =                                            segment_active[7]  | segment_keep[7];

assign segment_keep [7]  =  segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_keep[4];
assign segment_keep [6]  =                       segment_active[5]  | segment_active[4]  | segment_keep[4];
assign segment_keep [5]  =                                            segment_active[4]  | segment_keep[4];
assign segment_keep [4]  =                                            segment_active[3]  | segment_keep[3];

assign segment_keep [3]  =  segment_active[2]  | segment_active[1]  | segment_active[0];
assign segment_keep [2]  =  segment_active[1]  | segment_active[0];
assign segment_keep [1]  =  segment_active[0];
assign segment_keep [0]  =  0;
*/

//----------------------------------------------------------------------------------------------------------------------
// Synthesis Estimate: 24 segments 233.645 MHz, 43MHz post-PAR (emulator-fw)
//                     16 segments 207.211 MHz
//----------------------------------------------------------------------------------------------------------------------
// failed in par :(
// assign segment_keep [31] =  segment_active[30] | segment_active[29] | segment_active[28] | segment_active[27] | segment_keep[27];
// assign segment_keep [30] =                       segment_active[29] | segment_active[28] | segment_active[27] | segment_keep[27];
// assign segment_keep [29] =                                            segment_active[28] | segment_active[27] | segment_keep[27];
// assign segment_keep [28] =                                                                 segment_active[27] | segment_keep[27];
//
// assign segment_keep [27] =  segment_active[26] | segment_active[25] | segment_active[24] | segment_active[23] | segment_keep[23];
// assign segment_keep [26] =                       segment_active[25] | segment_active[24] | segment_active[23] | segment_keep[23];
// assign segment_keep [25] =                                            segment_active[24] | segment_active[23] | segment_keep[23];
// assign segment_keep [24] =                                                                 segment_active[23] | segment_keep[23];
//
// assign segment_keep [23] =  segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_keep[19];
// assign segment_keep [22] =                       segment_active[21] | segment_active[20] | segment_active[19] | segment_keep[19];
// assign segment_keep [21] =                                            segment_active[20] | segment_active[19] | segment_keep[19];
// assign segment_keep [20] =                                                                 segment_active[19] | segment_keep[19];
//
// assign segment_keep [19] =  segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_keep[15];
// assign segment_keep [18] =                       segment_active[17] | segment_active[16] | segment_active[15] | segment_keep[15];
// assign segment_keep [17] =                                            segment_active[16] | segment_active[15] | segment_keep[15];
// assign segment_keep [16] =                                                                 segment_active[15] | segment_keep[15];

//   assign segment_keep [15] =  segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
//   assign segment_keep [14] =                       segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
//   assign segment_keep [13] =                                            segment_active[12] | segment_active[11] | segment_keep[11];
//   assign segment_keep [12] =                                                                 segment_active[11] | segment_keep[11];
//
//   assign segment_keep [11] =  segment_active[10] | segment_active[9]  | segment_active[8] | segment_active[7] | segment_keep[7];
//   assign segment_keep [10] =                       segment_active[9]  | segment_active[8] | segment_active[7] | segment_keep[7];
//   assign segment_keep [9]  =                                            segment_active[8] | segment_active[7] | segment_keep[7];
//   assign segment_keep [8]  =                                                                segment_active[7] | segment_keep[7];
//
//   assign segment_keep [7]  =  segment_active[6]  | segment_active[5]  | segment_active[4] | segment_active[3] | segment_keep[3];
//   assign segment_keep [6]  =  segment_active[5]  |                      segment_active[4] | segment_active[3] | segment_keep[3];
//   assign segment_keep [5]  =  segment_active[4]                                           | segment_active[3] | segment_keep[3];
//   assign segment_keep [4]  =                                                                segment_active[3] | segment_keep[3];
//
//   assign segment_keep [3]  =  segment_active[2]  | segment_active[1]  | segment_active[0];
//   assign segment_keep [2]  =  segment_active[1]  | segment_active[0];
//   assign segment_keep [1]  =  segment_active[0];
//   assign segment_keep [0]  =  0;


//----------------------------------------------------------------------------------------------------------------------
// Synthesis Estimate: 230.788
//----------------------------------------------------------------------------------------------------------------------

// assign segment_keep [23] =  segment_active[22] | segment_active[21]    | segment_keep[21];
// assign segment_keep [22] =  segment_active[21]                         | segment_keep[21];
// assign segment_keep [21] =  segment_active[20]                         | segment_keep[20];
//
// assign segment_keep [20] =  segment_active[19] | segment_active[18]    | segment_keep[18];
// assign segment_keep [19] =  segment_active[18]                         | segment_keep[18];
// assign segment_keep [18] =  segment_active[17]                         | segment_keep[17];
//
// assign segment_keep [17] =  segment_active[16] | segment_active[15]    | segment_keep[15];
// assign segment_keep [16] =  segment_active[15]                         | segment_keep[15];
// assign segment_keep [15] =  segment_active[14]                         | segment_keep[14];
//
// assign segment_keep [14] =  segment_active[13] | segment_active[12]    | segment_keep[12];
// assign segment_keep [13] =  segment_active[12]                         | segment_keep[12];
// assign segment_keep [12] =  segment_active[11]                         | segment_keep[11];
//
// assign segment_keep [11] =  segment_active[10] | segment_active[9]     | segment_keep[9];
// assign segment_keep [10] =  segment_active[9]                          | segment_keep[9];
// assign segment_keep [9]  =  segment_active[8]                          | segment_keep[8];
//
// assign segment_keep [8]  =  segment_active[7]  | segment_active[6]     | segment_keep[6];
// assign segment_keep [7]  =  segment_active[6]                          | segment_keep[6];
// assign segment_keep [6]  =  segment_active[5]                          | segment_keep[5];
//
// assign segment_keep [5]  =  segment_active[4]  | segment_active[3]     | segment_keep[3];
// assign segment_keep [4]  =  segment_active[3]                          | segment_keep[3];
// assign segment_keep [3]  =  segment_active[2]                          | segment_keep[2];
//
// assign segment_keep [2]  =  segment_active[1]  | segment_active[0];
// assign segment_keep [1]  =  segment_active[0];
// assign segment_keep [0]  =  0;


assign vpfs_out = { //latch_en ? vpfs_in :  { // muxing vpfs_in to the output decreases overall processing latency by 1 clock cycle
//                    segment_ff[31], segment_ff[30], segment_ff[29], segment_ff[28],
//                    segment_ff[27], segment_ff[26], segment_ff[25], segment_ff[24],
//                    segment_ff[23], segment_ff[22], segment_ff[21], segment_ff[20],
//                    segment_ff[19], segment_ff[18], segment_ff[17], segment_ff[16],
//                  segment_ff[15], segment_ff[14], segment_ff[13], segment_ff[12],
                    segment_ff[11], segment_ff[10], segment_ff[9],  segment_ff[8],
                    segment_ff[7],  segment_ff[6],  segment_ff[5],  segment_ff[4],
                    segment_ff[3],  segment_ff[2],  segment_ff[1],  segment_ff[0]};

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
