module DES_core_base
(
    input            clk, start, rst,
    input            mode,       
    input    [63:0]  plaintext,
    input    [63:0]  key,
    output reg       done,
    output   [63:0]  ciphertext
);

reg [31:0] L;
reg [31:0] R;
reg [3:0] round;
reg       running;

wire [63:0]initial_permuted;
Initial_Permutation initial_permutation_inst(
    .in(plaintext),
    .out(initial_permuted)
);

wire [47:0] sub_key [15:0];
Key_schedule key_schedule_inst(
    .key(key),
    .sub_key_0(sub_key[0]),
    .sub_key_1(sub_key[1]),
    .sub_key_2(sub_key[2]),
    .sub_key_3(sub_key[3]),
    .sub_key_4(sub_key[4]),
    .sub_key_5(sub_key[5]),
    .sub_key_6(sub_key[6]),
    .sub_key_7(sub_key[7]),
    .sub_key_8(sub_key[8]),
    .sub_key_9(sub_key[9]),
    .sub_key_10(sub_key[10]),
    .sub_key_11(sub_key[11]),
    .sub_key_12(sub_key[12]),
    .sub_key_13(sub_key[13]),
    .sub_key_14(sub_key[14]),
    .sub_key_15(sub_key[15])
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

wire [31:0] S_out, F_out;
S_box s_box_inst(
    .in(xor_result),
    .out(S_out)
);

P_box p_box_inst(
    .in(S_out),
    .out(F_out)
);


reg [63:0] ciphertext_reg;
always @(posedge clk) begin
    if(rst) begin
        done <= 1'b0;
        running <= 1'b0;
        round <= 4'd0;
        ciphertext_reg <= 64'b0;
    end
    else if(start) begin
        L <= initial_permuted[63:32];
        R <= initial_permuted[31:0];
        done <= 1'b0;
        running <= 1'b1;
        round <= 4'd0;
    end
    else if(running) begin
        L <= R;
        R <= L ^ F_out;
        round <= round + 1;
        if(round == 4'd15) begin
            done <= 1'b1;
            running <= 1'b0;
            ciphertext_reg <= {L ^ F_out, R}; // Swap L and R truoc khi output
        end
    end
    else if (done) begin
        done <= 1'b0; 
    end
end

Inv_Initial_Permutation inv_initial_permutation_inst(
    .in(ciphertext_reg),
    .out(ciphertext)
);

endmodule