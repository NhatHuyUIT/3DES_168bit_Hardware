`timescale 1ns/1ps

module tb_Tri_DES_base;

reg         clk, rst, start;
reg         mode;
reg  [63:0] plaintext;
reg  [63:0] key_1, key_2, key_3;
wire [63:0] ciphertext;
wire        done;

Tri_DES_base uut (
    .clk       (clk),
    .rst       (rst),
    .start     (start),
    .mode      (mode),
    .plaintext (plaintext),
    .key_1     (key_1),
    .key_2     (key_2),
    .key_3     (key_3),
    .ciphertext(ciphertext),
    .done      (done)
);

always #10 clk = ~clk;

integer pass_cnt, fail_cnt;

task run_block;
    input [63:0]   pt_in;
    input          mode_in;
    input [63:0]   expected;
    input [255:0]  label;
    reg   [63:0]   got;
    integer        timeout;
    begin
        @(negedge clk);
        plaintext = pt_in;
        mode      = mode_in;
        start     = 1'b1;
        @(negedge clk);
        start     = 1'b0;
        timeout = 0;
        while (done !== 1'b1 && timeout < 300) begin
            @(posedge clk); 
            #10;
            timeout = timeout + 1;
        end
        @(posedge clk); 
        #10;
        got = ciphertext;

        if (timeout >= 300) begin
            $display("  [TIMEOUT] %0s", label);
            fail_cnt = fail_cnt + 1;
        end else if (got === expected) begin
            $display("  [PASS] %0s", label);
            $display("         mode=%0d  PT =%016H", mode_in, pt_in);
            $display("                   CT =%016H", got);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  [FAIL] %0s", label);
            $display("         mode=%0d  PT  =%016H", mode_in, pt_in);
            $display("                   Got =%016H", got);
            $display("                   Exp =%016H", expected);
            fail_cnt = fail_cnt + 1;
        end

        repeat(5) @(negedge clk);
    end
endtask

reg [63:0] pt [0:4];
reg [63:0] ct [0:4];

initial begin
    clk      = 0;
    rst      = 1;
    start    = 0;
    mode     = 1;
    plaintext= 64'd0;
    pass_cnt = 0;
    fail_cnt = 0;

    key_1 = 64'h133457799BBCDFF1;
    key_2 = 64'hAABBCCDDEEFF0011;
    key_3 = 64'h0F1E2D3C4B5A6978;

    // Plaintext blocks
    pt[0] = 64'h5472756F6E672044; // "Truong D"
    pt[1] = 64'h616920686F632043; // "ai hoc C"
    pt[2] = 64'h6F6E67204E676865; // "ong Nghe"
    pt[3] = 64'h2054686F6E672074; // " Thong t"
    pt[4] = 64'h696E060606060606; // "in" + PKCS7

    // Expected ciphertext
    ct[0] = 64'hEF3710901AD7E49B;
    ct[1] = 64'h1B3EE772EA197A1A;
    ct[2] = 64'h29418B3110588376;
    ct[3] = 64'hB95CEE343542B5FC;
    ct[4] = 64'h5D31B59B4DF23F10;

    repeat(5) @(negedge clk);
    rst = 1'b0;
    repeat(3) @(negedge clk);

    $display("");
    $display("=========================================================");
    $display(" tb_Tri_DES_base");
    $display(" Key_1=%016H", key_1);
    $display(" Key_2=%016H", key_2);
    $display(" Key_3=%016H", key_3);
    $display("=========================================================");

    // ── TEST 1: Encrypt 5 blocks ──────────────────────────
    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 1: Encrypt 5 blocks");
    $display(" Chuoi: 'Truong Dai hoc Cong Nghe Thong tin' + PKCS7");
    $display("---------------------------------------------------------");

    run_block(pt[0], 1'b1, ct[0], "Enc Block 0: 'Truong D'          ");
    run_block(pt[1], 1'b1, ct[1], "Enc Block 1: 'ai hoc C'          ");
    run_block(pt[2], 1'b1, ct[2], "Enc Block 2: 'ong Nghe'          ");
    run_block(pt[3], 1'b1, ct[3], "Enc Block 3: ' Thong t'          ");
    run_block(pt[4], 1'b1, ct[4], "Enc Block 4: 'in'+PKCS7(0x06 x6) ");

    // ── TEST 2: Decrypt 5 blocks ──────────────────────────
    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 2: Decrypt 5 blocks -> verify plaintext goc");
    $display("---------------------------------------------------------");

    run_block(ct[0], 1'b0, pt[0], "Dec Block 0 -> 'Truong D'          ");
    run_block(ct[1], 1'b0, pt[1], "Dec Block 1 -> 'ai hoc C'          ");
    run_block(ct[2], 1'b0, pt[2], "Dec Block 2 -> 'ong Nghe'          ");
    run_block(ct[3], 1'b0, pt[3], "Dec Block 3 -> ' Thong t'          ");
    run_block(ct[4], 1'b0, pt[4], "Dec Block 4 -> 'in'+PKCS7(0x06 x6) ");

    // ── TEST 3: Round-trip ────────────────────────────────
    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 3: Round-trip (Enc -> Dec -> ra PT goc)");
    $display("---------------------------------------------------------");

    run_block(pt[2], 1'b1, ct[2], "Enc block 2 'ong Nghe'   ");
    run_block(ct[2], 1'b0, pt[2], "Dec block 2 -> 'ong Nghe'");

    // ── TEST 4: Kiem tra latency ──────────────────────────
    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 4: Latency measurement");
    $display(" Ly thuyet: 3 x 16 + 2 bubble cycles = 50 cycles / block 3DES");
    $display("---------------------------------------------------------");
    begin : latency_test
        integer lat;
        rst = 1; 
        repeat(3) @(negedge clk); 
        rst = 0; 
        repeat(2) @(negedge clk);
        plaintext = pt[0]; 
        mode = 1'b1;
        @(negedge clk); 
        start = 1'b1;
        @(negedge clk); 
        start = 1'b0;
        lat = 0;
        while (done !== 1'b1 && lat < 300) begin
            @(posedge clk); 
            #10; 
            lat = lat + 1;
        end
        $display("  Latency do duoc: %0d cycles", lat);
        if (lat <= 55)
            $display("  [PASS] Nam trong nguong cho phep (<= 55 cycles)");
        else
            $display("  [WARN] %0d cycles - kiem tra lai", lat);
    end

    // ── Ket qua tong hop ──────────────────────────────────
    $display("");
    $display("=========================================================");
    $display(" KET QUA TONG HOP");
    $display("=========================================================");
    $display(" PASS : %0d / %0d", pass_cnt, pass_cnt + fail_cnt);
    $display(" FAIL : %0d / %0d", fail_cnt, pass_cnt + fail_cnt);
    if (fail_cnt == 0)
        $display(" >> TAT CA PASS - Tri_DES_base hoat dong chinh xac!");
    else
        $display(" >> Con %0d FAIL - Can debug!", fail_cnt);
    $display("=========================================================");

    #100;
    $finish;
end

initial begin
    #5000000;
    $display("[WATCHDOG] Timeout - Tri_DES_base bi treo!");
    $finish;
end

initial begin
    $dumpfile("tb_Tri_DES_base.vcd");
    $dumpvars(0, tb_Tri_DES_base);
end

endmodule
