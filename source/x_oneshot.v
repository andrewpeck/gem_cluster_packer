`timescale 1ns / 1ps
//`define DEBUG_X_ONESHOT 1
//------------------------------------------------------------------------------------------------------------------
// Digital One-Shot:
//    Produces 1-clock wide pulse when d goes high.
//    Waits for d to go low before re-triggering.
//
//  02/07/2002  Initial
//  09/15/2006  Mod for XST
//  01/13/2009  Mod for ISE 10.1i
//  04/26/2010  Mod for ISE 11.5
//  07/12/2010  Port to ISE 12, convert to nonblocking operators
//  09/06/2016  Mod to reduce latency by 1bx
//-----------------------------------------------------------------------------------------------------------------
  module x_oneshot (d,clock,q,enable);

  input  d;
  input  clock;
  output q;
  input  enable;

// State Machine declarations
  reg [2:0] sm;    // synthesis attribute safe_implementation of sm is "yes";
  parameter idle  =  0;
  parameter hold  =  1;

// One-shot state machine
  initial sm = idle;

  always @(posedge clock) begin
    case (sm)
      idle:    if (d) sm <= hold;
      hold:    if(!d) sm <= idle;
      default:        sm <= idle;
    endcase
  end

// Output FF
  reg  q = 0;

  always @(posedge clock) begin
    q <= d && (!enable || sm==idle);
  end

// Debug state machine display
`ifdef DEBUG_X_ONESHOT
  output [39:0] sm_dsp;
  reg    [39:0] sm_dsp;

  always @* begin
    case (sm)
      idle:   sm_dsp <= "idle ";
      hold:   sm_dsp <= "hold ";
      default sm_dsp <= "deflt";
    endcase
  end
`endif

//------------------------------------------------------------------------------------------------------------------
  endmodule
//------------------------------------------------------------------------------------------------------------------
