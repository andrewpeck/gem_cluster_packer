module merge16 (
    input clock4x,

    input [11-1:0] adr_in0,
    input [11-1:0] adr_in1,
    input [11-1:0] adr_in2,
    input [11-1:0] adr_in3,
    input [11-1:0] adr_in4,
    input [11-1:0] adr_in5,
    input [11-1:0] adr_in6,
    input [11-1:0] adr_in7,
    input [11-1:0] adr_in8,
    input [11-1:0] adr_in9,
    input [11-1:0] adr_in10,
    input [11-1:0] adr_in11,
    input [11-1:0] adr_in12,
    input [11-1:0] adr_in13,
    input [11-1:0] adr_in14,
    input [11-1:0] adr_in15,

    input [3-1:0] cnt_in0,
    input [3-1:0] cnt_in1,
    input [3-1:0] cnt_in2,
    input [3-1:0] cnt_in3,
    input [3-1:0] cnt_in4,
    input [3-1:0] cnt_in5,
    input [3-1:0] cnt_in6,
    input [3-1:0] cnt_in7,
    input [3-1:0] cnt_in8,
    input [3-1:0] cnt_in9,
    input [3-1:0] cnt_in10,
    input [3-1:0] cnt_in11,
    input [3-1:0] cnt_in12,
    input [3-1:0] cnt_in13,
    input [3-1:0] cnt_in14,
    input [3-1:0] cnt_in15,

    input [15:0] vpfs,

    output [MXADRBITS-1:0] adr0,
    output [MXADRBITS-1:0] adr1,
    output [MXADRBITS-1:0] adr2,
    output [MXADRBITS-1:0] adr3,
    output [MXADRBITS-1:0] adr4,
    output [MXADRBITS-1:0] adr5,
    output [MXADRBITS-1:0] adr6,
    output [MXADRBITS-1:0] adr7,

    output [MXCNTBITS-1:0] cnt0,
    output [MXCNTBITS-1:0] cnt1,
    output [MXCNTBITS-1:0] cnt2,
    output [MXCNTBITS-1:0] cnt3,
    output [MXCNTBITS-1:0] cnt4,
    output [MXCNTBITS-1:0] cnt5,
    output [MXCNTBITS-1:0] cnt6,
    output [MXCNTBITS-1:0] cnt7
);

parameter MXADRBITS=11;
parameter MXCNTBITS=3;

//----------------------------------------------------------------------------------------------------------------------
// vectorize inputs
//----------------------------------------------------------------------------------------------------------------------

    `ifdef debug
    reg [MXADRBITS-1:0] adr [15:0];   reg [MXCNTBITS-1:0] cnt [15:0];

    // use the inverted vpf flag to set the addresses to max value (7FF) if a valid flag wasn't found.
    // this allows us to just sort based on address (preferring smallest
    // address) and takes care automatically of flagging invalid clusters with invalid addresses
    always @(posedge clock4x) begin
     adr[0]  <= {11{~vpfs[0 ]}} | adr_in0;              cnt[0]  <= cnt_in0;
     adr[1]  <= {11{~vpfs[1 ]}} | adr_in1;              cnt[1]  <= cnt_in1;
     adr[2]  <= {11{~vpfs[2 ]}} | adr_in2;              cnt[2]  <= cnt_in2;
     adr[3]  <= {11{~vpfs[3 ]}} | adr_in3;              cnt[3]  <= cnt_in3;
     adr[4]  <= {11{~vpfs[4 ]}} | adr_in4;              cnt[4]  <= cnt_in4;
     adr[5]  <= {11{~vpfs[5 ]}} | adr_in5;              cnt[5]  <= cnt_in5;
     adr[6]  <= {11{~vpfs[6 ]}} | adr_in6;              cnt[6]  <= cnt_in6;
     adr[7]  <= {11{~vpfs[7 ]}} | adr_in7;              cnt[7]  <= cnt_in7;
     adr[8]  <= {11{~vpfs[8 ]}} | adr_in8;              cnt[8]  <= cnt_in8;
     adr[9]  <= {11{~vpfs[9 ]}} | adr_in9;              cnt[9]  <= cnt_in9;
     adr[10] <= {11{~vpfs[10]}} | adr_in10;             cnt[10] <= cnt_in10;
     adr[11] <= {11{~vpfs[11]}} | adr_in11;             cnt[11] <= cnt_in11;
     adr[12] <= {11{~vpfs[12]}} | adr_in12;             cnt[12] <= cnt_in12;
     adr[13] <= {11{~vpfs[13]}} | adr_in13;             cnt[13] <= cnt_in13;
     adr[14] <= {11{~vpfs[14]}} | adr_in14;             cnt[14] <= cnt_in14;
     adr[15] <= {11{~vpfs[15]}} | adr_in15;             cnt[15] <= cnt_in15;
   end

  `else

    wire [MXADRBITS-1:0] adr [15:0];   wire [MXCNTBITS-1:0] cnt [15:0];

    assign adr[0]  = {11{~vpfs[0 ]}} | adr_in0;             assign cnt[0]  = cnt_in0;
    assign adr[1]  = {11{~vpfs[1 ]}} | adr_in1;             assign cnt[1]  = cnt_in1;
    assign adr[2]  = {11{~vpfs[2 ]}} | adr_in2;             assign cnt[2]  = cnt_in2;
    assign adr[3]  = {11{~vpfs[3 ]}} | adr_in3;             assign cnt[3]  = cnt_in3;
    assign adr[4]  = {11{~vpfs[4 ]}} | adr_in4;             assign cnt[4]  = cnt_in4;
    assign adr[5]  = {11{~vpfs[5 ]}} | adr_in5;             assign cnt[5]  = cnt_in5;
    assign adr[6]  = {11{~vpfs[6 ]}} | adr_in6;             assign cnt[6]  = cnt_in6;
    assign adr[7]  = {11{~vpfs[7 ]}} | adr_in7;             assign cnt[7]  = cnt_in7;
    assign adr[8]  = {11{~vpfs[8 ]}} | adr_in8;             assign cnt[8]  = cnt_in8;
    assign adr[9]  = {11{~vpfs[9 ]}} | adr_in9;             assign cnt[9]  = cnt_in9;
    assign adr[10] = {11{~vpfs[10]}} | adr_in10;            assign cnt[10] = cnt_in10;
    assign adr[11] = {11{~vpfs[11]}} | adr_in11;            assign cnt[11] = cnt_in11;
    assign adr[12] = {11{~vpfs[12]}} | adr_in12;            assign cnt[12] = cnt_in12;
    assign adr[13] = {11{~vpfs[13]}} | adr_in13;            assign cnt[13] = cnt_in13;
    assign adr[14] = {11{~vpfs[14]}} | adr_in14;            assign cnt[14] = cnt_in14;
    assign adr[15] = {11{~vpfs[15]}} | adr_in15;            assign cnt[15] = cnt_in15;

  `endif

    // stage 0: sort eights (0,8), (1,9), (2,10), (3,11), (4,12), (5,13), (6,14), (7,15)
    //------------------------------------------------------------------------------------------------------------------

    wire [2:0]           cnt_s0 [15:0];
    wire [MXADRBITS-1:0] adr_s0 [15:0];

    assign {{adr_s0[0], cnt_s0[0]},  {adr_s0[8],  cnt_s0[8]}}   =  adr[0] < adr[8]  ? {{adr[0], cnt[0]}, {adr[8], cnt[8]}}   : {{adr[8],  cnt[8]},  {adr[0], cnt[0]}};
    assign {{adr_s0[1], cnt_s0[1]},  {adr_s0[9],  cnt_s0[9]}}   =  adr[1] < adr[9]  ? {{adr[1], cnt[1]}, {adr[9], cnt[9]}}   : {{adr[9],  cnt[9]},  {adr[1], cnt[1]}};
    assign {{adr_s0[2], cnt_s0[2]},  {adr_s0[10], cnt_s0[10]}}  =  adr[2] < adr[10] ? {{adr[2], cnt[2]}, {adr[10], cnt[10]}} : {{adr[10], cnt[10]}, {adr[2], cnt[2]}};
    assign {{adr_s0[3], cnt_s0[3]},  {adr_s0[11], cnt_s0[11]}}  =  adr[3] < adr[11] ? {{adr[3], cnt[3]}, {adr[11], cnt[11]}} : {{adr[11], cnt[11]}, {adr[3], cnt[3]}};
    assign {{adr_s0[4], cnt_s0[4]},  {adr_s0[12], cnt_s0[12]}}  =  adr[4] < adr[12] ? {{adr[4], cnt[4]}, {adr[12], cnt[12]}} : {{adr[12], cnt[12]}, {adr[4], cnt[4]}};
    assign {{adr_s0[5], cnt_s0[5]},  {adr_s0[13], cnt_s0[13]}}  =  adr[5] < adr[13] ? {{adr[5], cnt[5]}, {adr[13], cnt[13]}} : {{adr[13], cnt[13]}, {adr[5], cnt[5]}};
    assign {{adr_s0[6], cnt_s0[6]},  {adr_s0[14], cnt_s0[14]}}  =  adr[6] < adr[14] ? {{adr[6], cnt[6]}, {adr[14], cnt[14]}} : {{adr[14], cnt[14]}, {adr[6], cnt[6]}};
    assign {{adr_s0[7], cnt_s0[7]},  {adr_s0[15], cnt_s0[15]}}  =  adr[7] < adr[15] ? {{adr[7], cnt[7]}, {adr[15], cnt[15]}} : {{adr[15], cnt[15]}, {adr[7], cnt[7]}};

    // stage 1: sort fours (4,8), (5,9), (6,10), (7,11)
    //------------------------------------------------------------------------------------------------------------------

    reg [2:0]           cnt_s1 [15:0];
    reg [MXADRBITS-1:0] adr_s1 [15:0];

    always @(posedge clock4x) begin
           {adr_s1[0],  cnt_s1[0]} <= {adr_s0[0], cnt_s0[0]};
           {adr_s1[1],  cnt_s1[1]} <= {adr_s0[1], cnt_s0[1]};
           {adr_s1[2],  cnt_s1[2]} <= {adr_s0[2], cnt_s0[2]};
           {adr_s1[3],  cnt_s1[3]} <= {adr_s0[3], cnt_s0[3]};

           {{adr_s1[4],  cnt_s1[4]},  {adr_s1[8],   cnt_s1[8]}}  <= adr_s0[4]  < adr_s0[8]  ? {{adr_s0[4], cnt_s0[4]}, {adr_s0[8],  cnt_s0[8]}}  : {{adr_s0[8],   cnt_s0[8]},  {adr_s0[4], cnt_s0[4]}};
           {{adr_s1[5],  cnt_s1[5]},  {adr_s1[9],   cnt_s1[9]}}  <= adr_s0[5]  < adr_s0[9]  ? {{adr_s0[5], cnt_s0[5]}, {adr_s0[9],  cnt_s0[9]}}  : {{adr_s0[9],   cnt_s0[9]},  {adr_s0[5], cnt_s0[5]}};
           {{adr_s1[6],  cnt_s1[6]},  {adr_s1[10],  cnt_s1[10]}} <= adr_s0[6]  < adr_s0[10] ? {{adr_s0[6], cnt_s0[6]}, {adr_s0[10], cnt_s0[10]}} : {{adr_s0[10],  cnt_s0[10]}, {adr_s0[6], cnt_s0[6]}};
           {{adr_s1[7],  cnt_s1[7]},  {adr_s1[11],  cnt_s1[11]}} <= adr_s0[7]  < adr_s0[11] ? {{adr_s0[7], cnt_s0[7]}, {adr_s0[11], cnt_s0[11]}} : {{adr_s0[11],  cnt_s0[11]}, {adr_s0[7], cnt_s0[7]}};

           {adr_s1[12],  cnt_s1[12]} <= {adr_s0[12], cnt_s0[12]};
           {adr_s1[13],  cnt_s1[13]} <= {adr_s0[13], cnt_s0[13]};
           {adr_s1[14],  cnt_s1[14]} <= {adr_s0[14], cnt_s0[14]};
           {adr_s1[15],  cnt_s1[15]} <= {adr_s0[15], cnt_s0[15]};
    end

    // stage 2: sort twos (2,4), (3,5), (6,8), (7,9)
    //------------------------------------------------------------------------------------------------------------------

    wire [2:0]           cnt_s2 [15:0];
    wire [MXADRBITS-1:0] adr_s2 [15:0];

    assign {adr_s2[0],  cnt_s2[0]} = {adr_s1[0], cnt_s1[0]};
    assign {adr_s2[1],  cnt_s2[1]} = {adr_s1[1], cnt_s1[1]};

    assign {{adr_s2[2],  cnt_s2[2]},  {adr_s2[4],  cnt_s2[4]}}  = adr_s1[2]  < adr_s1[4]  ? {{adr_s1[2],  cnt_s1[2]},  {adr_s1[4],  cnt_s1[4]}}  : {{adr_s1[4],  cnt_s1[4]},  {adr_s1[2],  cnt_s1[2]}};
    assign {{adr_s2[3],  cnt_s2[3]},  {adr_s2[5],  cnt_s2[5]}}  = adr_s1[3]  < adr_s1[5]  ? {{adr_s1[3],  cnt_s1[3]},  {adr_s1[5],  cnt_s1[5]}}  : {{adr_s1[5],  cnt_s1[5]},  {adr_s1[3],  cnt_s1[3]}};
    assign {{adr_s2[6],  cnt_s2[6]},  {adr_s2[8],  cnt_s2[8]}}  = adr_s1[6]  < adr_s1[8]  ? {{adr_s1[6],  cnt_s1[6]},  {adr_s1[8],  cnt_s1[8]}}  : {{adr_s1[8],  cnt_s1[8]},  {adr_s1[6],  cnt_s1[6]}};
    assign {{adr_s2[7],  cnt_s2[7]},  {adr_s2[9],  cnt_s2[9]}}  = adr_s1[7]  < adr_s1[9]  ? {{adr_s1[7],  cnt_s1[7]},  {adr_s1[9],  cnt_s1[9]}}  : {{adr_s1[9],  cnt_s1[9]},  {adr_s1[7],  cnt_s1[7]}};
    assign {{adr_s2[10], cnt_s2[10]}, {adr_s2[12], cnt_s2[12]}} = adr_s1[10] < adr_s1[12] ? {{adr_s1[10], cnt_s1[10]}, {adr_s1[12], cnt_s1[12]}} : {{adr_s1[12], cnt_s1[12]}, {adr_s1[10], cnt_s1[10]}};
    assign {{adr_s2[11], cnt_s2[11]}, {adr_s2[13], cnt_s2[13]}} = adr_s1[11] < adr_s1[13] ? {{adr_s1[11], cnt_s1[11]}, {adr_s1[13], cnt_s1[13]}} : {{adr_s1[13], cnt_s1[13]}, {adr_s1[11], cnt_s1[11]}};

    assign {adr_s2[14],  cnt_s2[14]} = {adr_s1[14], cnt_s1[14]};
    assign {adr_s2[15],  cnt_s2[15]} = {adr_s1[15], cnt_s1[15]};

    // stage 3: swap odd pairs
    //------------------------------------------------------------------------------------------------------------------

    wire [2:0]           cnt_s3 [15:0];
    wire [MXADRBITS-1:0] adr_s3 [15:0];


    assign  {adr_s3[0],  cnt_s3[0]} = {adr_s2[0],  cnt_s2[0]};

    assign {{adr_s3[1],  cnt_s3[1]},  {adr_s3[2],  cnt_s3[2]}}  = adr_s2[1]  < adr_s2[2]  ? {{adr_s2[1],  cnt_s2[1]},  {adr_s2[2],  cnt_s2[2]}}  : {{adr_s2[2],  cnt_s2[2]},  {adr_s2[1],  cnt_s2[1]}};
    assign {{adr_s3[3],  cnt_s3[3]},  {adr_s3[4],  cnt_s3[4]}}  = adr_s2[3]  < adr_s2[4]  ? {{adr_s2[3],  cnt_s2[3]},  {adr_s2[4],  cnt_s2[4]}}  : {{adr_s2[4],  cnt_s2[4]},  {adr_s2[3],  cnt_s2[3]}};
    assign {{adr_s3[5],  cnt_s3[5]},  {adr_s3[6],  cnt_s3[6]}}  = adr_s2[5]  < adr_s2[6]  ? {{adr_s2[5],  cnt_s2[5]},  {adr_s2[6],  cnt_s2[6]}}  : {{adr_s2[6],  cnt_s2[6]},  {adr_s2[5],  cnt_s2[5]}};
    assign {{adr_s3[7],  cnt_s3[7]},  {adr_s3[8],  cnt_s3[8]}}  = adr_s2[7]  < adr_s2[8]  ? {{adr_s2[7],  cnt_s2[7]},  {adr_s2[8],  cnt_s2[8]}}  : {{adr_s2[8],  cnt_s2[8]},  {adr_s2[7],  cnt_s2[7]}};
    assign {{adr_s3[9],  cnt_s3[9]},  {adr_s3[10], cnt_s3[10]}} = adr_s2[9]  < adr_s2[10] ? {{adr_s2[9],  cnt_s2[9]},  {adr_s2[10], cnt_s2[10]}} : {{adr_s2[10], cnt_s2[10]}, {adr_s2[9],  cnt_s2[9]}};
    assign {{adr_s3[11], cnt_s3[11]}, {adr_s3[12], cnt_s3[12]}} = adr_s2[11] < adr_s2[12] ? {{adr_s2[11], cnt_s2[11]}, {adr_s2[12], cnt_s2[12]}} : {{adr_s2[12], cnt_s2[12]}, {adr_s2[11], cnt_s2[11]}};
    assign {{adr_s3[13], cnt_s3[13]}, {adr_s3[14], cnt_s3[14]}} = adr_s2[13] < adr_s2[14] ? {{adr_s2[13], cnt_s2[13]}, {adr_s2[14], cnt_s2[14]}} : {{adr_s2[14], cnt_s2[14]}, {adr_s2[13], cnt_s2[13]}};

    assign  {adr_s3[15],  cnt_s3[15]} = {adr_s2[15],  cnt_s2[15]};


//----------------------------------------------------------------------------------------------------------------------
// Latch Results for Output
//----------------------------------------------------------------------------------------------------------------------

    assign adr0 = adr_s3[0];
    assign adr1 = adr_s3[1];
    assign adr2 = adr_s3[2];
    assign adr3 = adr_s3[3];
    assign adr4 = adr_s3[4];
    assign adr5 = adr_s3[5];
    assign adr6 = adr_s3[6];
    assign adr7 = adr_s3[7];

    assign cnt0 = cnt_s3[0];
    assign cnt1 = cnt_s3[1];
    assign cnt2 = cnt_s3[2];
    assign cnt3 = cnt_s3[3];
    assign cnt4 = cnt_s3[4];
    assign cnt5 = cnt_s3[5];
    assign cnt6 = cnt_s3[6];
    assign cnt7 = cnt_s3[7];

//----------------------------------------------------------------------------------------------------------------------
endmodule
//----------------------------------------------------------------------------------------------------------------------
