module DES_core
(
    input            clk, start, rst,
    input            mode,       
    input    [63:0]  plaintext,
    input    [63:0]  key,
    output reg       done,
    output   [63:0]  ciphertext
);

reg [31:0] L, R;
reg [3:0]  round;
reg        running;
reg [1:0]  phase;

reg [47:0] xor_reg;     
reg [31:0] L_stage_1;        
reg [31:0] R_stage_1;        

reg [31:0] sp_reg;      
reg [31:0] L_stage_2;        
reg [31:0] R_stage_2;       

reg [63:0] ciphertext_reg;

wire [63:0] initial_permuted;
Initial_Permutation ip_inst (
    .in  (plaintext),
    .out (initial_permuted)
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

wire [47:0] expanded_R;
Expansion exp_inst (
    .in  (R),
    .out (expanded_R)
);

wire [47:0] current_key;
assign current_key = (mode) ? sub_key[round] : sub_key[15 - round];
wire [47:0] xor_result;
assign xor_result = expanded_R ^ current_key;

wire [31:0] sp_out;
SP_box sp_inst (
    .in  (xor_reg),
    .out (sp_out)
);

always @(posedge clk) begin
    if (rst) begin
        running        <= 1'b0;
        done           <= 1'b0;
        round          <= 4'd0;
        phase          <= 2'd0;
        ciphertext_reg <= 64'd0;
        L <= 32'd0; R <= 32'd0;
        xor_reg <= 48'd0; L_stage_1 <= 32'd0; R_stage_1 <= 32'd0;
        sp_reg <= 32'd0;  L_stage_2 <= 32'd0; R_stage_2 <= 32'd0;
    end
    else if (start) begin
        L              <= initial_permuted[63:32];
        R              <= initial_permuted[31:0];
        round          <= 4'd0;
        phase          <= 2'd0;
        running        <= 1'b1;
        done           <= 1'b0;
        ciphertext_reg <= 64'd0;
    end
    else if (running) begin
        case (phase)
            2'd0: begin
                xor_reg <= xor_result;
                phase   <= 2'd1;
            end
            
            2'd1: begin
                sp_reg  <= sp_out;
                phase   <= 2'd2;
            end
            
            2'd2: begin
                L <= R;
                R <= L ^ sp_reg;

                if (round == 4'd15) begin
                    running <= 1'b0;
                    done    <= 1'b1;
                    ciphertext_reg <= {L ^ sp_reg, R};
                end
                else begin
                    round <= round + 1'b1;
                    phase <= 2'd0;
                end
            end
endcase
    end
    else if (done) begin
        done <= 1'b0; // Pulse done 1 chu kỳ
    end
end

Inv_Initial_Permutation fp_inst (
    .in  (ciphertext_reg),
    .out (ciphertext)
);

endmodule
