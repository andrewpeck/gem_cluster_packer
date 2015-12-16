module inst_first8of1536 (
  input  lhc_clock,

  input  reset,

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

  output [10:0] adr_out0,
  output [10:0] adr_out1,
  output [10:0] adr_out2,
  output [10:0] adr_out3,
  output [10:0] adr_out4,
  output [10:0] adr_out5,
  output [10:0] adr_out6,
  output [10:0] adr_out7

);

mmcm_gen clockgen (
  // Clock in ports
  .CLK_IN1(lhc_clock),      // IN

  // Clock out ports
  //.CLK_OUT1(clock1x),     // OUT
  .CLK_OUT2(clock2x),     // OUT
  .CLK_OUT3(clock4x),     // OUT
  .CLK_OUT4(clock8x),     // OUT

  // Status and control signals
  .RESET(1'b0),// IN
  .LOCKED()
);      // OUT


wire [7 :0] vfat [23:0];
assign vfat[0] = vfat0;
assign vfat[1] = vfat1;
assign vfat[2] = vfat2;
assign vfat[3] = vfat3;
assign vfat[4] = vfat4;
assign vfat[5] = vfat5;
assign vfat[6] = vfat6;
assign vfat[7] = vfat7;
assign vfat[8] = vfat8;
assign vfat[9] = vfat9;
assign vfat[10] = vfat10;
assign vfat[11] = vfat11;
assign vfat[12] = vfat12;
assign vfat[13] = vfat13;
assign vfat[14] = vfat14;
assign vfat[15] = vfat15;
assign vfat[16] = vfat16;
assign vfat[17] = vfat17;
assign vfat[18] = vfat18;
assign vfat[19] = vfat19;
assign vfat[20] = vfat20;
assign vfat[21] = vfat21;
assign vfat[22] = vfat22;
assign vfat[23] = vfat23;

reg [7:0] w0 [23:0];
reg [7:0] w1 [23:0];
reg [7:0] w2 [23:0];
reg [7:0] w3 [23:0];
reg [7:0] w4 [23:0];
reg [7:0] w5 [23:0];
reg [7:0] w6 [23:0];
reg [7:0] w7 [23:0];

reg [63:0] vfat_sbit [23:0];

wire [1535:0] vpf;
reg  [1535:0] vpf_ff;

(* max_fanout = 15 *) reg [2:0] bytecnt; // synthesis attribute keep of bytecnt is true;

genvar ivfat;
generate
for (ivfat=0; ivfat<24; ivfat=ivfat+1) begin: fatloop

  always @(posedge clock8x) begin
    bytecnt <= bytecnt + 1'b1;
  end

  always @(posedge clock8x) begin
  case (bytecnt)
    3'd0: w0[ivfat]        <= vfat[ivfat];
    3'd1: w1[ivfat]        <= vfat[ivfat];
    3'd2: w2[ivfat]        <= vfat[ivfat];
    3'd3: w3[ivfat]        <= vfat[ivfat];
    3'd4: w4[ivfat]        <= vfat[ivfat];
    3'd5: w5[ivfat]        <= vfat[ivfat];
    3'd6: w6[ivfat]        <= vfat[ivfat];
    3'd7: vfat_sbit[ivfat] <= {vfat[ivfat], w6[ivfat], w5[ivfat], w4[ivfat], w3[ivfat], w2[ivfat], w1[ivfat], w0[ivfat]};
  endcase
  end

end
endgenerate


assign vpf = {vfat_sbit[23], vfat_sbit[22], vfat_sbit[21], vfat_sbit[20], vfat_sbit[19], vfat_sbit[18], vfat_sbit[17], vfat_sbit[16],
              vfat_sbit[15], vfat_sbit[14], vfat_sbit[13], vfat_sbit[12], vfat_sbit[11], vfat_sbit[10], vfat_sbit[9],  vfat_sbit[8],
              vfat_sbit[7],  vfat_sbit[6],  vfat_sbit[5],  vfat_sbit[4],  vfat_sbit[3],  vfat_sbit[2],  vfat_sbit[1],  vfat_sbit[0]};

always @(posedge clock4x)  begin
  vpf_ff <= vpf;
end

wire [10:0] adr [7:0];


first8of1536_mux u_first8_mux (
  .clock4x ( clock4x),
  .global_reset   ( reset),
  .vpfs    ( vpf_ff),
  .adr0    ( adr[0]),
  .adr1    ( adr[1]),
  .adr2    ( adr[2]),
  .adr3    ( adr[3]),
  .adr4    ( adr[4]),
  .adr5    ( adr[5]),
  .adr6    ( adr[6]),
  .adr7    ( adr[7])
);

assign adr_out0 = adr[0];
assign adr_out1 = adr[1];
assign adr_out2 = adr[2];
assign adr_out3 = adr[3];
assign adr_out4 = adr[4];
assign adr_out5 = adr[5];
assign adr_out6 = adr[6];
assign adr_out7 = adr[7];

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
