module testbench ();
	parameter ROM_FILE = "DivDivDiv.x";

	reg   [31:0]	addr_write;
	reg   [31:0]	din;
	reg		        enable;
	reg		        rw_write;
	reg   [2:0]	    access_size;
	wire 		    stall;
	
	reg		        test_mode;
	
	// General
	reg 		    clk;
	reg   [4:0]		stall_count = 0;
	reg   [4:0]     init_dst;
	reg   [31:0]	init_dval;
	reg 			init_rf_we;
	
	
	// Bypass
	wire [31:0]     aluSrc1Bypass;
	wire [31:0]     aluSrc2Bypass;
	wire [31:0]		dmemDataBypass;
	
	// Memory
	wire  [31:0]    addr;
	wire  [31:0]	mem_dout;
	wire 		    mem_busy;
	wire  [2:0]	    mem_access_size;
	wire		    rw;
	wire		    mem_enable;

	// Fetch
	wire  [31:0]    fetch_pc;
	wire		    fetch_rw;
	wire  [2:0]	    fetch_access_size;
	wire 		    fetch_enable;
	wire            fetch_j;
	
	// Decode
	wire  [5:0]     decode_instbits;
	wire  [5:0]     decode_src1;
	wire  [5:0]     decode_src2;
	wire  [4:0]     decode_dst;
	wire  [15:0] 	decode_imm;
	wire  [4:0]  	decode_funct;
	wire  [25:0] 	decode_addr;
	wire 		    decode_b_ctrl;
	wire  [2:0]	    decode_dmem_func;
	wire  [2:0]     decode_wb_func;
	wire  [1:0]     decode_j;
	reg   [31:0]    decode_pc;
    reg   [31:0]    decode_isn;
	
	// Reg file
	wire 		    rf_we;
	wire  [31:0]	rf_dval;
	wire  [4:0]	    rf_d;
	wire  [31:0]	rf_s1val;
	wire  [31:0]	rf_s2val;

	// ALU
	reg   [31:0]	alu_pc;
	reg   [31:0]	alu_s1val;
	reg   [31:0]	alu_s2val;
	reg   [4:0]	    alu_funct;
	reg   [15:0]	alu_imm;
	reg	  [25:0]    alu_addr;
	reg   [2:0]     alu_dmem_func;
	reg   [2:0]     alu_wb_func;
	reg   [4:0]     alu_dst;
	reg   [4:0]     alu_src1;
	reg   [4:0]     alu_src2;
	wire  [31:0]    alu_res;
    reg   [31:0]    alu_isn;
	reg   			alu_b_ctrl;
	reg   [1:0]     alu_j;
	wire  [31:0]    alu_a;
	wire  [31:0]    alu_b;
	wire  [31:0]    alu_br_tgt;
	wire  [31:0]    alu_sx;
	wire            alu_z;
	wire  [31:0]    alu_j_tgt;
	
	assign alu_a = aluSrc1Bypass;
	assign alu_br_tgt = (alu_pc + 4) + (alu_sx << 2);
	assign alu_sx = {{16{alu_imm[15]}}, {alu_imm[15:0]}};
	assign alu_j_tgt = (alu_j == 1) ? ((alu_pc & 32'hf000_0000) | (alu_addr << 2)): alu_s2val;
	
	// Mux the sign-extension and register file branches for the ALU B input
	assign alu_b = (alu_b_ctrl == 1 ? alu_sx : aluSrc2Bypass);
	
	// DATA
	wire  [31:0]    data_addr;
	wire  [31:0]	data_din;
	wire  [31:0]	data_dout;
	wire 		    data_busy;
	wire  [2:0]	    data_access_size;
	wire		    data_rw;
	wire		    data_enable;
	reg   [31:0]	data_pc;
	reg   [4:0]     data_dst;
	reg   [31:0]	data_res;
	reg   [31:0]	data_s2;
	reg   [4:0]     data_src2_reg;
	reg   [31:0]    data_isn;
	reg   [31:0]    data_br_tgt;
	reg   [2:0]     data_mem_func; // Bit 0 = enable / !disable, Bit 1 = w / !r, Bit 2 = byte / !word
	reg   [2:0]     data_wb_func;
	
	assign data_rw = data_mem_func[1] ? 1 : 0;
	assign data_access_size = data_wb_func[2] ? 'b101 : data_mem_func[2] ? 3'b100 : 3'b000;
	assign data_enable = data_mem_func[0] ? 1 : 0;
	assign data_din = dmemDataBypass; // Data value = Source 2 operand from ALU stage
	assign data_addr = data_res; // Data address == ALU result
	
	// Writeback
	
	reg   [4:0]     write_dst;
	wire  [31:0]    write_dval;
	reg   [31:0]    write_res;
	wire   [31:0]   write_dout;
	wire   			write_rf_we;
	reg   [2:0]	    write_func;
	
	assign write_dval = write_func[1] ? write_res : write_dout;
	assign write_rf_we = write_func[0];
	assign write_dout = data_dout;
	
	// Bypass
	// Bypass ALU input if the data memory stage has more recent data
	// Note we don't have to check what the data memory is doing at this point since we will stall if the data memory is doing something
	assign aluSrc1Bypass = (alu_src1 == data_dst && data_dst != 0 && data_mem_func[0] == 0) ? data_res : (alu_src1 == data_dst && data_dst != 0 && data_mem_func[0] == 1) ? data_dout : (alu_src1 == write_dst && write_dst != 0 ? write_dval : alu_s1val);
	assign aluSrc2Bypass = (alu_src2 == data_dst && data_dst != 0 && data_mem_func[0] == 0) ? data_res : (alu_src2 == data_dst && data_dst != 0 && data_mem_func[0] == 1) ? data_dout : (alu_src2 == write_dst && write_dst != 0 ? write_dval : alu_s2val);
	assign dmemDataBypass = (data_src2_reg == write_dst && write_dst != 0) ? write_dval : data_s2;
	
	mips_memory2  #(ROM_FILE)  test_memory(.clk(clk), 
											.addr(addr),
											.din(din), 
											.dout(mem_dout), 
											.access_size(mem_access_size), 
											.rw(rw), 
											.busy(mem_busy), 
											.enable(mem_enable));

	fetch			            fetch_unit(.clk(clk),
										   .busy(mem_busy),
										   .stall(stall),
										   .pc(fetch_pc),
										   .rw(fetch_rw),
										   .access_size(fetch_access_size),
										   .enable(fetch_enable),
										   .j_addr(alu_j_tgt),
										   .jump(fetch_j),
										   .br_addr(alu_br_tgt),
										   .branch(alu_z));

	decode			 			decode_unit(.clk(clk),
											.insn(decode_isn),
											.pc(decode_pc),
											.instbits(decode_instbits),
											.imm(decode_imm),
											.funct(decode_funct),
											.addr(decode_addr),
											.src1(decode_src1),
											.src2(decode_src2),
											.dst(decode_dst),
											.b_ctrl(decode_b_ctrl),
											.dmem_func(decode_dmem_func),
											.wb_func(decode_wb_func),
											.j(decode_j));
	
	register_file			   reg_file(.clk(clk),
										 .we(rf_we),
										 .dval(rf_dval),
										 .s1(decode_src1),
										 .s2(decode_src2),
										 .d(rf_d),
										 .s1val(rf_s1val),
										 .s2val(rf_s2val),
										 .pc(decode_pc));

	alu			 				mips_alu(.a_input(alu_a),
										 .b_input(alu_b),
										 .funct(alu_funct),
										 .res(alu_res),
										 .z(alu_z));
	            
	data_memory2  #(ROM_FILE)   data_memory(.clk(clk), 
											.addr(data_addr),
											.din(data_din), 
											.dout(data_dout), 
											.access_size(data_access_size), 
											.rw(data_rw), 
											.busy(data_busy), 
											.enable(data_enable));			
	assign addr = fetch_pc;
	assign mem_access_size = fetch_access_size;
	assign rw = fetch_rw;
	assign mem_enable = fetch_enable;
	assign rf_d = write_dst;
	assign rf_dval = write_dval;
	assign rf_we = write_rf_we;
	assign fetch_j = (alu_j != 0);
	
	// If insn in front of us is reading from data memory AND writing back to a register AND we're using that register AND next instruction isn't a store
	// OR
	// If waiting for a jump or a branch
	//             (          memory operation is load            ) AND (( FD Src1 == DX Dst   ) OR ((   FD Src2 == DX Dst  ) AND (FD Mem Op != STORE)                                                        
	assign stall = (((alu_dmem_func[0] == 1 && alu_dmem_func[1] == 0) && ((decode_src1 == alu_dst) || ((decode_src2 == alu_dst) && decode_dmem_func[1] != 1))) | (alu_j != 0) | alu_z == 1) ? 1 : 0;
	
	initial
	begin
		clk = 1'b0;
		enable = 1'b1;
		addr_write = 32'h8001_fffc;
		din =  32'b0000_0000;
		rw_write = 1'b1;
		access_size = 2'b00;
		test_mode = 0;
		init_dval = 0;
		init_dst = 0;
		init_rf_we = 0;
		alu_j = 0;
		write_func = 0;
		write_dst = 0;
		data_dst = 0;
		data_wb_func = 0;
		alu_dst = 0;
		alu_wb_func = 0;
		alu_src1 = 0;
		alu_src2 = 0;
		data_mem_func = 0;
		data_src2_reg = 0;
	end

	always @(posedge clk)
	begin		
		// Only dispatch one instruction every 5 cycles
		// M/W
		write_dst = data_dst;
		write_func = data_wb_func;
		write_res = data_res;
		
		// X/M
		data_res = alu_res;
		data_s2 = aluSrc2Bypass;
		data_isn = alu_isn;
		data_pc = alu_pc;
		data_br_tgt = alu_br_tgt;
		data_mem_func = alu_dmem_func;
		data_dst = alu_dst;
		data_wb_func = alu_wb_func;
		data_src2_reg = alu_src2;
		
		// D/X
		if(stall == 0)
		begin
			alu_pc = decode_pc;
			alu_s1val = rf_s1val;
			alu_s2val = rf_s2val;
			alu_b_ctrl = decode_b_ctrl;
			alu_funct = decode_funct;
			alu_isn = decode_isn;
			alu_imm = decode_imm;
			alu_addr = decode_addr;
			alu_dmem_func = decode_dmem_func;
			alu_dst = decode_dst;
			alu_wb_func = decode_wb_func;
			alu_j = decode_j;
			alu_src1 = decode_src1;
			alu_src2 = decode_src2;
		end
		else
		begin
			alu_pc = decode_pc;
			alu_s1val = 0;
			alu_s2val = 0;
			alu_b_ctrl = 0;
			alu_funct = 0;
			alu_isn = 0;
			alu_imm = 0;
			alu_addr = 0;
			alu_dmem_func = 0;
			alu_dst = 0;
			alu_wb_func = 0;
			alu_j = 0;
			alu_src1 = 0;
			alu_src2 = 0;
		end
		
		if(stall == 0)
		begin
			// F/D
			decode_pc = addr;
			decode_isn = mem_dout;
		end
		
	end

	always @(negedge clk)
	begin
		if(alu_z == 1)
		begin
			$display("Branch target is %h", alu_br_tgt);
		end
		if(alu_j != 0)
		begin
			$display("Jump target is %h", alu_j_tgt);
		end
	end

	always
		#5 clk = !clk;

endmodule

