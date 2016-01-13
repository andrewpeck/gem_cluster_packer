`timescale 1ns / 100 ps

//synthesis attribute ALLCLOCKNETS of truncate_clusters is "240MHz"

module truncate_clusters (
  input           clock,
  input     global_reset,

  input [3:0] delay,

  input [1535:0]  vpfs_in,

  output [1535:0] vpfs_out
);

reg [1535:0] vpf_ff;

//----------------------------------------------------------------------------------------------------------------------
// reset
//----------------------------------------------------------------------------------------------------------------------

SRL16E #(.INIT(16'hffff)) u00 (.CLK(clock),.CE(1'b1),.D(global_reset),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(reset_dly));
reg reset=1;
always @(posedge clock) reset <= reset_dly;

//----------------------------------------------------------------------------------------------------------------------
// phase
//----------------------------------------------------------------------------------------------------------------------

(* max_fanout         = 10 *)
reg latch_en;
reg [2:0] phase=3'd0;
always @(posedge clock) begin
  phase <= (reset) ? 3'd0 : phase+1'b1;
  latch_en <= (phase==3'd0);
end


//----------------------------------------------------------------------------------------------------------------------
// here we take advtange of the trick that the twos complement of a number tells us something about the position
// of the first non-zero bit in the number..
// e.g.
// let a        = 101100100
//    ~a        = 010011011  // bitwise inversion
//     b = ~a+1 = 010011100  // twos complement
//    ~b        = 101100011
//     a & b    = 000000100  // one hot of first one set
//     a &~b    = 101100000  // copy of a with the first non-zero bit set to zero
//
//----------------------------------------------------------------------------------------------------------------------


//wire [1535:0] vpfs_twos_complement_inv = ~(~vpfs_in + 1);
//wire [1535:0] vpfs_twos_complement_inv = ~((1536'b0 - vpfs_in) + 1);
//wire [1535:0] vpfs_twos_complement_inv = ~(({1536{1'b1}} ^ vpfs_in) + 1);
//wire [1535:0] vpfs_twos_complement_inv = ~(-vpfs_in);

parameter MXSEGS  = 24;
parameter SEGSIZE = 1536/MXSEGS;

wire [SEGSIZE-1:0] segment           [MXSEGS-1:0];
wire [SEGSIZE-1:0] segment_copy      [MXSEGS-1:0];
wire [SEGSIZE-1:0] segment_truncated [MXSEGS-1:0];
wire [0:0] segment_keep   [MXSEGS-1:0];
wire [0:0]         segment_active [MXSEGS-1:0];
reg [SEGSIZE-1:0] segment_ff [MXSEGS-1:0];

genvar iseg;
generate;
for (iseg=0; iseg<MXSEGS; iseg=iseg+1) begin: segloop

  // remap cluster inputs into Segments
  assign segment[iseg]        = {vpfs_in [(iseg+1)*SEGSIZE-1:iseg*SEGSIZE]};

 // mark segment as active it has any clusters
  assign segment_active[iseg] = |segment_ff[iseg];

  // copy of segment with least significant 1 removed
  assign segment_copy[iseg]      =  segment_ff[iseg] & ({SEGSIZE{segment_keep[iseg]}} | ~(~segment_ff[iseg]+1));

  always @(posedge clock) begin
    if   (latch_en) segment_ff[iseg] <= segment      [iseg];
    else            segment_ff[iseg] <= segment_copy [iseg];
  end


//  // latch segment I/O
//  assign segment_truncated[iseg] =  segment_ff[iseg] & (~(~segment_ff[iseg]+1));
//  always @(posedge clock) begin
//    if       (phase==4'd0)        segment_ff[iseg] <= segment           [iseg];
//    else if (!segment_keep[iseg]) segment_ff[iseg] <= segment_truncated [iseg];
//  end

end
endgenerate

// segments are kept (untruncated) if any preceeding segment has clusters
// assign segment_keep [31]  =  segment_active[30] | segment_active[29] | segment_active[28] | segment_active[27] | segment_active[26] | segment_active[25] | segment_active[24] | segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [30]  =  segment_active[29] | segment_active[28] | segment_active[27] | segment_active[26] | segment_active[25] | segment_active[24] | segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [29]  =  segment_active[28] | segment_active[27] | segment_active[26] | segment_active[25] | segment_active[24] | segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [28]  =  segment_active[27] | segment_active[26] | segment_active[25] | segment_active[24] | segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [27]  =  segment_active[26] | segment_active[25] | segment_active[24] | segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [26]  =  segment_active[25] | segment_active[24] | segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [25]  =  segment_active[24] | segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [24]  =  segment_active[23] | segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [23]  =  segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [22]  =  segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [21]  =  segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [20]  =  segment_active[19] | segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [19]  =  segment_active[18] | segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [18]  =  segment_active[17] | segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [17]  =  segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [16]  =  segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [15]  =  segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [14]  =  segment_active[13] | segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [13]  =  segment_active[12] | segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [12]  =  segment_active[11] | segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [11]  =  segment_active[10] | segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [10]  =  segment_active[9]  | segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [9]   =  segment_active[8]  | segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [8]   =  segment_active[7]  | segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [7]   =  segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [6]   =  segment_active[5]  | segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [5]   =  segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [4]   =  segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [3]   =  segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [2]   =  segment_active[1]  | segment_active[0];
// assign segment_keep [1]   =  segment_active[0];
// assign segment_keep [0]   =  0;

// assign segment_keep [23]  =  segment_active[22] | segment_active[21] | segment_active[20] | segment_keep[20];
// assign segment_keep [22]  =  segment_active[21] | segment_active[20]                      | segment_keep[20];
// assign segment_keep [21]  =  segment_active[20]                                           | segment_keep[20];
// assign segment_keep [20]  =  segment_active[19]                                           | segment_keep[19];
//
// assign segment_keep [19]  =  segment_active[18] | segment_active[17] | segment_active[16] | segment_keep[16];
// assign segment_keep [18]  =  segment_active[17] | segment_active[16]                      | segment_keep[16];
// assign segment_keep [17]  =  segment_active[16]                                           | segment_keep[16];
// assign segment_keep [16]  =  segment_active[15]                                           | segment_keep[15];
//
// assign segment_keep [15]  =  segment_active[14] | segment_active[13] | segment_active[12] | segment_keep[12];
// assign segment_keep [14]  =  segment_active[13] | segment_active[12]                      | segment_keep[12];
// assign segment_keep [13]  =  segment_active[12]                                           | segment_keep[12];
// assign segment_keep [12]  =  segment_active[11]                                           | segment_keep[11];
//
// assign segment_keep [11]  =  segment_active[10] | segment_active[9]  | segment_active[8]  | segment_keep[8];
// assign segment_keep [10]  =  segment_active[9]  | segment_active[8]                       | segment_keep[8];
// assign segment_keep [9]   =  segment_active[8]                                            | segment_keep[8];
// assign segment_keep [8]   =  segment_active[7]                                            | segment_keep[7];
//
// assign segment_keep [7]   =  segment_active[6]  | segment_active[5]  | segment_active[4]  | segment_keep[3];
// assign segment_keep [6]   =  segment_active[5]  | segment_active[4]                       | segment_keep[3];
// assign segment_keep [5]   =  segment_active[4]                                            | segment_keep[3];
// assign segment_keep [4]   =  segment_active[3]                                            | segment_keep[3];
//
// assign segment_keep [3]   =  segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [2]   =  segment_active[1]  | segment_active[0];
// assign segment_keep [1]   =  segment_active[0];
// assign segment_keep [0]   =  0;


assign segment_keep [23] =  segment_active[22]  | segment_active[21]   | segment_keep[20];
assign segment_keep [22] =  segment_active[21]                         | segment_keep[20];
assign segment_keep [21] =  segment_active[20]                         | segment_keep[20];

assign segment_keep [20] =  segment_active[19]  | segment_active[18]   | segment_keep[17];
assign segment_keep [19] =  segment_active[18]                         | segment_keep[17];
assign segment_keep [18] =  segment_active[17]                         | segment_keep[17];

assign segment_keep [17] =  segment_active[16]  | segment_active[15]   | segment_keep[14];
assign segment_keep [16] =  segment_active[15]                         | segment_keep[14];
assign segment_keep [15] =  segment_active[14]                         | segment_keep[14];

assign segment_keep [14] =  segment_active[13]  | segment_active[12]   | segment_keep[11];
assign segment_keep [13] =  segment_active[12]                         | segment_keep[11];
assign segment_keep [12] =  segment_active[11]                         | segment_keep[11];

assign segment_keep [11] =  segment_active[10]  | segment_active[9]    | segment_keep[8];
assign segment_keep [10] =  segment_active[9]                          | segment_keep[8];
assign segment_keep [9]  =  segment_active[8]                          | segment_keep[8];

assign segment_keep [8]  =  segment_active[7]  | segment_active[6]     | segment_keep[5];
assign segment_keep [7]  =  segment_active[6]                          | segment_keep[5];
assign segment_keep [6]  =  segment_active[5]                          | segment_keep[5];

assign segment_keep [5]  =  segment_active[4]  | segment_active[3]     | segment_keep[2];
assign segment_keep [4]  =  segment_active[3]                          | segment_keep[2];
assign segment_keep [3]  =  segment_active[2]                          | segment_keep[2];

assign segment_keep [2]  =  segment_active[1]  | segment_active[0];
assign segment_keep [1]  =  segment_active[0];
assign segment_keep [0]  =  0;

// assign segment_keep [23]  =  segment_active[22] | segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [22]  =  segment_active[21] | segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [21]  =  segment_active[20] | segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [20]  =  segment_active[19] | segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [19]  =  segment_active[18] | segment_active[17] | segment_keep[17];
// assign segment_keep [18]  =  segment_active[17] | segment_keep[17];
//
// assign segment_keep [17]  =  segment_active[16] | segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [16]  =  segment_active[15] | segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [15]  =  segment_active[14] | segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [14]  =  segment_active[13] | segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [13]  =  segment_active[12] | segment_active[11] | segment_keep[11];
// assign segment_keep [12]  =  segment_active[11] | segment_keep[11];
//
// assign segment_keep [11]  =  segment_active[10] | segment_active[9] | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [10]  =  segment_active[9]  | segment_active[8] | segment_active[7] | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [9]   =  segment_active[8]  | segment_active[7] | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [8]   =  segment_active[7]  | segment_active[6] | segment_active[5] | segment_keep[5];
// assign segment_keep [7]   =  segment_active[6]  | segment_active[5] | segment_keep[5];
// assign segment_keep [6]   =  segment_active[5]  | segment_keep[5];
//
// assign segment_keep [5]   =  segment_active[4]  | segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [4]   =  segment_active[3]  | segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [3]   =  segment_active[2]  | segment_active[1]  | segment_active[0];
// assign segment_keep [2]   =  segment_active[1]  | segment_active[0];
// assign segment_keep [1]   =  segment_active[0];
// assign segment_keep [0]   =  0;


assign vpfs_out = {
                //  segment_ff[31], segment_ff[30], segment_ff[29], segment_ff[28],
                //  segment_ff[27], segment_ff[26], segment_ff[25], segment_ff[24],
                    segment_ff[23], segment_ff[22], segment_ff[21], segment_ff[20],
                    segment_ff[19], segment_ff[18], segment_ff[17], segment_ff[16],
                    segment_ff[15], segment_ff[14], segment_ff[13], segment_ff[12],
                    segment_ff[11], segment_ff[10], segment_ff[9],  segment_ff[8],
                    segment_ff[7],  segment_ff[6],  segment_ff[5],  segment_ff[4],
                    segment_ff[3],  segment_ff[2],  segment_ff[1],  segment_ff[0]};


//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
