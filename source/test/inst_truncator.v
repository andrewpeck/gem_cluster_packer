module inst_truncator (
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

  output sump
);

//synthesis attribute ALLCLOCKNETS of inst_truncator is "240MHz"

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

reg latch_enable;
always @(posedge clock4x)
  latch_enable <= (bytecnt==3'd1);

wire [1535:0] vpf;
wire [1535:0] vpfs_truncated;
reg  [1535:0] vpf_ff;

(* KEEP = "TRUE" *)
(* shreg_extract = "no" *)
always @(posedge clock4x)  begin
    vpf_ff <= vpf;
end

assign vpf = {vfat_sbit[23], vfat_sbit[22], vfat_sbit[21], vfat_sbit[20], vfat_sbit[19], vfat_sbit[18], vfat_sbit[17], vfat_sbit[16],
              vfat_sbit[15], vfat_sbit[14], vfat_sbit[13], vfat_sbit[12], vfat_sbit[11], vfat_sbit[10], vfat_sbit[9],  vfat_sbit[8],
              vfat_sbit[7],  vfat_sbit[6],  vfat_sbit[5],  vfat_sbit[4],  vfat_sbit[3],  vfat_sbit[2],  vfat_sbit[1],  vfat_sbit[0]};

truncate_clusters u_truncate (
  .clock        (clock4x),
  .global_reset (1'b0),
  .latch_delay  (0),
  .latch_in     (latch_enable),
  .vpfs_in      (vpf_ff),
  .vpfs_out     (vpfs_truncated)
);

reg [23:0] sump_s1;
reg        sump_s2;

generate
for (ivfat=0; ivfat<24; ivfat=ivfat+1) begin: fatloop2
always @(posedge clock4x)  begin
  sump_s1[ivfat] <= ^(vpfs_truncated[(ivfat+1)*24-1:ivfat*24]);
end
end
endgenerate


always @(posedge clock4x)  begin
sump_s2 <=  sump_s1[23]| sump_s1[22]| sump_s1[21]| sump_s1[20]| sump_s1[19]| sump_s1[18]| sump_s1[17]| sump_s1[16]|
    sump_s1[15]| sump_s1[14]| sump_s1[13]| sump_s1[12]| sump_s1[11]| sump_s1[10]| sump_s1[9]|  sump_s1[8]|
    sump_s1[7]|  sump_s1[6]|  sump_s1[5]|  sump_s1[4]|  sump_s1[3]|  sump_s1[2]|  sump_s1[1]|  sump_s1[0];
end

assign sump = sump_s2;

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
