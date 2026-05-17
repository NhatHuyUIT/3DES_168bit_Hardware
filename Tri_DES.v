module Tri_DES
(
    input           clk, start, rst,
    input           mode,           // 1 = encrypt, 0 = decrypt
    input   [63:0]  plaintext,
    input   [63:0]  key_1,
    input   [63:0]  key_2,
    input   [63:0]  key_3,
    output          done,
    output  [63:0]  ciphertext
);

wire [63:0] first_key;
wire [63:0] third_key;
assign first_key = mode ? key_1 : key_3;
assign third_key = mode ? key_3 : key_1;

wire first_mode;    
wire second_mode;   
wire third_mode;    
assign first_mode  = mode;    
assign second_mode = ~mode;   
assign third_mode  = mode;

wire done_1;
wire done_2;

wire [63:0] T1;
wire [63:0] T2;

DES_core des1 (
    .clk       (clk),
    .rst       (rst),
    .start     (start),
    .mode      (first_mode),
    .plaintext (plaintext),
    .key       (first_key),
    .ciphertext(T1),
    .done      (done_1)
);


DES_core des2 (
    .clk       (clk),
    .rst       (rst),
    .start     (done_1),
    .mode      (second_mode),
    .plaintext (T1),
    .key       (key_2),
    .ciphertext(T2),
    .done      (done_2)
);

DES_core des3 (
    .clk       (clk),
    .rst       (rst),
    .start     (done_2),
    .mode      (third_mode),
    .plaintext (T2),
    .key       (third_key),
    .ciphertext(ciphertext),
    .done      (done)
);

endmodule