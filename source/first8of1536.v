`timescale 1ns / 100 ps

module first8of1536 (
    input clock4x,
    input global_reset,

    input [3:0] delay,

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
    else  vpfs_in <= vpfs;
  end

  reg [10:0] adr [7:0];
  reg [2:0]  cnt [7:0];


//----------------------------------------------------------------------------------------------------------------------
// reset
//----------------------------------------------------------------------------------------------------------------------

  SRL16E #(.INIT(16'hffff)) u00 (.CLK(clock4x),.CE(1'b1),.D(global_reset),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(reset_dly));
  reg reset=1;
  always @(posedge clock4x) reset <= reset_dly;

//----------------------------------------------------------------------------------------------------------------------
// phase counter
//----------------------------------------------------------------------------------------------------------------------

  (* max_fanout = 50 *) reg [2:0] phase=3'd0;
  always @(posedge clock4x) begin
    phase <= (reset) ? 0 : phase+1'b1;
  end

  //------------------
  // cluster truncator
  //------------------

  truncate_clusters u_truncate (
    .global_reset (global_reset),
    .clock        (clock4x),
    .delay        (delay),
    .vpfs_in      (vpfs_in),
    .vpfs_out     (vpfs_truncated)
  );

  //--------------------------
  // 1536-bit priority encoder
  //--------------------------

  priority1536 u_priority (
    .global_reset (global_reset),
    .delay (delay),
    .clock (clock4x ),       // IN  160 MHz clock
    .vpfs  (vpfs_truncated), // IN  1536   bit cluster inputs
    .cnts  (cnts),           // IN  1536*3 bit cluster counts
    .cnt   (cnt_enc ),       // OUT 11-bit counts    of first found cluster
    .adr   (adr_enc )        // OUT 11-bit addresses of first found cluster
  );

//------------------------------------------------------------------------------------------------------------------
// Latch addresses for output
//------------------------------------------------------------------------------------------------------------------

  always @(posedge clock4x) begin
    case (phase)
      3'd4: cnt[0] <= cnt_enc;
      3'd5: cnt[1] <= cnt_enc;
      3'd6: cnt[2] <= cnt_enc;
      3'd7: cnt[3] <= cnt_enc;
      3'd0: cnt[4] <= cnt_enc;
      3'd1: cnt[5] <= cnt_enc;
      3'd2: cnt[6] <= cnt_enc;
      //3'd3: cnt[7] <= cnt_enc;
    endcase

    case (phase)
      3'd4: adr[0] <= adr_enc;
      3'd5: adr[1] <= adr_enc;
      3'd6: adr[2] <= adr_enc;
      3'd7: adr[3] <= adr_enc;
      3'd0: adr[4] <= adr_enc;
      3'd1: adr[5] <= adr_enc;
      3'd2: adr[6] <= adr_enc;
      //3'd3: adr[7] <= adr_enc;
    endcase
  end

//-------------------------------------------------------------------------------------------------------------------
// Outputs
// ------------------------------------------------------------------------------------------------------------------

  always @(posedge clock4x) begin
    if (phase==3'd3) begin
      adr0 <= adr[0]  ;
      adr1 <= adr[1]  ;
      adr2 <= adr[2]  ;
      adr3 <= adr[3]  ;
      adr4 <= adr[4]  ;
      adr5 <= adr[5]  ;
      adr6 <= adr[6]  ;
      adr7 <= adr_enc ;

      cnt0 <= cnt[0]  ;
      cnt1 <= cnt[1]  ;
      cnt2 <= cnt[2]  ;
      cnt3 <= cnt[3]  ;
      cnt4 <= cnt[4]  ;
      cnt5 <= cnt[5]  ;
      cnt6 <= cnt[6]  ;
      cnt7 <= adr_enc ;
    end
  end

//----------------------------------------------------------------------------------------------------------------------
endmodule
// ---------------------------------------------------------------------------------------------------------------------
