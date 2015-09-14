module testbench ();
	
	parameter START_ADDR = 32'h80020000;

	// test
	reg   [31:0]	test_counter;	

	// global
	reg 		clk;

	// fetch in
	reg		stall;
	reg		reset;

	// fetch out, mem in, decode in
	wire   [31:0]	addr;	
	reg		rw;
	wire   [1:0]	access_size;
	wire		enable;

	// mem in
	reg   [31:0]	din;

	// mem out
	wire		busy;

	// mem out, decode in
	wire  [31:0]	dout;


	fetch		test_fetch(.clk(clk), 
				   .stall(stall), 
				   .reset(reset), 
				   .pc(addr), 
				   .rw(), 
				   .access_size(access_size), 
				   .enable(enable));

	mips_memory2    test_memory(.clk(clk), 
			            .addr(addr), 
			            .din(din), 
			            .dout(dout), 
			            .access_size(access_size), 
			            .rw(rw), 
			            .busy(busy), 
			            .enable(enable));

	/*decode		test_decode(.clk, 
				    .insn, 
				    .pc, 
				    .instbits, 
				    .op, 
				    .src1, 
				    .src2, 
				    .dst);*/

	reg    [7:0]  mem[0:256];

	initial
	begin
		clk = 1'b1;

		test_counter = 0;

		stall = 0;
		reset = 0;

		rw = 1;
		
		din =  32'b0000_0000;

		$readmemh("SumArray.x", mem);
	end

	

	always @(posedge clk)
	begin
		if (test_counter <= 2)
		begin
			test_counter <= test_counter + 1;
			reset <= 1;
			din <= 'x;
			$display("1");
		end
		else if (test_counter > 2 && test_counter <= 15)
		begin
			test_counter <= test_counter + 1;
			reset <= 0;			
			din[31:24] = mem[addr - START_ADDR];
			din[23:16] = mem[addr + 1 - START_ADDR];
			din[15:8] = mem[addr + 2 - START_ADDR];
			din[7:0] = mem[addr + 3 - START_ADDR];
			$display("2");
		end
		else
		begin
			test_counter <= 0;
			reset <= 1;
			din <= 'x;
			rw <= !rw;
			$display("3");
		end
	end

	always
		#5 clk = !clk;

endmodule
