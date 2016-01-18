`timescale 1ns / 100 ps

module first8of1536 (
    input clock4x,
    input global_reset,

    input [3:0] latch_delay,
    input       latch_in,

    input  [1536  -1:0] vpfs,
    input  [1536*3-1:0] cnts,

    output reg [2:0]      cnt0,
    output reg [2:0]      cnt1,
    output reg [2:0]      cnt2,
    output reg [2:0]      cnt3,
    output reg [2:0]      cnt4,
    output reg [2:0]      cnt5,
    output reg [2:0]      cnt6,
    output reg [2:0]      cnt7,

    output reg [10:0]      adr0,
    output reg [10:0]      adr1,
    output reg [10:0]      adr2,
    output reg [10:0]      adr3,
    output reg [10:0]      adr4,
    output reg [10:0]      adr5,
    output reg [10:0]      adr6,
    output reg [10:0]      adr7
);

//----------------------------------------------------------------------------------------------------------------------
// Interconnects
//----------------------------------------------------------------------------------------------------------------------

  wire [1535:0] vpfs_truncated;
  wire   [10:0] adr_enc;
  wire   [2:0] cnt_enc;

  (* KEEP = "TRUE" *)
  (* shreg_extract = "no" *)
  reg [1535:0] vpfs_in;
  always @(posedge clock4x) begin
    if   (global_reset) vpfs_in <= 1536'd0;
    else                vpfs_in <= vpfs;
  end


//   //----------------------------------------------------------------------------------------------------------------------
//   // reset
//   //----------------------------------------------------------------------------------------------------------------------
//
//     SRL16E #(.INIT(16'hffff)) u_reset (.CLK(clock4x),.CE(1'b1),.D(global_reset),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(reset_dly));
//     reg reset=1;
//     always @(posedge clock4x) reset <= reset_dly;

//----------------------------------------------------------------------------------------------------------------------
// latch_enable
//----------------------------------------------------------------------------------------------------------------------

  (* max_fanout = 100 *) reg latch_en=0;
  wire [3:0] delay = latch_delay + 4'd4;
  SRL16E u_latchdly (.CLK(clock4x),.CE(1'b1),.D(latch_in),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(latch_dly));
  always @(posedge clock4x) begin
    latch_en <= (latch_dly);
  end

  //------------------
  // cluster truncator
  //------------------

  truncate_clusters u_truncate (
    .clock        (clock4x),
    .global_reset (global_reset),
    .latch_delay  (latch_delay+4'd1),
    .latch_in     (latch_in),
    .vpfs_in      (vpfs_in),
    .vpfs_out     (vpfs_truncated)
  );

  //--------------------------
  // 1536-bit priority encoder
  //--------------------------

  priority1536 u_priority (
    .clock        (clock4x),       // IN  160 MHz clock
    .global_reset (global_reset),
    .latch_delay  (4'd2), // this delay should be tuned such that the delayed latch_en in the priority encoder causes
    .latch_in     (latch_in),
    .vpfs_in      (vpfs_truncated), // IN  1536   bit cluster inputs
    .cnts_in      (cnts),           // IN  1536*3 bit cluster counts
    .cnt          (cnt_enc ),       // OUT 11-bit counts    of first found cluster
    .adr          (adr_enc )        // OUT 11-bit addresses of first found cluster
  );

//------------------------------------------------------------------------------------------------------------------
// Latch addresses for output
//------------------------------------------------------------------------------------------------------------------

  parameter MXADRBITS = 11;
  parameter MXCNTBITS = 3;

  reg [MXADRBITS*8-1:0] adr_sr;
  reg [MXCNTBITS*8-1:0] cnt_sr;

  always @(posedge clock4x) begin
    cnt_sr <= {cnt_sr[MXCNTBITS*7-1:0], cnt_enc};
    adr_sr <= {adr_sr[MXADRBITS*7-1:0], adr_enc};
  end

//-------------------------------------------------------------------------------------------------------------------
// Outputs
// ------------------------------------------------------------------------------------------------------------------


  always @(posedge clock4x) begin
    if (latch_en) begin
      adr7 <= adr_sr[MXADRBITS*1-1:MXADRBITS*0] ;
      adr6 <= adr_sr[MXADRBITS*2-1:MXADRBITS*1] ;
      adr5 <= adr_sr[MXADRBITS*3-1:MXADRBITS*2] ;
      adr4 <= adr_sr[MXADRBITS*4-1:MXADRBITS*3] ;
      adr3 <= adr_sr[MXADRBITS*5-1:MXADRBITS*4] ;
      adr2 <= adr_sr[MXADRBITS*6-1:MXADRBITS*5] ;
      adr1 <= adr_sr[MXADRBITS*7-1:MXADRBITS*6] ;
      adr0 <= adr_sr[MXADRBITS*8-1:MXADRBITS*7] ;

      cnt7 <= cnt_sr[MXCNTBITS*1-1:MXCNTBITS*0] ;
      cnt6 <= cnt_sr[MXCNTBITS*2-1:MXCNTBITS*1] ;
      cnt5 <= cnt_sr[MXCNTBITS*3-1:MXCNTBITS*2] ;
      cnt4 <= cnt_sr[MXCNTBITS*4-1:MXCNTBITS*3] ;
      cnt3 <= cnt_sr[MXCNTBITS*5-1:MXCNTBITS*4] ;
      cnt2 <= cnt_sr[MXCNTBITS*6-1:MXCNTBITS*5] ;
      cnt1 <= cnt_sr[MXCNTBITS*7-1:MXCNTBITS*6] ;
      cnt0 <= cnt_sr[MXCNTBITS*8-1:MXCNTBITS*7] ;
    end
  end

  wire [MXADRBITS-1:0] adr [7:0];
  wire [MXCNTBITS-1:0] cnt [7:0];

  assign adr[7] = adr_sr[MXADRBITS*1-1:MXADRBITS*0] ;
  assign adr[6] = adr_sr[MXADRBITS*2-1:MXADRBITS*1] ;
  assign adr[5] = adr_sr[MXADRBITS*3-1:MXADRBITS*2] ;
  assign adr[4] = adr_sr[MXADRBITS*4-1:MXADRBITS*3] ;
  assign adr[3] = adr_sr[MXADRBITS*5-1:MXADRBITS*4] ;
  assign adr[2] = adr_sr[MXADRBITS*6-1:MXADRBITS*5] ;
  assign adr[1] = adr_sr[MXADRBITS*7-1:MXADRBITS*6] ;
  assign adr[0] = adr_sr[MXADRBITS*8-1:MXADRBITS*7] ;

  assign cnt[7] = cnt_sr[MXCNTBITS*1-1:MXCNTBITS*0] ;
  assign cnt[6] = cnt_sr[MXCNTBITS*2-1:MXCNTBITS*1] ;
  assign cnt[5] = cnt_sr[MXCNTBITS*3-1:MXCNTBITS*2] ;
  assign cnt[4] = cnt_sr[MXCNTBITS*4-1:MXCNTBITS*3] ;
  assign cnt[3] = cnt_sr[MXCNTBITS*5-1:MXCNTBITS*4] ;
  assign cnt[2] = cnt_sr[MXCNTBITS*6-1:MXCNTBITS*5] ;
  assign cnt[1] = cnt_sr[MXCNTBITS*7-1:MXCNTBITS*6] ;
  assign cnt[0] = cnt_sr[MXCNTBITS*8-1:MXCNTBITS*7] ;

//----------------------------------------------------------------------------------------------------------------------
endmodule
// ---------------------------------------------------------------------------------------------------------------------
