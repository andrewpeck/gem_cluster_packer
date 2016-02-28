`timescale 1ns / 100 ps


module tb_cluster_packer;

clockgen uclockgen (
  .clock40  (clock1x),
  .clock160 (clock4x)
);

STARTUPE2 startup_inst(.GSR(1'b0), .GTS(1'b0));

reg truncate_clusters=0;
reg reset;

initial begin
    reset = 1;
    # 12.5
    reset = 0;
end

//`define vfat3
//----------------------------------------------------------------------------------------------------------------------
// VFAT3
//----------------------------------------------------------------------------------------------------------------------
    `ifdef vfat3
      reg  [1535:0] sbits;
      wire [63:0] vfat_sbits [23:0]; 

      initial begin
      //    #12.5 sbits=1536'hFF0FF0FF0FF0FF0FF0FF0FF0FF;
      //    #25   sbits=1536'h0;
      //    #25   sbits=1536'hFF0FF0FF0FF0FF0FF0FF0FF0FF;
      //    #25   sbits=1536'h0;
      //    #25   sbits=1536'hFF0FF0FF0FF0FF0FF0FF0FF0FF;
      //    #25   sbits=1536'h0;
      //    #25   sbits=1536'hFF0FF0FF0FF0FF0FF0FF0FF0FF;
      //    #25   sbits=1536'h0;
      //
      //
      #12.5 sbits = {732'd0, 36'h0ff0ff0ff, 732'd0, 36'h0ff0ff0ff};
      #25   sbits = {732'd0, 36'hf0f0f0f0f, 732'd0, 36'h0f0f0f0f0};
      #25   sbits = {732'd0, 36'h555555555, 732'd0, 36'hAAAAAAAAA};
      #25   sbits = {732'd0, 36'hAAAAAAAAA, 732'd0, 36'h555555555};
      #25   sbits = {732'd0, 36'h555555555, 732'd0, 36'hAAAAAAAAA};
      #25   sbits = {1536'd0};
      #25   sbits = {1536'd2};
      #25   sbits = {1536'd4};
      #25   sbits = {1536'd8};
      #25   sbits = {1536'd16};
      #25   sbits = {1536'd32};
      #25   sbits = {1536'd64};
      #25   sbits = {1536'd128};
      #25   sbits = {1536'd256};
      #25   sbits = {1536'd512};
      #25   sbits = {1536'd1024};
      #25   sbits = {48{$random}};
      #25   sbits = {48{$random}};
      #25   sbits = {48{$random}};
      #25   sbits = {48{$random}};
      #25   sbits = {48{$random}};
      //#25   sbits = {732'd0, 36'hAAAAAAAAA, 732'd0, 36'h555555555};
      //#25   sbits = {732'd0, 36'h555555555, 732'd0, 36'hAAAAAAAAA};
      //#25   sbits = {732'd0, 36'hAAAAAAAAA, 732'd0, 36'h555555555};
      //#25   sbits = {732'd0, 36'h555555555, 732'd0, 36'hAAAAAAAAA};
      //#25   sbits = {732'd0, 36'hAAAAAAAAA, 732'd0, 36'h555555555};
      //#25   sbits = {732'd0, 36'h555555555, 732'd0, 36'hAAAAAAAAA};
      //#25   sbits = {732'd0, 36'hAAAAAAAAA, 732'd0, 36'h555555555};
      //#25   sbits = {732'd0, 36'h555555555, 732'd0, 36'hAAAAAAAAA};
      #25   sbits = { {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011} };
      #25   sbits = {1536'd0};
      #25   sbits = { {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011} };
      #25   sbits = {1536'd0};
      #25   sbits = { {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011} };
      #25   sbits = {1536'd0};
      #25   sbits = { {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011}, {184'd0,8'b00000011} };
      #25   sbits = {1536'd0};
      //#25   sbits = {
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000011}
      //      };
      //#25   sbits = {1536'd0};
      //#25   sbits = {
      //        {184'd0,8'b11111111},
      //        {184'd0,8'b01111111},
      //        {184'd0,8'b00111111},
      //        {184'd0,8'b00011111},
      //        {184'd0,8'b00001111},
      //        {184'd0,8'b00000111},
      //        {184'd0,8'b00000011},
      //        {184'd0,8'b00000001}
      //      };
      //#25   sbits = {1536'd0};
      //#25   sbits = {1500'd0, 36'b000000000000000000000000000000000001};  // adr=0,  cnt=0
      //#25   sbits = {1500'd0, 36'b000000000000000000000000000000000010};  // adr=1,  cnt=0
      //#25   sbits = {1500'd0, 36'b000000000000000000000000000000001100};  // adr=2,  cnt=1,
      //#25   sbits = {1500'd0, 36'b000000000000000000000000000000011000};  // adr=3,  cnt=1,
      //#25   sbits = {1500'd0, 36'b000000000000000000000000000001110000};  // adr=4,  cnt=2,
      //#25   sbits = {1500'd0, 36'b000000000000000000000000000011100000};  // adr=5,  cnt=2,
      //#25   sbits = {1500'd0, 36'b000000000000000000000000001111000000};  // adr=6,  cnt=3,
      //#25   sbits = {1500'd0, 36'b000000000000000000000000011110000000};  // adr=7,  cnt=3,
      //#25   sbits = {1500'd0, 36'b000000000000000000000001111100000000};  // adr=8,  cnt=4,
      //#25   sbits = {1500'd0, 36'b000000000000000000000011111000000000};  // adr=9,  cnt=4,
      //#25   sbits = {1500'd0, 36'b000000000000000000001111110000000000};  // adr=10, cnt=5,
      //#25   sbits = {1500'd0, 36'b000000000000000000011111100000000000};  // adr=11, cnt=5,
      //#25   sbits = {1500'd0, 36'b000000000000000001111111000000000000};  // adr=12, cnt=6
      //#25   sbits = {1500'd0, 36'b000000000000000011111110000000000000};  // adr=13, cnt=6,
      //#25   sbits = {1500'd0, 36'b000000000000001111111100000000000000};  // adr=14, cnt=7
      //#25   sbits = {1500'd0, 36'b000000000000011111111000000000000000};  // adr=15, cnt=7
  end

  genvar ivfat;
  generate
    for (ivfat=0; ivfat<24; ivfat=ivfat+1) begin: vfat_loop
    assign vfat_sbits[ivfat] = sbits [(ivfat+1)*64-1:(ivfat*64)]; 
    end
  endgenerate

  //--------------------------------------------------------------------------------------------------------------------
  // VFAT 2 
  //--------------------------------------------------------------------------------------------------------------------



  `else

    reg  [191:0] fat2_bits=0;

    initial begin
      #12.5
      #25 fat2_bits = 192'h55555555;
      #25 fat2_bits = 192'haaaaaaaa;
      #25 fat2_bits = -1;
      #25 fat2_bits = 192'h0;
      #25 fat2_bits = {144'h0, 24'h555555, 24'b0};
      #25 fat2_bits = {144'h0, 24'hAAAAAA, 24'b0};
    end

    wire [7:0] vfat_sbits [23:0]; 
    genvar ivfat;
    generate
    for (ivfat=0; ivfat<24; ivfat=ivfat+1) begin: vfat_loop
      assign vfat_sbits[ivfat] = fat2_bits [(ivfat+1)*8-1:(ivfat*8)]; 
    end
    endgenerate

  `endif

//----------------------------------------------------------------------------------------------------------------------
// Common Components
//----------------------------------------------------------------------------------------------------------------------

wire [13:0] cluster [7:0];

`ifdef vfat3 cluster_packer       u_cluster_packer 
`else        cluster_packer_vfat2 u_cluster_packer 
`endif (
  .clock4x(clock4x),

  .global_reset (reset),

  .vfat0  (vfat_sbits[0]),
  .vfat1  (vfat_sbits[1]),
  .vfat2  (vfat_sbits[2]),
  .vfat3  (vfat_sbits[3]),
  .vfat4  (vfat_sbits[4]),
  .vfat5  (vfat_sbits[5]),
  .vfat6  (vfat_sbits[6]),
  .vfat7  (vfat_sbits[7]),
  .vfat8  (vfat_sbits[8]),
  .vfat9  (vfat_sbits[9]),
  .vfat10 (vfat_sbits[10]),
  .vfat11 (vfat_sbits[11]),
  .vfat12 (vfat_sbits[12]),
  .vfat13 (vfat_sbits[13]),
  .vfat14 (vfat_sbits[14]),
  .vfat15 (vfat_sbits[15]),
  .vfat16 (vfat_sbits[16]),
  .vfat17 (vfat_sbits[17]),
  .vfat18 (vfat_sbits[18]),
  .vfat19 (vfat_sbits[19]),
  .vfat20 (vfat_sbits[20]),
  .vfat21 (vfat_sbits[21]),
  .vfat22 (vfat_sbits[22]),
  .vfat23 (vfat_sbits[23]),

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


wire  [2:0] cnt [7:0];
wire [10:0] adr [7:0];

assign cnt[0] = cluster[0][13:11];
assign cnt[1] = cluster[1][13:11];
assign cnt[2] = cluster[2][13:11];
assign cnt[3] = cluster[3][13:11];
assign cnt[4] = cluster[4][13:11];
assign cnt[5] = cluster[5][13:11];
assign cnt[6] = cluster[6][13:11];
assign cnt[7] = cluster[7][13:11];

assign adr[0] = cluster[0][10:0];
assign adr[1] = cluster[1][10:0];
assign adr[2] = cluster[2][10:0];
assign adr[3] = cluster[3][10:0];
assign adr[4] = cluster[4][10:0];
assign adr[5] = cluster[5][10:0];
assign adr[6] = cluster[6][10:0];
assign adr[7] = cluster[7][10:0];


//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
