`define VFAT3 1

`ifdef VFAT3
    //$display("Compiling cluster packer for VFAT-3!");
    parameter MXSBITS    = 64;         // S-bits per vfat
`else
    //$display ("Compiling cluster packer for VFAT-2!");
    parameter MXSBITS    = 8;          // S-bits per vfat
`endif

parameter MXKEYS     = 3*MXSBITS;  // S-bits per partition
parameter MXPADS     = 24*MXSBITS; // S-bits per chamber
parameter MXROWS     = 8;          // Eta partitions per chamber
parameter MXCNTBITS  = 3;          // Number of count   bits per cluster
parameter MXADRBITS  = 11;         // Number of address bits per cluster
parameter MXCLSTBITS = 14;         // Number of total   bits per cluster
parameter MXOUTBITS  = 56;         // Number of total   bits per packet
parameter MXCLUSTERS = 8;          // Number of clusters per bx
