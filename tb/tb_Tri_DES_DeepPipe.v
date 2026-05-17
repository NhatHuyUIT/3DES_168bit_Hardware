`timescale 1ns/1ps

module tb_Tri_DES_DeepPipe;

reg         clk;
reg         rst;
reg         valid_in;
reg         mode;          
reg  [63:0] plaintext;
reg  [63:0] key_1, key_2, key_3;
wire [63:0] ciphertext;
wire        valid_out;

Tri_DES_DeepPipe uut (
    .clk        (clk),
    .rst        (rst),
    .plaintext  (plaintext),
    .valid_in   (valid_in),
    .mode       (mode),
    .key_1      (key_1),
    .key_2      (key_2),
    .key_3      (key_3),
    .ciphertext (ciphertext),
    .valid_out  (valid_out)
);

always #10 clk = ~clk;

integer pass_cnt;
integer fail_cnt;

reg [63:0] pt [0:4];
reg [63:0] ct [0:4];
reg [63:0] got [0:4];

task do_reset;
    begin
        valid_in  = 1'b0;
        plaintext = 64'd0;
        rst       = 1'b1;
        repeat (5) @(negedge clk);
        rst       = 1'b0;
        repeat (3) @(negedge clk);
    end
endtask

task push_block;
    input [63:0] data_in;
    begin
        @(negedge clk);
        plaintext = data_in;
        valid_in  = 1'b1;
        @(negedge clk);
        valid_in  = 1'b0;
    end
endtask

task push_5_blocks;
    input [63:0] b0;
    input [63:0] b1;
    input [63:0] b2;
    input [63:0] b3;
    input [63:0] b4;
    begin
        @(negedge clk);
        valid_in  = 1'b1; 
        plaintext = b0;
        @(negedge clk);
        valid_in  = 1'b1; 
        plaintext = b1;
        @(negedge clk);
        valid_in  = 1'b1; 
        plaintext = b2;
        @(negedge clk);
        valid_in  = 1'b1; 
        plaintext = b3;
        @(negedge clk);
        valid_in  = 1'b1; 
        plaintext = b4;
        @(negedge clk);
        valid_in  = 1'b0; 
    end
endtask

task collect_5_outputs;
    integer idx;
    integer timeout;
    begin
        idx     = 0;
        timeout = 0;

        while (idx < 5 && timeout < 1000) begin
            @(posedge clk); 
				#10;
            if (valid_out === 1'b1) begin
                got[idx] = ciphertext;
                $display("  Output[%0d] = %016H", idx, ciphertext);
                idx = idx + 1;
            end
            timeout = timeout + 1;
        end

        if (idx < 5) begin
            $display("  [TIMEOUT] Chi nhan duoc %0d/5 output", idx);
            fail_cnt = fail_cnt + (5 - idx);
        end
    end
endtask

task check_5_outputs;
    input [63:0] e0;
    input [63:0] e1;
    input [63:0] e2;
    input [63:0] e3;
    input [63:0] e4;
    input [255:0] label;
    reg [63:0] exp [0:4];
    integer k;
    begin
        exp[0] = e0;
        exp[1] = e1;
        exp[2] = e2;
        exp[3] = e3;
        exp[4] = e4;

        for (k = 0; k < 5; k = k + 1) begin
            if (got[k] === exp[k]) begin
                $display("  [PASS] %0s block %0d", label, k);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  [FAIL] %0s block %0d", label, k);
                $display("         Got = %016H", got[k]);
                $display("         Exp = %016H", exp[k]);
                fail_cnt = fail_cnt + 1;
            end
        end
    end
endtask

task run_single_block;
    input [63:0] data_in;
    input        mode_in;
    input [63:0] expected;
    input [255:0] label;
    integer timeout;
    reg [63:0] one_got;
    begin
        mode = mode_in;
        repeat (2) @(negedge clk);
        push_block(data_in);

        timeout = 0;
        while (valid_out !== 1'b1 && timeout < 1000) begin
            @(posedge clk); 
            #10;
            timeout = timeout + 1;
        end

        if (timeout >= 1000) begin
            $display("  [TIMEOUT] %0s", label);
            fail_cnt = fail_cnt + 1;
        end else begin
            one_got = ciphertext;
            if (one_got === expected) begin
                $display("  [PASS] %0s", label);
                $display("         In  = %016H", data_in);
                $display("         Out = %016H", one_got);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  [FAIL] %0s", label);
                $display("         In  = %016H", data_in);
                $display("         Got = %016H", one_got);
                $display("         Exp = %016H", expected);
                fail_cnt = fail_cnt + 1;
            end
        end

        repeat (5) @(negedge clk);
    end
endtask

initial begin
    clk       = 1'b0;
    rst       = 1'b1;
    valid_in  = 1'b0;
    mode      = 1'b1;
    plaintext = 64'd0;
    pass_cnt  = 0;
    fail_cnt  = 0;

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

    do_reset();

    $display("");
    $display("=========================================================");
    $display(" tb_Tri_DES_DeepPipe");
    $display(" Interface: valid_in / valid_out");
    $display(" Key_1=%016H", key_1);
    $display(" Key_2=%016H", key_2);
    $display(" Key_3=%016H", key_3);
    $display("=========================================================");

    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 1: Encrypt 5 blocks lien tiep");
    $display("---------------------------------------------------------");
    mode = 1'b1;
    repeat (2) @(negedge clk);
    push_5_blocks(pt[0], pt[1], pt[2], pt[3], pt[4]);
    collect_5_outputs();
    check_5_outputs(ct[0], ct[1], ct[2], ct[3], ct[4], "Encrypt");

    repeat (10) @(negedge clk);

    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 2: Decrypt 5 blocks lien tiep");
    $display("---------------------------------------------------------");
    mode = 1'b0;
    repeat (2) @(negedge clk);
    push_5_blocks(ct[0], ct[1], ct[2], ct[3], ct[4]);
    collect_5_outputs();
    check_5_outputs(pt[0], pt[1], pt[2], pt[3], pt[4], "Decrypt");

    repeat (10) @(negedge clk);

    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 3: Round-trip 1 block");
    $display("---------------------------------------------------------");
    run_single_block(pt[2], 1'b1, ct[2], "Round-trip step 1: Encrypt pt[2]");
    run_single_block(ct[2], 1'b0, pt[2], "Round-trip step 2: Decrypt ct[2]");

    $display("");
    $display("---------------------------------------------------------");
    $display(" TEST 4: Latency measurement");
    $display("---------------------------------------------------------");
    begin : latency_test
        integer lat;
        do_reset();
        mode = 1'b1;

        @(negedge clk);
        plaintext = pt[0];
        valid_in  = 1'b1;
        @(posedge clk); 
        #10;
        valid_in  = 1'b0;

        lat = 0;
        while (valid_out !== 1'b1 && lat < 1000) begin
            @(posedge clk);
            #10;
            lat = lat + 1;
        end

        if (lat >= 1000) begin
            $display("  [TIMEOUT] Khong thay valid_out khi do latency");
            fail_cnt = fail_cnt + 1;
        end else begin
            $display("  Latency do duoc: %0d cycles", lat);
            $display("  Output latency-test = %016H", ciphertext);
            if (ciphertext === ct[0]) begin
                $display("  [PASS] Output dung khi do latency");
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  [FAIL] Output sai khi do latency");
                $display("         Got = %016H", ciphertext);
                $display("         Exp = %016H", ct[0]);
                fail_cnt = fail_cnt + 1;
            end
        end
    end

    $display("");
    $display("=========================================================");
    $display(" KET QUA TONG HOP");
    $display("=========================================================");
    $display(" PASS : %0d / %0d", pass_cnt, pass_cnt + fail_cnt);
    $display(" FAIL : %0d / %0d", fail_cnt, pass_cnt + fail_cnt);
    if (fail_cnt == 0)
        $display(" >> TAT CA PASS - Tri_DES_DeepPipe hoat dong chinh xac!");
    else
        $display(" >> Con %0d FAIL - Can debug!", fail_cnt);
    $display("=========================================================");

    #100;
    $finish;
end

initial begin
    #10000000;
    $display("[WATCHDOG] Timeout - Tri_DES_DeepPipe co the bi treo!");
    $finish;
end

initial begin
    $dumpfile("tb_Tri_DES_DeepPipe.vcd");
    $dumpvars(0, tb_Tri_DES_DeepPipe);
end

endmodule
