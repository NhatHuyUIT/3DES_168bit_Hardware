module Initial_Permutation
(
    input [63:0] in,
    output [63:0] out
);

// Cong thuc IP: out[i] = in[64 - IP[table value[i]]

// index     63 62 61 60 59 58 57 56                63 62 61 60 59 58 57 56

// IP table: 58 50 42 34 26 18 10 2                 1  2  3  4  5  6  7  8
//           60 52 44 36 28 20 12 4                 9  10 11 12 13 14 15 16
//           62 54 46 38 30 22 14 6                 17 18 19 20 21 22 23 24
//           64 56 48 40 32 24 16 8                 25 26 27 28 29 30 31 32
//           57 49 41 33 25 17 9  1                 33 34 35 36 37 38 39 40
//           59 51 43 35 27 19 11 3                 41 42 43 44 45 46 47 48
//           61 53 45 37 29 21 13 5                 49 50 51 52 53 54 55 56
//           63 55 47 39 31 23 15 7                 57 58 59 60 61 62 63 64

// index     7  6  5  4  3  2  1  0                  7  6  5  4  3  2  1  0

assign out[63] = in[64 - 58];   // i = 0
assign out[62] = in[64 - 50];
assign out[61] = in[64 - 42];
assign out[60] = in[64 - 34];
assign out[59] = in[64 - 26];
assign out[58] = in[64 - 18];
assign out[57] = in[64 - 10];
assign out[56] = in[64 - 2];

assign out[55] = in[64 - 60];   // i = 8
assign out[54] = in[64 - 52];
assign out[53] = in[64 - 44];
assign out[52] = in[64 - 36];
assign out[51] = in[64 - 28];
assign out[50] = in[64 - 20];
assign out[49] = in[64 - 12];
assign out[48] = in[64 - 4];

assign out[47] = in[64 - 62];   // i = 16
assign out[46] = in[64 - 54];
assign out[45] = in[64 - 46];
assign out[44] = in[64 - 38];
assign out[43] = in[64 - 30];
assign out[42] = in[64 - 22];
assign out[41] = in[64 - 14];
assign out[40] = in[64 - 6];

assign out[39] = in[64 - 64];   // i = 24
assign out[38] = in[64 - 56];
assign out[37] = in[64 - 48];
assign out[36] = in[64 - 40];
assign out[35] = in[64 - 32];
assign out[34] = in[64 - 24];
assign out[33] = in[64 - 16];
assign out[32] = in[64 - 8];

assign out[31] = in[64 - 57];   // i = 32
assign out[30] = in[64 - 49];
assign out[29] = in[64 - 41];
assign out[28] = in[64 - 33];
assign out[27] = in[64 - 25];
assign out[26] = in[64 - 17];
assign out[25] = in[64 - 9];
assign out[24] = in[64 - 1];

assign out[23] = in[64 - 59];   // i = 40
assign out[22] = in[64 - 51];
assign out[21] = in[64 - 43];
assign out[20] = in[64 - 35];
assign out[19] = in[64 - 27];
assign out[18] = in[64 - 19];
assign out[17] = in[64 - 11];
assign out[16] = in[64 - 3];

assign out[15] = in[64 - 61];   // i = 48
assign out[14] = in[64 - 53];
assign out[13] = in[64 - 45];
assign out[12] = in[64 - 37];
assign out[11] = in[64 - 29];
assign out[10] = in[64 - 21];
assign out[9] = in[64 - 13];
assign out[8] = in[64 - 5];

assign out[7] = in[64 - 63];   // i = 56
assign out[6] = in[64 - 55];
assign out[5] = in[64 - 47];
assign out[4] = in[64 - 39];
assign out[3] = in[64 - 31];
assign out[2] = in[64 - 23];
assign out[1] = in[64 - 15];
assign out[0] = in[64 - 7];

endmodule

