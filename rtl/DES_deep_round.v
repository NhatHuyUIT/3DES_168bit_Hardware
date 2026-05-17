module DES_deep_round (
    input         clk,
    input         rst,
    input  [31:0] L_in,
    input  [31:0] R_in,
    input  [47:0] K,
    input         valid_in,
    output [31:0] L_out,
    output [31:0] R_out,
    output        valid_out
);

    // ==========================================================
    // CHẶNG 1 (PHASE 0): Expansion & XOR Key
    // ==========================================================
    wire [47:0] E_out;
    Expansion exp_inst (.in(R_in), .out(E_out));
    
    wire [47:0] xor_result = E_out ^ K;

    // Khai báo thanh ghi chốt cho Chặng 1
    reg [31:0] L_reg_1, R_reg_1;
    reg [47:0] xor_reg_1;
    reg        valid_reg_1;

    always @(posedge clk) begin
        if (rst) begin
            L_reg_1     <= 32'd0; 
            R_reg_1     <= 32'd0; 
            xor_reg_1   <= 48'd0; 
            valid_reg_1 <= 1'b0;
        end else begin
            L_reg_1     <= L_in; 
            R_reg_1     <= R_in; 
            xor_reg_1   <= xor_result; 
            valid_reg_1 <= valid_in;
        end
    end

    // ==========================================================
    // CHẶNG 2 (PHASE 1): Substitution (SP-Box)
    // ==========================================================
    wire [31:0] sp_out;
    SP_box sp_inst (.in(xor_reg_1), .out(sp_out));

    // Khai báo thanh ghi chốt cho Chặng 2
    reg [31:0] L_reg_2, R_reg_2;
    reg [31:0] sp_reg_2;
    reg        valid_reg_2;

    always @(posedge clk) begin
        if (rst) begin
            L_reg_2     <= 32'd0; 
            R_reg_2     <= 32'd0; 
            sp_reg_2    <= 32'd0; 
            valid_reg_2 <= 1'b0;
        end else begin
            L_reg_2     <= L_reg_1; 
            R_reg_2     <= R_reg_1; 
            sp_reg_2    <= sp_out; 
            valid_reg_2 <= valid_reg_1;
        end
    end

    // ==========================================================
    // CHẶNG 3 (PHASE 2): Feistel XOR & Swap
    // ==========================================================
    // Khai báo thanh ghi chốt cho Chặng 3
    reg [31:0] L_reg_3, R_reg_3;
    reg        valid_reg_3;

    always @(posedge clk) begin
        if (rst) begin
            L_reg_3     <= 32'd0; 
            R_reg_3     <= 32'd0; 
            valid_reg_3 <= 1'b0;
        end else begin
            L_reg_3     <= R_reg_2;                // L mới nhận R cũ
            R_reg_3     <= L_reg_2 ^ sp_reg_2;     // R mới nhận (L cũ XOR hàm F)
            valid_reg_3 <= valid_reg_2;
        end
    end

    // ==========================================================
    // OUTPUT ASSIGNMENT
    // ==========================================================
    assign L_out     = L_reg_3;
    assign R_out     = R_reg_3;
    assign valid_out = valid_reg_3;

endmodule