module DES_core_DeepPipe 
(
    input           clk,
    input           rst,
    input  [63:0]   plaintext,
    input           valid_in,       
    output [63:0]   ciphertext,
    output          valid_out,      
    input  [63:0]   key,
    input           mode
);

    wire [47:0] sub_key [0:15];
    Key_schedule ks_inst (
        .key        (key),
        .sub_key_0  (sub_key[0]),  .sub_key_1  (sub_key[1]),
        .sub_key_2  (sub_key[2]),  .sub_key_3  (sub_key[3]),
        .sub_key_4  (sub_key[4]),  .sub_key_5  (sub_key[5]),
        .sub_key_6  (sub_key[6]),  .sub_key_7  (sub_key[7]),
        .sub_key_8  (sub_key[8]),  .sub_key_9  (sub_key[9]),
        .sub_key_10 (sub_key[10]), .sub_key_11 (sub_key[11]),
        .sub_key_12 (sub_key[12]), .sub_key_13 (sub_key[13]),
        .sub_key_14 (sub_key[14]), .sub_key_15 (sub_key[15])
    );

wire [47:0] round_key [0:15];
genvar g;
generate
    for (g = 0; g < 16; g = g + 1) begin : key_mux
         assign round_key[g] = mode ? sub_key[g] : sub_key[15 - g];
    end
endgenerate

wire [63:0] initial_permuted;
Initial_Permutation ip_inst (
    .in  (plaintext),
    .out (initial_permuted)
);

reg [31:0] L_reg[0:16];
reg [31:0] R_reg[0:16];
reg        valid_reg[0:16];

always @(posedge clk) begin
    if (rst) begin
        L_reg[0]     <= 32'd0; 
        R_reg[0]     <= 32'd0; 
        valid_reg[0] <= 1'b0;      
    end 
    else begin
        L_reg[0]     <= initial_permuted[63:32]; 
        R_reg[0]     <= initial_permuted[31:0]; 
        valid_reg[0] <= valid_in;   
    end
end

wire [31:0] L_stage [0:16];
wire [31:0] R_stage [0:16];
wire        valid_stage [0:16];

assign L_stage[0]     = L_reg[0];
assign R_stage[0]     = R_reg[0];
assign valid_stage[0] = valid_reg[0]; 

genvar r;
generate
    for (r = 0; r < 16; r = r + 1) begin : deep_stages
        DES_deep_round rnd_inst (
            .clk        (clk),     
            .rst        (rst),
            .L_in       (L_stage[r]), 
            .R_in       (R_stage[r]), 
            .K          (round_key[r]),       
            .valid_in   (valid_stage[r]),     
            .L_out      (L_stage[r+1]),       
            .R_out      (R_stage[r+1]),       
            .valid_out  (valid_stage[r+1])    
        );
    end
endgenerate

wire [63:0] Inv_IP_out;
Inv_Initial_Permutation fp_inst (.in({R_stage[16], L_stage[16]}), .out(Inv_IP_out));

reg [63:0] ciphertext_reg;
reg        valid_out_reg;

always @(posedge clk) begin
    if (rst) begin
        ciphertext_reg <= 64'd0; 
        valid_out_reg  <= 1'b0;
    end else begin
        ciphertext_reg <= Inv_IP_out;       
        valid_out_reg  <= valid_stage[16];  
    end
end

assign ciphertext = ciphertext_reg;
assign valid_out  = valid_out_reg;

endmodule