module Tri_DES_DeepPipe 
(
    input           clk,
    input           rst,
    input  [63:0]   plaintext,
    input           valid_in,
    input           mode,
    input  [63:0]   key_1,
    input  [63:0]   key_2,
    input  [63:0]   key_3,
    output [63:0]   ciphertext,
    output          valid_out
);

wire [63:0] first_key = mode ? key_1 : key_3;
wire [63:0] third_key = mode ? key_3 : key_1;

wire first_mode;    
wire second_mode;   
wire third_mode;    
assign first_mode  = mode;    
assign second_mode = ~mode;   
assign third_mode  = mode;       

wire [63:0] T1;
wire        valid_out_1;

DES_core_DeepPipe des1 
(
    .clk(clk), 
    .rst(rst),
    .key(first_key), 
    .mode(first_mode),
    .plaintext(plaintext), 
    .valid_in(valid_in),
    .valid_out(valid_out_1),
    .ciphertext(T1)
);

wire [63:0] T2;
wire        valid_out_2;

DES_core_DeepPipe des2 
(
    .clk(clk), 
    .rst(rst),
    .key(key_2), 
    .mode(second_mode),
    .plaintext(T1), 
    .valid_in(valid_out_1),
    .valid_out(valid_out_2),
    .ciphertext(T2)
);

DES_core_DeepPipe des3 
(
    .clk(clk), 
    .rst(rst),
    .key(third_key), 
    .mode(third_mode),
    .plaintext(T2), 
    .valid_in(valid_out_2),
    .valid_out(valid_out),
    .ciphertext(ciphertext)
);

endmodule