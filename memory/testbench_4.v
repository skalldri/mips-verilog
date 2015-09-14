module testbench_4 ();
	
	parameter START_ADDR = 32'h8002_0000; // h80020000

	reg 		clk;
	reg   [31:0]	addr;
	reg   [31:0]	din;
	reg		enable;
	reg		rw;
	reg   [1:0]	access_size;
	
	reg		test_mode;
	reg   [31:0]	int_addr;

	wire  [31:0]	dout;
	wire 		busy;

	mips_memory2    test_memory(.clk(clk), 
			            .addr(addr), 
			            .din(din), 
			            .dout(dout), 
			            .access_size(access_size), 
			            .rw(rw), 
			            .busy(busy), 
			            .enable(enable));

	reg    [7:0]  mem[0:256];

	initial
	begin
		clk = 1'b0;
		enable = 1'b0;
		addr = 32'h8002_0000;
		din =  32'b0000_0000;
		rw = 1'b1;
		access_size = 2'b01;
		test_mode = 0;
		int_addr = 0;
		$readmemh("SumArray.x", mem);
	end

	always @(negedge clk)
	begin
		if ((addr + int_addr) > 32'h8002_00b4 & test_mode == 0)
		begin
			enable = 0;
			if (busy == 0)
			begin
				enable = 1;
				test_mode = 1;
				addr = 32'h8002_0000;
				rw = 1'b0;	
				int_addr = 4;
			end
		end
		else
		begin
			if (test_mode == 0)
			begin
				enable = 1'b1;
				din[31:24] = mem[addr + int_addr - START_ADDR];
				din[23:16] = mem[addr + int_addr + 1 - START_ADDR];
				din[15:8] = mem[addr + int_addr + 2 - START_ADDR];
				din[7:0] = mem[addr + int_addr + 3 - START_ADDR];
		
				int_addr = int_addr + 32'h0000_0004;
	
				if (int_addr == 20)
				begin
					addr = addr + 32'h0000_0010;
					int_addr = 4;
				end
			end
			else
			begin
				enable = 1'b1;
				int_addr = int_addr + 32'h0000_0004;
	
				if (int_addr == 20)
				begin
					addr = addr + 32'h0000_0010;
					int_addr = 4;
				end					
			end
		end
						
	end

	always
		#5 clk = !clk;

endmodule
