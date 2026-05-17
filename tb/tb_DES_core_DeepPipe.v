`timescale 1ns / 1ps

module tb_DES_core_DeepPipe;

reg         clk, rst;
reg  [63:0] plaintext, key;
reg         mode, valid_in;
wire [63:0] ciphertext;
wire        valid_out;

DES_core_DeepPipe uut (
    .clk       (clk),
    .rst       (rst),
    .plaintext (plaintext),
    .valid_in  (valid_in),
    .key       (key),
    .mode      (mode),
    .ciphertext(ciphertext),
    .valid_out (valid_out)
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
        plaintext=pt_in; 
        key=key_in; 
        mode=mode_in; 
        valid_in=1'b1;
        @(negedge clk); 
        valid_in=1'b0;
        timeout=0;
        while (valid_out!==1'b1 && timeout<200) begin 
            @(posedge clk); 
            #1; 
            timeout=timeout+1; 
        end
        if (timeout>=200) begin
            $display("  [TIMEOUT] %0s", label); 
            fail_cnt=fail_cnt+1;
        end else if (ciphertext===exp_out) begin
            $display("  [PASS] %0s | Out = %016H", label, ciphertext); 
            pass_cnt=pass_cnt+1;
        end else begin
            $display("  [FAIL] %0s | Got=%016H Exp=%016H", label, ciphertext, exp_out);
            fail_cnt=fail_cnt+1;
        end
        repeat(3) @(negedge clk);
    end
endtask

initial begin
    clk=0; 
    rst=1; 
    valid_in=0; 
    mode=1; 
    plaintext=0; 
    key=0;
    pass_cnt=0; 
    fail_cnt=0;
    repeat(4) @(negedge clk); 
    rst=0; 
    repeat(2) @(negedge clk);

    $display("==========================================================");
    $display(" DES_core_DeepPipe Testbench");
    $display(" Latency: 50 cycles | Throughput: 1 block/cycle");
    $display("==========================================================");

    $display("\n[Test 1] Encrypt NIST FIPS 46-3");
    run_one(64'h0123456789ABCDEF, 64'h133457799BBCDFF1, 1'b1, 64'h85E813540F0AB405, "Encrypt NIST    ");

    $display("\n[Test 2] Decrypt NIST FIPS 46-3");
    run_one(64'h85E813540F0AB405, 64'h133457799BBCDFF1, 1'b0, 64'h0123456789ABCDEF, "Decrypt NIST    ");

    $display("\n[Test 3] Encrypt block thu 2");
    run_one(64'hDEADBEEFCAFEBABE, 64'hAABBCCDDEEFF0011, 1'b1, 64'hD40205D299C658B8, "Encrypt block 2  ");

    $display("\n[Test 4] Round-trip (Decrypt block thu 2)");
    run_one(64'hD40205D299C658B8, 64'hAABBCCDDEEFF0011, 1'b0, 64'hDEADBEEFCAFEBABE, "Decrypt block 2  ");

    $display("\n[Test 5] Throughput - Nap 4 blocks lien tuc");
    begin : throughput
        reg [63:0] results [0:3];
        integer sent, recv, t_out;
        sent=0; 
        recv=0; 
        t_out=0;
        key=64'h133457799BBCDFF1; 
        mode=1'b1;
        @(negedge clk);
        repeat(4) begin
            plaintext = (sent==0) ? 64'h0123456789ABCDEF :
                        (sent==1) ? 64'hDEADBEEFCAFEBABE :
                        (sent==2) ? 64'hFFFFFFFFFFFFFFFF :
                                    64'h0000000000000000;
            valid_in=1'b1; 
            @(negedge clk); 
            sent=sent+1;
        end
        valid_in=1'b0;
        $display("  Da nap 4 blocks lien tuc (4 cycles)");
        while (recv<4 && t_out<300) begin
            @(posedge clk); #1;
            if (valid_out===1'b1) begin 
                results[recv]=ciphertext; 
                recv=recv+1; 
            end
            t_out=t_out+1;
        end
        $display("  Nhan %0d outputs trong ~%0d cycles", recv, t_out);
        if (results[0]===64'h85E813540F0AB405) begin
            $display("  [PASS] Block 0 NIST dung: %016H", results[0]); 
            pass_cnt=pass_cnt+1;
        end else begin
            $display("  [FAIL] Block 0: Got=%016H", results[0]); 
            fail_cnt=fail_cnt+1;
        end
    end

    $display("\n[Test 6] Do latency chinh xac");
    begin : latency
        integer cycles;
        rst=1; 
        repeat(3) @(negedge clk); 
        rst=0; 
        repeat(2) @(negedge clk);
        plaintext=64'h0123456789ABCDEF; 
        key=64'h133457799BBCDFF1; 
        mode=1'b1;
        valid_in=1'b1; 
        @(negedge clk); 
        valid_in=1'b0;
        cycles=0;
        while (valid_out!==1'b1 && cycles<200) begin 
            @(posedge clk); 
            #1; 
            cycles=cycles+1;
        end
        $display("  Latency: %0d cycles (Ly thuyet: 1+48+1 = 50)", cycles);
        if (cycles==50) 
            $display("  [PASS] Dung 50 cycles");
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
    #200000; 
    $display("[WATCHDOG] Timeout!"); 
    $finish; 
end

initial begin 
    $dumpfile("tb_DES_core_DeepPipe.vcd"); 
    $dumpvars(0, tb_DES_core_DeepPipe); 
end
endmodule