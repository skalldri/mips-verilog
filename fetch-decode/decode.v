//  display the PC, instruction bits, operation type, the source and destination operands
module decode (clk, insn, pc, src1, src2, dst, imm, instbits, funct, addr, b_ctrl, dmem_func, wb_func, j);

// input
	input	      clk;
	input  [31:0] insn;
	input  [31:0] pc;

// output
	output [5:0]  src1;
	output [5:0]  src2;
	output [4:0]  dst;
	output [15:0] imm;
	output [4:0]  funct;
	output [5:0]  instbits;
	output [25:0] addr;
	output        b_ctrl;
	output [2:0]  dmem_func;
	output [2:0]  wb_func;
	output [1:0]  j;

// local
	reg  [31:0]   pc_reg = 0;
	reg  [5:0]    instbits = 0;
	reg  [5:0]    src1 = 0;
	reg  [5:0]    src2 = 0;
	reg  [4:0]    dst = 0;
	reg  [15:0]   imm = 0;
	reg  [4:0]    funct = 0;
	reg  [25:0]   addr = 0;
	reg  		  b_ctrl = 0;
	reg  [2:0]    dmem_func = 0;
	reg  [2:0]    wb_func = 0;
	reg	 [1:0]    j = 0;

	// for next lab
	wire [5:0]    inst_wire;
	wire [4:0]    rs_wire;
	wire [4:0]    rt_wire;
	wire [4:0]    rd_wire;	
	wire [4:0]    sa_wire;
	wire [5:0]    fn_wire;
	wire [15:0]   imm_wire;
	wire [25:0]   idx_wire;

// comb
	assign inst_wire = insn[31:26];
	assign rs_wire = insn[25:21];
	assign rt_wire = insn[20:16];
	assign rd_wire = insn[15:11];
	assign sa_wire = insn[10:6];		
	assign fn_wire = insn[5:0];
	assign imm_wire = insn[15:0];
	assign idx_wire = insn[25:0];

// proc
	always @(insn)
	begin
		// save
		pc_reg = pc;

		// decode
		instbits[5:0] = inst_wire;

		if (inst_wire[5:0] == 'b000000)
		begin
			// r-type			
			if (fn_wire == 'b000000)
			begin
				if (rt_wire == 'b00000 && rd_wire == 'b00000 && sa_wire == 'b00000)
				begin
					// nop
					src1 = rs_wire;
					src2 = rt_wire;
					dst = rd_wire;
					funct = 'b00000;
					imm[15:5] = 0;
					imm[4:0] = sa_wire;
					addr = 0;
					b_ctrl = 0;
					dmem_func = 3'b000; // Data memory is not used
					wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
					j = 0;
					$display("%h\tNOP", pc);
				end
				else
				begin
					// sll
					src1 = rt_wire;
					src2 = 0;
					dst = rd_wire;
					funct = 'b00000;
					imm[15:5] = 0;
					imm[4:0] = sa_wire;
					addr = 0;
					b_ctrl = 1; // Use the imm value instead of src2
					dmem_func = 3'b000; // Data memory is not used
					wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
					j = 0;
					$display("%h\tSLL\tR%d, R%d, %d", pc, rd_wire, rt_wire, sa_wire);
				end
			end
			else if (fn_wire == 'b000010)
			begin
				// srl
				src1 = rt_wire;
				src2 = 0;
				dst = rd_wire;
				funct = 'b00001;
				imm[15:5] = 0;
				imm[4:0] = sa_wire;
				addr = 0;
				b_ctrl = 1; // Use the imm value instead of src2
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSRL\tR%d, R%d, %d", pc, rd_wire, rt_wire, sa_wire);
			end
			else if (fn_wire == 'b000011)
			begin			
				// sra
				src1 = rt_wire;
				src2 = 0;
				dst = rd_wire;
				funct = 'b00010;
				imm[15:5] = 0;
				imm[4:0] = sa_wire;
				addr = 0;
				b_ctrl = 1;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSRA\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b000100)
			begin
				// sllv
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b00000;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSLLV\tR%d, R%d, R%d", pc, rd_wire, rt_wire, rs_wire);
			end
			else if (fn_wire == 'b000110)
			begin
				// srlv
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b00001;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSRLV\tR%d, R%d, R%d", pc, rd_wire, rt_wire, rs_wire);
			end
			else if (fn_wire == 'b000111)
			begin
				// srav
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b00010;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSRAV\tR%d, R%d, R%d", pc, rd_wire, rt_wire, rs_wire);
			end
			else if (fn_wire == 'b001000)
			begin
				// jr
				src1 = 0;
				src2 = rs_wire;
				dst = 0;
				funct = 'b00000;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 2;
				
				$display("%h\tJR\tR%d", pc, rs_wire);
			end
			else if (fn_wire == 'b001001)
			begin
				// jalr
				src1 = 32;
				src2 = rs_wire;
				dst = rd_wire;
				funct = 'b01001; // Add src1 + imm, store in dst
				imm = 'b0000000000000100; // 4
				addr = 0;
				b_ctrl = 1; // Read B input from imm with SX
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 2;
				
				$display("%h\tJALR\tR%d, R%d", pc, rd_wire, rs_wire);
			end
			else if (fn_wire == 'b010000)
			begin
				// mfhi
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b00011;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				
				$display("%h\tMFHI\tR%d", pc, rd_wire);
			end
			else if (fn_wire == 'b010010)
			begin
				// mflo
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b00100;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				
				$display("%h\tMFLO\tR%d", pc, rd_wire);
			end
			else if (fn_wire == 'b011010)
			begin
				// div
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b00110;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tDIV\tR%d, R%d", pc, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b011011)
			begin
				// divu
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b00111;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tDIVU\tR%d, R%d", pc, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100000)
			begin
				// add rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01000;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tADD\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100001)
			begin
				// addu rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01001;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tADDU\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100010)
			begin
				// sub rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01010;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSUB\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100011)
			begin
				// subu rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01010;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSUBU\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100100)
			begin
				// and rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01100;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tAND\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100101)
			begin
				// or rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01101;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tOR\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100110)
			begin
				// xor rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01110;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tXOR\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b100111)
			begin
				// nor rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b01111;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tNOR\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b101010)
			begin
				// slt rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b10000;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSLT\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else if (fn_wire == 'b101011)
			begin
				// sltu rd, rs, rt
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = 'b10001;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tSLTU\tR%d, R%d, R%d", pc, rd_wire, rs_wire, rt_wire);
			end
			else
			begin
				src1 = rs_wire;
				src2 = rt_wire;
				dst = rd_wire;
				funct = fn_wire;
				imm = 0;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				$display("%h\tUNDEF %b", pc, insn);
			end
		end
		
		else if (inst_wire[5:0] == 'b000001)
		begin			
			if (rt_wire == 'b00000)
			begin
				src1 = rs_wire;
				src2 = 0;
				dst = 0;
				funct = 'b10100;
				imm = imm_wire;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				// bltz
				$display("%h\tBLTZ R%d, %d", pc, rs_wire, $signed(imm_wire));
			end
			else if (rt_wire == 'b00001)
			begin
				src1 = 0;
				src2 = rs_wire;
				dst = 0;
				funct = 'b10110;
				imm = imm_wire;
				addr = 0;
				b_ctrl = 0;
				dmem_func = 3'b000; // Data memory is not used
				wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
				j = 0;
				// bgez
				$display("%h\tBGEZ R%d, %d", pc, rs_wire, $signed(imm_wire));
			end
			else
			begin
				$display("%h\tUNDEF %b", pc, insn);
			end
		end
		
		else if (inst_wire[5:0] == 'b000010)
		begin
			src1 = 0;
			src2 = 0;
			dst = 0;
			funct = 'b01001;
			imm = 0;
			addr = idx_wire;
			b_ctrl = 0;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 1;
			// j
			$display("%h\tJ\t%h", pc, idx_wire);
		end
		else if (inst_wire[5:0] == 'b000011)
		begin
			src1 = 32;
			src2 = 0;
			dst = 31;
			funct = 'b01001; // Add 4 to the program counter value
			imm = 'b0000000000000100; // 4
			addr = idx_wire;
			b_ctrl = 1;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 1;
			// jal
			$display("%h\tJAL\t%h", pc, idx_wire);
		end
		else if (inst_wire[5:0] == 'b000100)
		begin
			src1 = rs_wire;
			src2 = rt_wire;
			dst = 0;
			funct = 'b10011;			
			imm = imm_wire;
			addr = 0;
			b_ctrl = 0;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// beq
			$display("%h\tBEQ\tR%d, R%d, %d", pc, rs_wire, rt_wire, $signed(imm_wire));
		end		
		else if (inst_wire[5:0] == 'b000101)
		begin
			src1 = rs_wire;
			src2 = rt_wire;
			dst = 0;
			funct = 'b10101;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 0;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// bne
			$display("%h\tBNE\tR%d, R%d, %d", pc, rs_wire, rt_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b000110)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = 0;
			funct = 'b10110;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 0;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// blez
			$display("%h\tBLEZ\tR%d, %d", pc, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b000111)
		begin
			src1 = 0;
			src2 = rs_wire;
			dst = 0;
			funct = 'b10110;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 0;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// bgtz
			$display("%h\tBGTZ\tR%d, %d", pc, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b001001)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b01000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// addiu
			$display("%h\tADDIU\tR%d, R%d, %d", pc, rt_wire, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b001010)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b10000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// slti
			$display("%h\tSLTI\tR%d, R%d, %d", pc, rt_wire, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b001011)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b10001;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// sltiu
			$display("%h\tSLTIU\tR%d, R%d, %d", pc, rt_wire, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b001101)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b01101;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// ori
			$display("%h\tORI\tR%d, R%d, %d", pc, rt_wire, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b001100)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b01100;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1;
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// andi
			$display("%h\tANDI\tR%d, R%d, %d", pc, rt_wire, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b001110)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b01110;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// xori
			$display("%h\tXORI\tR%d, R%d, %d", pc, rt_wire, rs_wire, $signed(imm_wire));
		end
		else if (inst_wire[5:0] == 'b001111)
		begin
			src1 = 0;
			src2 = 0;
			dst = rt_wire;
			funct = 'b10010;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b000; // Data memory is not used
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem,
			j = 0;
			// lui
			$display("%h\tLUI\tR%d, %d", pc, rt_wire, $signed(imm_wire));
		end
		
		else if (inst_wire[5:0] == 'b100000)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b01000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b101; // byte mode, read mode, enable memory
			wb_func = 3'b101; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem, Bit 2 = trigger sign extend / !no sign extend
			j = 0;
			// lb
			
			$display("%h\tLB\tR%d, %d(R%d)", pc, rt_wire, $signed(imm_wire), rs_wire);
		end
		else if (inst_wire[5:0] == 'b100011)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b01000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b001; // word mode, read mode, enable memory
			wb_func = 3'b001; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem, Bit 2 = trigger sign extend / !no sign extend
			j = 0;
			// lw
			$display("%h\tLW\tR%d, %d(R%d)", pc, rt_wire, $signed(imm_wire), rs_wire);
		end
		else if (inst_wire[5:0] == 'b100100)
		begin
			src1 = rs_wire;
			src2 = 0;
			dst = rt_wire;
			funct = 'b01000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b101; // byte mode, read mode, enable memory
			wb_func = 3'b001; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem, Bit 2 = trigger sign extend / !no sign extend
			j = 0;
			// lbu
			$display("%h\tLBU\tR%d, %d(R%d)", pc, rt_wire, $signed(imm_wire), rs_wire);
		end
		else if (inst_wire[5:0] == 'b101000)
		begin
			src1 = rs_wire;
			src2 = rt_wire;
			dst = 0;
			funct = 'b01000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b111; // byte mode, write mode, enable memory
			wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem, Bit 2 = trigger sign extend / !no sign extend
			j = 0;
			// sb
			$display("%h\tSB\tR%d, %d(R%d)", pc, rt_wire, $signed(imm_wire), rs_wire);
		end
		else if (inst_wire[5:0] == 'b101001)
		begin
			src1 = rs_wire;
			src2 = rt_wire;
			dst = 0;
			funct = 'b01000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b011; // byte mode, write mode, enable memory
			wb_func = 3'b100; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem, Bit 2 = trigger sign extend / !no sign extend, Bit3: force halfword memory write/read
			j = 0;
			// sh
			$display("%h\tSH\tR%d, %d(R%d)", pc, rt_wire, $signed(imm_wire), rs_wire);
		end
		else if (inst_wire[5:0] == 'b101011)
		begin
			src1 = rs_wire;
			src2 = rt_wire;
			dst = 0;
			funct = 'b01000;
			imm = imm_wire;
			addr = 0;
			b_ctrl = 1; // ALU op2 drawn from SX unit
			dmem_func = 3'b011; // byte mode, write mode, enable memory
			wb_func = 3'b000; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem, Bit 2 = trigger sign extend / !no sign extend
			j = 0;
			// sw			
			$display("%h\tSW\tR%d, %d(R%d)", pc, rt_wire, $signed(imm_wire), rs_wire);
		end
		else if (inst_wire[5:0] == 'b011100)
		begin
			src1 = rs_wire;
			src2 = rt_wire;
			dst = rd_wire;
			funct = 'b00101; // Use the MULT command for now
			imm = 0;
			addr = 0;
			b_ctrl = 0;
			wb_func = 3'b011; // Bit 0 = enable writeback / !disable writeback, Bit 1 = writeback from ALU / !writeback from mem, Bit 2 = trigger sign extend / !no sign extend
			j = 0;
			// mul
			$display("%h\tMUL\tR%d, R%d, R%d)", pc, rd_wire, rs_wire, rt_wire);
		end
		
		else
		begin
			$display("%h\tUNDEF %b", pc, insn);			
		end
	end

endmodule