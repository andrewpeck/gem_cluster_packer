`timescale 1ns / 100 ps

module first8of1536 (
    input clock4x,
    input global_reset,

    input [3:0] delay,

    input  [1535:0]    vpfs,

    output reg [10:0]      adr0,
    output reg [10:0]      adr1,
    output reg [10:0]      adr2,
    output reg [10:0]      adr3,
    output reg [10:0]      adr4,
    output reg [10:0]      adr5,
    output reg [10:0]      adr6,
    output reg [10:0]      adr7
);

//-------------------------------------------------------------------------------------------------------------------
// Interconnects
// ------------------------------------------------------------------------------------------------------------------

  wire [1535:0] vpfs_truncated;
  wire   [10:0] adr_enc;

  (* KEEP = "TRUE" *)
  reg [1535:0] vpfs_in;
  always @(posedge clock4x)
    vpfs_in <= vpfs;

  reg [10:0] adr        [7:0];
  initial adr[0] = 11'h7fe;
  initial adr[1] = 11'h7fe;
  initial adr[2] = 11'h7fe;
  initial adr[3] = 11'h7fe;
  initial adr[4] = 11'h7fe;
  initial adr[5] = 11'h7fe;
  initial adr[6] = 11'h7fe;
  initial adr[7] = 11'h7fe;

//------------------------------------------------------------------------------------------------------------------
// Cluster Finders
//------------------------------------------------------------------------------------------------------------------

  // reset
  //-------------------

  SRL16E u00 (.CLK(clock4x),.CE(1'b1),.D(global_reset),.A0(delay[0]),.A1(delay[1]),.A2(delay[2]),.A3(delay[3]),.Q(reset_dly));
  reg reset;
  always @(posedge clock4x) reset <= reset_dly;

  // phase counter
  //-------------------

  (* max_fanout = 50 *) reg [2:0] phase=3'd0;
  always @(posedge clock4x) begin
    phase <= (reset) ? 3'd0 : phase+1'b1;
  end

  wire [1535:0] vpfs_enc;
  assign vpfs_enc = (phase==3'd1) ? vpfs_in : vpfs_truncated;

  truncate_clusters u_truncate (
    .global_reset (global_reset),
    .clock    (clock4x),
    .delay        (delay),
    .vpfs_in  (vpfs_in),
    .vpfs_out (vpfs_truncated)
  );

  priority1536 u_priority (
    .reset (global_reset),
    .clock (clock4x ), // IN  160 MHz clock
    .vpfs  (vpfs_enc), // IN  1536 bit S-bits input
    .adr   (adr_enc )  // OUT 11-bit flopped addrses of first found cluster
  );

//------------------------------------------------------------------------------------------------------------------
// Latch addresses for output
//------------------------------------------------------------------------------------------------------------------

  always @(posedge clock4x) begin
    case (phase)
      3'd2: adr[0] <= adr_enc;
      3'd3: adr[1] <= adr_enc;
      3'd4: adr[2] <= adr_enc;
      3'd5: adr[3] <= adr_enc;
      3'd6: adr[4] <= adr_enc;
      3'd7: adr[5] <= adr_enc;
      3'd0: adr[6] <= adr_enc;
    endcase
  end

//-------------------------------------------------------------------------------------------------------------------
// Outputs
// ------------------------------------------------------------------------------------------------------------------

  always @(posedge clock4x) begin
    if (phase==3'd1) begin
      adr0 <= adr[0]  ;
      adr1 <= adr[1]  ;
      adr2 <= adr[2]  ;
      adr3 <= adr[3]  ;
      adr4 <= adr[4]  ;
      adr5 <= adr[5]  ;
      adr6 <= adr[6]  ;
      adr7 <= adr_enc ;
    end
  end

//----------------------------------------------------------------------------------------------------------------------
endmodule
// ---------------------------------------------------------------------------------------------------------------------
