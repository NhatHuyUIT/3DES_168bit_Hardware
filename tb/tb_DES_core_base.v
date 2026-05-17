`timescale 1ns / 1ps

module tb_DES_core_base;

reg         clk, rst, start;
reg  [63:0] plaintext, key;
reg         mode;
wire        done;
wire [63:0] ciphertext;

DES_core_base uut (
    .clk       (clk),
    .rst       (rst),
    .start     (start),
    .mode      (mode),
    .plaintext (plaintext),
    .key       (key),
    .done      (done),
    .ciphertext(ciphertext)
);

always #5 clk = ~clk;
integer pass_cnt, fail_cnt;

task run_one;
    input [63:0]  pt_in;
    input [63:0]  key_in;
    input         mode_in;
    input [63:0]  exp_out;
    input [127:0] label;
    integer timeout;
    begin
        @(negedge clk);
        plaintext = pt_in; 
        key = key_in; 
        mode = mode_in; 
        start = 1'b1;
        @(negedge clk); 
        start = 1'b0;
        timeout = 0;
        while (done !== 1'b1 && timeout < 100) begin @(posedge clk); 
            #1; 
            timeout = timeout + 1;
        end
        if (timeout >= 100) begin
            $display("  [TIMEOUT] %0s", label); 
            fail_cnt = fail_cnt + 1;
        end else if (ciphertext === exp_out) begin
            $display("  [PASS] %0s | Out = %016H", label, ciphertext); 
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  [FAIL] %0s | Got=%016H Exp=%016H", label, ciphertext, exp_out);
            fail_cnt = fail_cnt + 1;
        end
        repeat(3) @(negedge clk);
    end
endtask

initial begin
    clk=0; 
    rst=1; 
    start=0; 
    mode=1; 
    plaintext=0; 
    key=0;
    pass_cnt=0; 
    fail_cnt=0;
    repeat(4) @(negedge clk); 
    rst=0; 
    repeat(2) @(negedge clk);

    $display("==========================================================");
    $display(" DES_core_base Testbench (1 cycle/round, 16 cycles/block)");
    $display("==========================================================");

    $display("\n[Test 1] Encrypt NIST FIPS 46-3");
    run_one(64'h0123456789ABCDEF, 64'h133457799BBCDFF1, 1'b1, 64'h85E813540F0AB405, "Encrypt NIST    ");

    $display("\n[Test 2] Decrypt NIST FIPS 46-3");
    run_one(64'h85E813540F0AB405, 64'h133457799BBCDFF1, 1'b0, 64'h0123456789ABCDEF, "Decrypt NIST    ");

    $display("\n[Test 3] Encrypt block thu 2");
    run_one(64'hDEADBEEFCAFEBABE, 64'hAABBCCDDEEFF0011, 1'b1, 64'hD40205D299C658B8, "Encrypt block 2  ");

    $display("\n[Test 4] Round-trip (Decrypt block thu 2)");
    run_one(64'hD40205D299C658B8, 64'hAABBCCDDEEFF0011, 1'b0, 64'hDEADBEEFCAFEBABE, "Decrypt block 2  ");

    $display("\n[Test 5] Dem chu ky xu ly");
    begin : cycle_count
        integer cycles;
        @(negedge clk); 
        plaintext=64'h0123456789ABCDEF; 
        key=64'h133457799BBCDFF1; 
        mode=1; 
        start=1;
        @(negedge clk); 
        start=0; 
        cycles=0;
        while (done!==1'b1 && cycles<100) begin 
            @(posedge clk); 
            #1; 
            cycles=cycles+1; 
        end
        $display("  So chu ky: %0d cycles (Ly thuyet: 16 rounds x 1 cycle = 16)", cycles);
        if (cycles==16) 
            $display("  [PASS] Dung 16 cycles");
        else            
            $display("  [INFO] %0d cycles", cycles);
    end

    $display("\n==========================================================");
    $display(" PASS: %0d | FAIL: %0d", pass_cnt, fail_cnt);
    if (fail_cnt==0) 
        $display(" >> TAT CA PASS");
    else             
        $display(" >> Con %0d FAIL", fail_cnt);
    $display("==========================================================");
    #50; 
    $finish;
end

initial begin 
    #50000; 
    $display("[WATCHDOG] Timeout!"); 
    $finish; 
end

initial begin 
    $dumpfile("tb_DES_core_base.vcd"); 
    $dumpvars(0, tb_DES_core_base); 
end

endmodule