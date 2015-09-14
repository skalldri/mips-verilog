module fetch (clk, stall, busy, pc, rw, access_size, enable, j_addr, jump, br_addr, branch);

parameter START_ADDR = 32'h8002_0000;

// input
	input         clk;
	input	      stall;
	input	      busy;
	input [31:0]  j_addr;
	input 		  jump;
	input [31:0]  br_addr;
	input 		  branch;

// output
	output [31:0] pc;
	output [2:0]  access_size;
	output 	      rw; //1 is write, 0 is read
	output	      enable;

// local
	reg  [31:0]   pc_reg	= 32'h8001_FFFC; // current address
	reg  [2:0]    access_size_reg  = 3'b000;
	reg  	      rw_reg = 1'b0;
	reg  	      enable_reg = 1'b1;

// comb
	assign pc = pc_reg;
	assign access_size = access_size_reg;
	assign rw = rw_reg;
	assign enable = enable_reg;

// proc
	always @(posedge clk)
	begin
		if(stall != 1 & busy != 1)
		begin
			if(jump != 1 & branch != 1)
			begin
				pc_reg = pc_reg + 32'h0000_0004;
			end
			else if (branch == 1)
			begin
				pc_reg = br_addr;
			end
			else if(jump == 1)
			begin
				pc_reg = j_addr;
			end
		end
		else if (branch == 1)
		begin
			pc_reg = br_addr;
		end
		else if(jump == 1)
		begin
			pc_reg = j_addr;
		end
	end

endmodule
