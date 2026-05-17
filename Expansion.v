module Expansion
(
    input [31:0] in,
    output [47:0] out
);

// Cong thuc E: out[i] = in[32 - E[table value[i]]

//Index     47   46 45 44 43    42               31 30 29 28

//          32 |  1  2  3  4  |  5                1  2  3  4
//          4  |  5  6  7  8  |  9                5  6  7  8
//          8  |  9 10 11 12  | 13                9 10 11 12
//          12 | 13 14 15 16  | 17               13 14 15 16
//          16 | 17 18 19 20  | 21               17 18 19 20
//          20 | 21 22 23 24  | 25               21 22 23 24
//          24 | 25 26 27 28  | 29               25 26 27 28
//          28 | 29 30 31 32  |  1               29 30 31 32

//Index      5    4  3  2  1     0                3  2  1  0

assign out[47] = in[32 - 32];   // i= 0
assign out[46] = in[32 - 1];
assign out[45] = in[32 - 2];
assign out[44] = in[32 - 3];
assign out[43] = in[32 - 4];
assign out[42] = in[32 - 5];

assign out[41] = in[32 - 4];   // i= 6
assign out[40] = in[32 - 5];
assign out[39] = in[32 - 6];
assign out[38] = in[32 - 7];
assign out[37] = in[32 - 8];
assign out[36] = in[32 - 9];

assign out[35] = in[32 - 8];   // i= 12
assign out[34] = in[32 - 9];
assign out[33] = in[32 - 10];
assign out[32] = in[32 - 11];
assign out[31] = in[32 - 12];
assign out[30] = in[32 - 13];

assign out[29] = in[32 - 12];   // i= 18
assign out[28] = in[32 - 13];
assign out[27] = in[32 - 14];
assign out[26] = in[32 - 15];
assign out[25] = in[32 - 16];
assign out[24] = in[32 - 17];

assign out[23] = in[32 - 16];   // i= 24
assign out[22] = in[32 - 17];
assign out[21] = in[32 - 18];
assign out[20] = in[32 - 19];
assign out[19] = in[32 - 20];
assign out[18] = in[32 - 21];

assign out[17] = in[32 - 20];   // i= 30
assign out[16] = in[32 - 21];
assign out[15] = in[32 - 22];
assign out[14] = in[32 - 23];
assign out[13] = in[32 - 24];
assign out[12] = in[32 - 25];

assign out[11] = in[32 - 24];   // i= 36
assign out[10] = in[32 - 25];
assign out[9] = in[32 - 26];
assign out[8] = in[32 - 27];
assign out[7] = in[32 - 28];
assign out[6] = in[32 - 29];

assign out[5] = in[32 - 28];   // i= 42
assign out[4] = in[32 - 29];
assign out[3] = in[32 - 30];
assign out[2] = in[32 - 31];
assign out[1] = in[32 - 32];
assign out[0] = in[32 - 1];   

endmodule