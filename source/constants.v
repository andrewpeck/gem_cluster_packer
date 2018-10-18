// START: CLUSTER_PACKER_SETTINGS DO NOT EDIT --
`define oh_lite
//`define full_chamber_finder
`define first5
// END: CLUSTER_PACKER_SETTINGS DO NOT EDIT --

  localparam MXSBITS      = 64; // S-bits per vfat

  //--------------------------------------------------------------------------------------------------------------------
  // GE2/1
  //--------------------------------------------------------------------------------------------------------------------

  `ifdef oh_lite
      localparam OH_LITE      = 1;         //
      localparam MXKEYS       = 6*MXSBITS; // S-bits per partition
      localparam MXROWS       = 2;         // Eta partitions per chamber
      `ifdef first5                        //
      localparam MXCLUSTERS = 5;           // Number of clusters per bx
      `else                                //
      localparam MXCLUSTERS = 4;           // Number of clusters per bx
      `endif                               //

  //--------------------------------------------------------------------------------------------------------------------
  // GE1/1
  //--------------------------------------------------------------------------------------------------------------------

  `else

    localparam OH_LITE      = 0;         //
    localparam MXKEYS       = 3*MXSBITS; // Vfats  per partition
    localparam MXROWS       = 8;         // Eta partitions per chamber
    localparam MXCLUSTERS   = 8;         // Number of clusters per bx

  `endif

  //--------------------------------------------------------------------------------------------------------------------
  // Generic
  //--------------------------------------------------------------------------------------------------------------------

  localparam MXVFATS    = 24-12*OH_LITE;       // Number of VFATs
  localparam MXPADS     = (MXKEYS*MXROWS);     // S-bits per chamber
  localparam MXCNTBITS  = 3;                   // Number of count   bits per cluster
  localparam MXADRBITS  = 11;                  // Number of address bits per cluster
  localparam MXCLSTBITS = MXCNTBITS+MXADRBITS; // Number of total   bits per cluster
