
//TODO: make memory do... something... when given an address not in range 0x80020000 -> (0x80020000 + Memory Size)


module mips_memory (clk, addr, din, dout, access_size, rw, busy, enable);

parameter MEMSIZE = 1024;
parameter START_ADDR = 32'h8002_0000; // h80020000

// input
	input         clk;
	input [31:0]  addr;
	input [31:0]  din;
	input [1:0]   access_size;
	input 	      rw; //1 is write, 0 is read
	input	      enable;

// output
	output 	      busy;
	output [31:0] dout;

	reg    [31:0] dout_driver;
	wire   [31:0] dout = dout_driver;

	wire	      busy;
	
// memory
	reg    [7:0]  mem[0:MEMSIZE];

// local variables
	wire	      should_respond;	// = enable & !busy
	wire [4:0]    cycles_remaining;	// = 1, 4, 8, 16 for rw = 00, 01, 10, 11
	reg  [7:0]    cycle_counter = 0;
	reg	      operating;
	reg  [31:0]   current_addr = 0;	// increment by 1 after each cycle
	reg	      current_rw = 0;	// saves rw status for cycles to come
	
// combinational 
	assign should_respond = (enable & !busy);
	assign cycles_remaining = (access_size == 2'b00) ? 1 : ((access_size == 2'b01) ? 4 : ((access_size == 2'b10) ? 8 : ((access_size == 2'b11) ? 16 : 0 ))); 
	assign busy = (cycles_remaining != cycle_counter) & (cycle_counter != 0) & (cycles_remaining > 1);

// set up
	/*integer       i;

	initial
	begin
		cycle_counter = 0;
		current_addr = 0;
		current_rw = 0;
		
		for (i=0; i<180; i=i+1)
      			mem[i] <= 0;
    	end*/
	
// procedural

// do r/w, use local variables
	always @(posedge clk)
	begin
		// if first cycle, set address + cycle + rw
		if (should_respond == 1'b1)
		begin
			current_rw = rw;
			current_addr = (addr - START_ADDR); //Convert to internal addresses
			cycle_counter = 0;
			operating = 1;
		end
	end

	always @(negedge clk)
	begin
		if (cycle_counter != cycles_remaining && operating == 1)
		begin
			if (current_rw == 1'b1)
			begin
				//Do write, needs to support various "access_size"
				mem[current_addr]   <= din[31:24];   // MSB
				mem[current_addr+1] <= din[23:16];
				mem[current_addr+2] <= din[15:8];
				mem[current_addr+3] <= din[7:0]; // LSB
			end
			else
			begin
				//Do read, needs to support various "access_size"
				dout_driver[31:24] <= mem[current_addr];   // MSB
				dout_driver[23:16] <= mem[current_addr+1];
				dout_driver[15:8]  <= mem[current_addr+2];
				dout_driver[7:0]   <= mem[current_addr+3]; // LSB
			end
			cycle_counter = cycle_counter + 1;
			current_addr = current_addr + 4;
		end
		else
		begin
			operating = 0;
		end
	end

endmodule
