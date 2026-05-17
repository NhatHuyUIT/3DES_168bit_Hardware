module Key_schedule
(
    input [63:0] key,
    output [47:0]   sub_key_0, sub_key_1, sub_key_2, sub_key_3,
                    sub_key_4, sub_key_5, sub_key_6, sub_key_7,
                    sub_key_8, sub_key_9, sub_key_10, sub_key_11,
                    sub_key_12, sub_key_13, sub_key_14, sub_key_15
);

//                                      |PC-1:             C_table                                  D_table
// index     63 62 61 60 59 58 57 56    |           27 26 25 24 23 22 21                    27 26 25 24 23 22 21
//                                      |
//   key      1  2  3  4  5  6  7  8    |           57 49 41 33 25 17  9                    63 55 47 39 31 23 15
//            9  10 11 12 13 14 15 16   |            1 58 50 42 34 26 18                     7 62 54 46 38 30 22             
//           17 18 19 20 21 22 23 24    |           10  2 59 51 43 35 27                    14  6 61 53 45 37 29
//           25 26 27 28 29 30 31 32    |           19 11  3 60 52 44 36                    21 13  5 28 20 12  4
//           33 34 35 36 37 38 39 40    |   
//           41 42 43 44 45 46 47 48    |Index C:    6  5  4  3  2  1  0         Index D:    6  5  4  3  2  1  0
//           49 50 51 52 53 54 55 56    |
//           57 58 59 60 61 62 63 64    |

// index      7  6  5  4  3  2  1  0                  

// C[i] = key[64 - C_table[i]]
// D[i] = key[64 - D_table[i]]

wire [27:0] C_table;
wire [27:0] D_table;

// C_table
assign C_table[27] = key[64 - 57];
assign C_table[26] = key[64 - 49];
assign C_table[25] = key[64 - 41];
assign C_table[24] = key[64 - 33];
assign C_table[23] = key[64 - 25];
assign C_table[22] = key[64 - 17];
assign C_table[21] = key[64 - 9];

assign C_table[20] = key[64 - 1];
assign C_table[19] = key[64 - 58];
assign C_table[18] = key[64 - 50];
assign C_table[17] = key[64 - 42];
assign C_table[16] = key[64 - 34];
assign C_table[15] = key[64 - 26];
assign C_table[14] = key[64 - 18];

assign C_table[13] = key[64 - 10];
assign C_table[12] = key[64 - 2];
assign C_table[11] = key[64 - 59];
assign C_table[10] = key[64 - 51];
assign C_table[9] = key[64 - 43];
assign C_table[8] = key[64 - 35];
assign C_table[7] = key[64 - 27];

assign C_table[6] = key[64 - 19];
assign C_table[5] = key[64 - 11];
assign C_table[4] = key[64 - 3];
assign C_table[3] = key[64 - 60];
assign C_table[2] = key[64 - 52];
assign C_table[1] = key[64 - 44];
assign C_table[0] = key[64 - 36];

// D_table
assign D_table[27] = key[64 - 63];
assign D_table[26] = key[64 - 55];
assign D_table[25] = key[64 - 47];
assign D_table[24] = key[64 - 39];
assign D_table[23] = key[64 - 31];
assign D_table[22] = key[64 - 23];
assign D_table[21] = key[64 - 15];

assign D_table[20] = key[64 - 7];
assign D_table[19] = key[64 - 62];
assign D_table[18] = key[64 - 54];
assign D_table[17] = key[64 - 46];
assign D_table[16] = key[64 - 38];
assign D_table[15] = key[64 - 30];
assign D_table[14] = key[64 - 22];

assign D_table[13] = key[64 - 14];
assign D_table[12] = key[64 - 6];
assign D_table[11] = key[64 - 61];
assign D_table[10] = key[64 - 53];
assign D_table[9] = key[64 - 45];
assign D_table[8] = key[64 - 37];
assign D_table[7] = key[64 - 29];

assign D_table[6] = key[64 - 21];
assign D_table[5] = key[64 - 13];
assign D_table[4] = key[64 - 5];
assign D_table[3] = key[64 - 28];
assign D_table[2] = key[64 - 20];
assign D_table[1] = key[64 - 12];
assign D_table[0] = key[64 - 4];

wire [27:0] C_shifted[15:0];
wire [27:0] D_shifted[15:0];

// Left shifts
// Round 1 2 9 16: shift 1, others shift 2
// Round 1: Shift 1
assign C_shifted[0] = {C_table[26:0], C_table[27]};
assign D_shifted[0] = {D_table[26:0], D_table[27]};

// Round 2: Shift 1
assign C_shifted[1] = {C_shifted[0][26:0], C_shifted[0][27]};
assign D_shifted[1] = {D_shifted[0][26:0], D_shifted[0][27]};  

// Round 3: Shift 2
assign C_shifted[2] = {C_shifted[1][25:0], C_shifted[1][27:26]};
assign D_shifted[2] = {D_shifted[1][25:0], D_shifted[1][27:26]};

// Round 4: Shift 2
assign C_shifted[3] = {C_shifted[2][25:0], C_shifted[2][27:26]};
assign D_shifted[3] = {D_shifted[2][25:0], D_shifted[2][27:26]};

// Round 5: Shift 2
assign C_shifted[4] = {C_shifted[3][25:0], C_shifted[3][27:26]};
assign D_shifted[4] = {D_shifted[3][25:0], D_shifted[3][27:26]};

// Round 6: Shift 2
assign C_shifted[5] = {C_shifted[4][25:0], C_shifted[4][27:26]};
assign D_shifted[5] = {D_shifted[4][25:0], D_shifted[4][27:26]};

// Round 7: Shift 2
assign C_shifted[6] = {C_shifted[5][25:0], C_shifted[5][27:26]};
assign D_shifted[6] = {D_shifted[5][25:0], D_shifted[5][27:26]};

// Round 8: Shift 2
assign C_shifted[7] = {C_shifted[6][25:0], C_shifted[6][27:26]};
assign D_shifted[7] = {D_shifted[6][25:0], D_shifted[6][27:26]};

// Round 9: Shift 1
assign C_shifted[8] = {C_shifted[7][26:0], C_shifted[7][27]};
assign D_shifted[8] = {D_shifted[7][26:0], D_shifted[7][27]};

// Round 10: Shift 2
assign C_shifted[9] = {C_shifted[8][25:0], C_shifted[8][27:26]};
assign D_shifted[9] = {D_shifted[8][25:0], D_shifted[8][27:26]};

// Round 11: Shift 2
assign C_shifted[10] = {C_shifted[9][25:0], C_shifted[9][27:26]};
assign D_shifted[10] = {D_shifted[9][25:0], D_shifted[9][27:26]};

// Round 12: Shift 2
assign C_shifted[11] = {C_shifted[10][25:0], C_shifted[10][27:26]};
assign D_shifted[11] = {D_shifted[10][25:0], D_shifted[10][27:26]};

// Round 13: Shift 2
assign C_shifted[12] = {C_shifted[11][25:0], C_shifted[11][27:26]};
assign D_shifted[12] = {D_shifted[11][25:0], D_shifted[11][27:26]};

// Round 14: Shift 2
assign C_shifted[13] = {C_shifted[12][25:0], C_shifted[12][27:26]};
assign D_shifted[13] = {D_shifted[12][25:0], D_shifted[12][27:26]};

// Round 15: Shift 2
assign C_shifted[14] = {C_shifted[13][25:0], C_shifted[13][27:26]};
assign D_shifted[14] = {D_shifted[13][25:0], D_shifted[13][27:26]};

// Round 16: Shift 1
assign C_shifted[15] = {C_shifted[14][26:0], C_shifted[14][27]};
assign D_shifted[15] = {D_shifted[14][26:0], D_shifted[14][27]};       


// Bảng PC-2 (Permuted Choice 2): Giảm từ 56-bit {C, D} xuống 48-bit Subkey
//    14  |   17  |   11  |   24  |    1  |    5  |
//     3  |   28  |   15  |    6  |   21  |   10  |
//    23  |   19  |   12  |    4  |   26  |    8  |
//    16  |    7  |   27  |   20  |   13  |    2  |
//    41  |   52  |   31  |   37  |   47  |   55  |
//    30  |   40  |   51  |   45  |   33  |   48  |
//    44  |   49  |   39  |   56  |   34  |   53  |
//    46  |   42  |   50  |   36  |   29  |   32  |

// CD[i] = {C_shifted[i], D_shifted[i]}
wire [55:0] CD [15:0]; 
wire [47:0] sub_key [15:0]; 

genvar i;
generate
    for(i = 0; i < 16; i = i + 1) begin : subkey_generation
        assign CD[i] = {C_shifted[i], D_shifted[i]};

        //// sub_key[i] = CD[56 - PC2_table[j]]     Moi lan chay i thi j luon chay xong tu 47 ve 0
        assign sub_key[i][47] = CD[i][56 - 14];
        assign sub_key[i][46] = CD[i][56 - 17];
        assign sub_key[i][45] = CD[i][56 - 11];
        assign sub_key[i][44] = CD[i][56 - 24];
        assign sub_key[i][43] = CD[i][56 - 1];
        assign sub_key[i][42] = CD[i][56 - 5];
        assign sub_key[i][41] = CD[i][56 - 3];
        assign sub_key[i][40] = CD[i][56 - 28];

        assign sub_key[i][39] = CD[i][56 - 15];
        assign sub_key[i][38] = CD[i][56 - 6];
        assign sub_key[i][37] = CD[i][56 - 21];
        assign sub_key[i][36] = CD[i][56 - 10];
        assign sub_key[i][35] = CD[i][56 - 23];
        assign sub_key[i][34] = CD[i][56 - 19];
        assign sub_key[i][33] = CD[i][56 - 12];
        assign sub_key[i][32] = CD[i][56 - 4];

        assign sub_key[i][31] = CD[i][56 - 26];
        assign sub_key[i][30] = CD[i][56 - 8];
        assign sub_key[i][29] = CD[i][56 - 16];
        assign sub_key[i][28] = CD[i][56 - 7];
        assign sub_key[i][27] = CD[i][56 - 27];
        assign sub_key[i][26] = CD[i][56 - 20];
        assign sub_key[i][25] = CD[i][56 - 13];
        assign sub_key[i][24] = CD[i][56 - 2];

        assign sub_key[i][23] = CD[i][56 - 41];
        assign sub_key[i][22] = CD[i][56 - 52];
        assign sub_key[i][21] = CD[i][56 - 31];
        assign sub_key[i][20] = CD[i][56 - 37];
        assign sub_key[i][19] = CD[i][56 - 47];
        assign sub_key[i][18] = CD[i][56 - 55];
        assign sub_key[i][17] = CD[i][56 - 30];
        assign sub_key[i][16] = CD[i][56 - 40];
    
        assign sub_key[i][15] = CD[i][56 - 51];
        assign sub_key[i][14] = CD[i][56 - 45];
        assign sub_key[i][13] = CD[i][56 - 33];
        assign sub_key[i][12] = CD[i][56 - 48];
        assign sub_key[i][11] = CD[i][56 - 44];
        assign sub_key[i][10] = CD[i][56 - 49];
        assign sub_key[i][9] = CD[i][56 - 39];
        assign sub_key[i][8] = CD[i][56 - 56];

        assign sub_key[i][7] = CD[i][56 - 34];
        assign sub_key[i][6] = CD[i][56 - 53];
        assign sub_key[i][5] = CD[i][56 - 46];
        assign sub_key[i][4] = CD[i][56 - 42];
        assign sub_key[i][3] = CD[i][56 - 50];
        assign sub_key[i][2] = CD[i][56 - 36];
        assign sub_key[i][1] = CD[i][56 - 29];
        assign sub_key[i][0] = CD[i][56 - 32];
    end
endgenerate

assign sub_key_0 = sub_key[0];
assign sub_key_1 = sub_key[1];
assign sub_key_2 = sub_key[2];
assign sub_key_3 = sub_key[3];
assign sub_key_4 = sub_key[4];
assign sub_key_5 = sub_key[5];
assign sub_key_6 = sub_key[6];
assign sub_key_7 = sub_key[7];
assign sub_key_8 = sub_key[8];
assign sub_key_9 = sub_key[9];
assign sub_key_10 = sub_key[10];
assign sub_key_11 = sub_key[11];
assign sub_key_12 = sub_key[12];
assign sub_key_13 = sub_key[13];
assign sub_key_14 = sub_key[14];
assign sub_key_15 = sub_key[15];

endmodule
