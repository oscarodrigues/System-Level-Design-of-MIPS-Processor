module mips_test();
reg CK;
reg RESET;
wire DONE;
wire [4:0] OUTADDR;
wire [31:0] OUTDATA;
wire OUTVALID;
reg [15:0] COUNT;
mips U0 (CK, RESET, DONE, OUTADDR, OUTDATA, OUTVALID);
initial
begin
CK=0;
RESET=1;
COUNT=0;
end
always #10 CK = ~ CK;
always @(posedge CK)
begin
RESET <= 0;
if (!RESET && OUTVALID) $display("%04x %2x = %08x",COUNT,OUTADDR,OUTDATA);
COUNT <= COUNT + 1;
if (DONE) $finish;
end
endmodule