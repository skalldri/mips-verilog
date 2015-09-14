module testbench ();
	
	parameter START_ADDR = 32'h8001_fffc; // h80020000

	reg 		clk;
	reg   [31:0]	addr_write;
	reg   [31:0]	din;
	reg		enable;
	reg		rw_write;
	reg   [2:0]	access_size;
	reg 		stall;
	
	
	reg		test_mode;

	wire  [31:0]	dout;
	wire 		busy;
	wire  [31:0]    addr;
	wire  [31:0]    pc;
	wire		rw;
	wire		rw_fetch;
	wire  [2:0]	access_size_fetch;
	wire  [2:0]	access_size_mem;
	wire 		enable_fetch;
	wire		enable_mem;
	wire  [5:0]     instbits;
	wire  [1:0]     op; // r = 00, j = 01, i = 10
	wire  [4:0]     src1;
	wire  [4:0]     src2;
	wire  [4:0]     dst;
	wire  [31:0]    pc_mem;

	mips_memory2    test_memory(.clk(clk), 
			            .addr(addr), 
			            .din(din), 
			            .dout(dout), 
			            .access_size(access_size_mem), 
				    .pc(pc_mem),
			            .rw(rw), 
			            .busy(busy), 
			            .enable(enable_mem));

	fetch		fetch_unit(.clk(clk),
				   .busy(busy),
				   .stall(stall),
				   .pc(pc),
				   .rw(rw_fetch), 
				   .access_size(access_size_fetch), 
				   .enable(enable_fetch));

	decode 		decode_unit(.clk(clk),
				    .insn(dout),
				    .pc(pc_mem));
			            
	reg    [7:0]  mem[0:512];


	assign addr = (test_mode == 0) ? addr_write : pc;
	assign access_size_mem = (test_mode == 0) ? access_size : access_size_fetch;
	assign rw = (test_mode == 0) ? rw_write : rw_fetch;
	assign enable_mem = (test_mode == 0) ? enable : enable_fetch;

	initial
	begin
		clk = 1'b0;
		enable = 1'b1;
		addr_write = 32'h8001_fffc;
		din =  32'b0000_0000;
		rw_write = 1'b1;
		access_size = 3'b000;
		test_mode = 0;
		stall = 1'b1;
		$readmemh("BubbleSort.x", mem);
	end

	always @(negedge clk)
	begin
		if (test_mode == 0)
		begin		
			din[31:24] = mem[addr_write - START_ADDR];
			din[23:16] = mem[addr_write + 1 - START_ADDR];
			din[15:8] = mem[addr_write + 2 - START_ADDR];
			din[7:0] = mem[addr_write + 3 - START_ADDR];
			addr_write = addr_write + 32'h0000_0004;
		end
		else
		begin
			addr_write = addr_write + 32'h0000_0004;
		end

		if (addr_write > 32'h8002_01a4 & test_mode == 0)
		begin
			test_mode = 1;
			addr_write = 32'h8002_0000;
			rw_write = 1'b0;
			stall = 1'b0;
		end				
	end

	always
		#5 clk = !clk;

endmodule

