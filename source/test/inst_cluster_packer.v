module inst_cluster_packer (
  input  clock4x,

  input  reset,

  input  [15:0] vfat0,
  input  [15:0] vfat1,
  input  [15:0] vfat2,
  input  [15:0] vfat3,
  input  [15:0] vfat4,
  input  [15:0] vfat5,
  input  [15:0] vfat6,
  input  [15:0] vfat7,
  input  [15:0] vfat8,
  input  [15:0] vfat9,
  input  [15:0] vfat10,
  input  [15:0] vfat11,
  input  [15:0] vfat12,
  input  [15:0] vfat13,
  input  [15:0] vfat14,
  input  [15:0] vfat15,
  input  [15:0] vfat16,
  input  [15:0] vfat17,
  input  [15:0] vfat18,
  input  [15:0] vfat19,
  input  [15:0] vfat20,
  input  [15:0] vfat21,
  input  [15:0] vfat22,
  input  [15:0] vfat23,

  input truncate_clusters,

  output reg [13:0] cluster0,
  output reg [13:0] cluster1,
  output reg [13:0] cluster2,
  output reg [13:0] cluster3,
  output reg [13:0] cluster4,
  output reg [13:0] cluster5,
  output reg [13:0] cluster6,
  output reg [13:0] cluster7
);

//synthesis attribute ALLCLOCKNETS of inst_cluster_packer is ""

//  mmcm_gen clockgen (
//    // Clock in ports
//    .CLK_IN1(lhc_clock),      // IN
//
//    // Clock out ports
//    .CLK_OUT1(clock1x),     // OUT
//    .CLK_OUT2(clock2x),     // OUT
//    .CLK_OUT3(clock4x),     // OUT
//    .CLK_OUT4(clock8x),     // OUT
//
//    // Status and control signals
//    .RESET(1'b0),// IN
//    .LOCKED()
//  );      // OUT

wire [15:0] vfat [23:0];
assign vfat[0]   =  vfat0;
assign vfat[1]   =  vfat1;
assign vfat[2]   =  vfat2;
assign vfat[3]   =  vfat3;
assign vfat[4]   =  vfat4;
assign vfat[5]   =  vfat5;
assign vfat[6]   =  vfat6;
assign vfat[7]   =  vfat7;
assign vfat[8]   =  vfat8;
assign vfat[9]   =  vfat9;
assign vfat[10]  =  vfat10;
assign vfat[11]  =  vfat11;
assign vfat[12]  =  vfat12;
assign vfat[13]  =  vfat13;
assign vfat[14]  =  vfat14;
assign vfat[15]  =  vfat15;
assign vfat[16]  =  vfat16;
assign vfat[17]  =  vfat17;
assign vfat[18]  =  vfat18;
assign vfat[19]  =  vfat19;
assign vfat[20]  =  vfat20;
assign vfat[21]  =  vfat21;
assign vfat[22]  =  vfat22;
assign vfat[23]  =  vfat23;

reg [15:0] w0 [23:0];
reg [15:0] w1 [23:0];
reg [15:0] w2 [23:0];
reg [15:0] w3 [23:0];
reg [15:0] w4 [23:0];
reg [15:0] w5 [23:0];
reg [15:0] w6 [23:0];
reg [15:0] w7 [23:0];

reg [63:0] vfat_sbit [23:0];

wire [1535:0] vpf;
reg  [1535:0] vpf_ff;

(* max_fanout = 15 *) reg [1:0] bytecnt=0; // synthesis attribute keep of bytecnt is true;

genvar ivfat;
generate
for (ivfat=0; ivfat<24; ivfat=ivfat+1) begin: fatloop

  always @(posedge clock4x) begin
    bytecnt <= bytecnt + 1'b1;
  end

  always @(posedge clock4x) begin
  case (bytecnt)
    3'd0: w0[ivfat]        <= vfat[ivfat];
    3'd1: w1[ivfat]        <= vfat[ivfat];
    3'd2: w2[ivfat]        <= vfat[ivfat];
    3'd3: w3[ivfat]        <= vfat[ivfat];
  endcase
  end

  always @(posedge clock4x) begin
    if (bytecnt==3'd0)
      vfat_sbit[ivfat] <= {w3[ivfat], w2[ivfat], w1[ivfat], w0[ivfat]};
  end

end
endgenerate


wire [13:0] cluster    [7:0];

cluster_packer u_cluster_packer (
    .clock4x(clock4x),

    .global_reset (reset),

    .vfat0  (vfat_sbit[0]),
    .vfat1  (vfat_sbit[1]),
    .vfat2  (vfat_sbit[2]),
    .vfat3  (vfat_sbit[3]),
    .vfat4  (vfat_sbit[4]),
    .vfat5  (vfat_sbit[5]),
    .vfat6  (vfat_sbit[6]),
    .vfat7  (vfat_sbit[7]),
    .vfat8  (vfat_sbit[8]),
    .vfat9  (vfat_sbit[9]),
    .vfat10 (vfat_sbit[10]),
    .vfat11 (vfat_sbit[11]),
    .vfat12 (vfat_sbit[12]),
    .vfat13 (vfat_sbit[13]),
    .vfat14 (vfat_sbit[14]),
    .vfat15 (vfat_sbit[15]),
    .vfat16 (vfat_sbit[16]),
    .vfat17 (vfat_sbit[17]),
    .vfat18 (vfat_sbit[18]),
    .vfat19 (vfat_sbit[19]),
    .vfat20 (vfat_sbit[20]),
    .vfat21 (vfat_sbit[21]),
    .vfat22 (vfat_sbit[22]),
    .vfat23 (vfat_sbit[23]),

    .truncate_clusters (truncate_clusters),

    .cluster0 (cluster[0]),
    .cluster1 (cluster[1]),
    .cluster2 (cluster[2]),
    .cluster3 (cluster[3]),
    .cluster4 (cluster[4]),
    .cluster5 (cluster[5]),
    .cluster6 (cluster[6]),
    .cluster7 (cluster[7])
);

always @(posedge clock4x) begin
    cluster0 <= cluster[0];
    cluster1 <= cluster[1];
    cluster2 <= cluster[2];
    cluster3 <= cluster[3];
    cluster4 <= cluster[4];
    cluster5 <= cluster[5];
    cluster6 <= cluster[6];
    cluster7 <= cluster[7];
end

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
