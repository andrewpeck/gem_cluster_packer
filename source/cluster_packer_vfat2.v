module cluster_packer_vfat2 (
    input  clock4x,
    input  global_reset,
    input  truncate_clusters,

    input  [7:0] vfat0,
    input  [7:0] vfat1,
    input  [7:0] vfat2,
    input  [7:0] vfat3,
    input  [7:0] vfat4,
    input  [7:0] vfat5,
    input  [7:0] vfat6,
    input  [7:0] vfat7,
    input  [7:0] vfat8,
    input  [7:0] vfat9,
    input  [7:0] vfat10,
    input  [7:0] vfat11,
    input  [7:0] vfat12,
    input  [7:0] vfat13,
    input  [7:0] vfat14,
    input  [7:0] vfat15,
    input  [7:0] vfat16,
    input  [7:0] vfat17,
    input  [7:0] vfat18,
    input  [7:0] vfat19,
    input  [7:0] vfat20,
    input  [7:0] vfat21,
    input  [7:0] vfat22,
    input  [7:0] vfat23,

    output [13:0] cluster0,
    output [13:0] cluster1,
    output [13:0] cluster2,
    output [13:0] cluster3,
    output [13:0] cluster4,
    output [13:0] cluster5,
    output [13:0] cluster6,
    output [13:0] cluster7,

    output overflow
); 

wire [7:0] vfat2_sbits [23:0];

assign vfat2_sbits[0]   =  vfat0 ; 
assign vfat2_sbits[1]   =  vfat1 ; 
assign vfat2_sbits[2]   =  vfat2 ; 
assign vfat2_sbits[3]   =  vfat3 ; 
assign vfat2_sbits[4]   =  vfat4 ; 
assign vfat2_sbits[5]   =  vfat5 ; 
assign vfat2_sbits[6]   =  vfat6 ; 
assign vfat2_sbits[7]   =  vfat7 ; 
assign vfat2_sbits[8]   =  vfat8 ; 
assign vfat2_sbits[9]   =  vfat9 ; 
assign vfat2_sbits[10]  =  vfat10; 
assign vfat2_sbits[11]  =  vfat11; 
assign vfat2_sbits[12]  =  vfat12; 
assign vfat2_sbits[13]  =  vfat13; 
assign vfat2_sbits[14]  =  vfat14; 
assign vfat2_sbits[15]  =  vfat15; 
assign vfat2_sbits[16]  =  vfat16; 
assign vfat2_sbits[17]  =  vfat17; 
assign vfat2_sbits[18]  =  vfat18; 
assign vfat2_sbits[19]  =  vfat19; 
assign vfat2_sbits[20]  =  vfat20; 
assign vfat2_sbits[21]  =  vfat21; 
assign vfat2_sbits[22]  =  vfat22; 
assign vfat2_sbits[23]  =  vfat23; 

wire [63:0] vfat3_sbits [23:0]; 

genvar ibit;
genvar ivfat;
generate
  for (ivfat=0; ivfat<24; ivfat=ivfat+1) begin: vfat_loop
    for (ibit=0; ibit<8; ibit=ibit+1) begin: bit_loop
      assign  vfat3_sbits[ivfat][(ibit+1)*8-1:ibit*8] = {7'b0,vfat2_sbits[ivfat][ibit]};
    end
  end
endgenerate

cluster_packer #(.VFAT_V2(1)) u_cluster_packer (
    .clock4x(clock4x),

    .global_reset (global_reset),

    .vfat0  (vfat3_sbits[0]),
    .vfat1  (vfat3_sbits[1]),
    .vfat2  (vfat3_sbits[2]),
    .vfat3  (vfat3_sbits[3]),
    .vfat4  (vfat3_sbits[4]),
    .vfat5  (vfat3_sbits[5]),
    .vfat6  (vfat3_sbits[6]),
    .vfat7  (vfat3_sbits[7]),
    .vfat8  (vfat3_sbits[8]),
    .vfat9  (vfat3_sbits[9]),
    .vfat10 (vfat3_sbits[10]),
    .vfat11 (vfat3_sbits[11]),
    .vfat12 (vfat3_sbits[12]),
    .vfat13 (vfat3_sbits[13]),
    .vfat14 (vfat3_sbits[14]),
    .vfat15 (vfat3_sbits[15]),
    .vfat16 (vfat3_sbits[16]),
    .vfat17 (vfat3_sbits[17]),
    .vfat18 (vfat3_sbits[18]),
    .vfat19 (vfat3_sbits[19]),
    .vfat20 (vfat3_sbits[20]),
    .vfat21 (vfat3_sbits[21]),
    .vfat22 (vfat3_sbits[22]),
    .vfat23 (vfat3_sbits[23]),

    .truncate_clusters (truncate_clusters),

    .cluster0 (cluster0),
    .cluster1 (cluster1),
    .cluster2 (cluster2),
    .cluster3 (cluster3),
    .cluster4 (cluster4),
    .cluster5 (cluster5),
    .cluster6 (cluster6),
    .cluster7 (cluster7), 

    .overflow (overflow)
);

endmodule
