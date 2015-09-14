module alu (a_input, b_input, funct, res, z);

// input
	input  [31:0] a_input;
	input  [31:0] b_input;
	input  [4:0]  funct;

// output
	output [31:0] res;
	output        z;

// reg
	reg    [31:0] res = 0;
	reg			  z = 0;
	reg	   [31:0] hi = 0;
	reg    [31:0] lo = 0;

// combinational logic but easier to understand format
	always @(a_input or b_input or funct)
	begin
        if (funct == 'b00000)
        begin
            // sll 
			res = a_input << b_input;
			z = 0;
			$display("%d = %d << %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00001)
        begin
            // srl
            res = a_input >> b_input;
			z = 0;
			$display("%d = %d >> %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00010)
        begin
           // sra
           res = $signed(a_input) >>> $signed(b_input);
		   z = 0;
		   $display("%d = %d >>> %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00011)
        begin
            // mfhi
           res = hi;
		   z = 0;
		   $display("HI = %d", res);
        end
        else if (funct == 'b00100)
        begin
            // mflo
			res = lo;
			z = 0;
			$display("LO = %d", res);
        end
        else if (funct == 'b00101)
        begin
			// mul
            res = ($signed(a_input) * $signed(b_input));
			z = 0;
			$display("%d = %d * %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b00110)
        begin
            // div
			lo = ($signed(a_input) / $signed(b_input));
			hi = ($signed(a_input) % $signed(b_input));
			$display("%d = %d / %d", $signed(lo), $signed(a_input), $signed(b_input));
            z = 0;
        end
        else if (funct == 'b00111)
        begin
            // divu
			hi = ($unsigned(a_input) / $unsigned(b_input));
			lo = ($unsigned(a_input) % $unsigned(b_input));
            z = 0;
        end
        else if (funct == 'b01000)
        begin
            // add rd, rs, rt
            res = $signed(a_input) + $signed(b_input);
			z = 0;
			$display("%d = %d + %d", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b01001)
        begin
            // addu rd, rs, rt
            res = a_input + b_input;
			z = 0;
			$display("%d = u%d + u%d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01010)
        begin
            // sub rd, rs, rt
            res = $signed(a_input) - $signed(b_input);
			z = 0;
			$display("%d = %d - %d", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b01011)
        begin
            // subu rd, rs, rt
            res = a_input - b_input;
			z = 0;
			$display("%d = u%d - u%d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01100)
        begin
            // and rd, rs, rt
            res = a_input & b_input;
			z = 0;
			$display("%d = %d & %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01101)
        begin
            // or rd, rs, rt
            res = a_input | b_input;
			z = 0;
			$display("%d = %d | %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01110)
        begin
            // xor rd, rs, rt
            res = a_input ^ b_input;
			z = 0;
			$display("%d = %d ^ %d", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b01111)
        begin
            // nor rd, rs, rt
            res = ~(a_input | b_input);
			z = 0;
			$display("%d = ~(%d | %d)", $signed(res), $signed(a_input), $signed(b_input));
        end
        else if (funct == 'b10000)
        begin
            // slt rd, rs, rt
            res = $signed(a_input) < $signed(b_input) ? 1 : 0;
			z = 0;
			$display("%d = (%d < %d)", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10001)
        begin
            // sltu rd, rs, rt
            res = a_input < b_input ? 1 : 0;
			z = 0;
			$display("%d = u%d < u%d", $signed(res), $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10010)
        begin
            // lui
            res = b_input << 16;
			z = 0;
			$display("%d = %d << 16", $signed(res), $signed(b_input));
        end
		else if (funct == 'b10011)
        begin
            // beq rd, rs, rt
            z = a_input == b_input ? 1 : 0;
			res = 0;
			$display("%d = %d == %d", z, $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10100)
        begin
            // blt rd, rs, rt
            z = $signed(a_input) < $signed(b_input) ? 1 : 0;
			res = 0;
			$display("%d = %d < %d", z, $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10101)
        begin
            // bne rd, rs, rt
            z = a_input != b_input ? 1 : 0;
			res = 0;
			$display("%d = %d != %d", z, $signed(a_input), $signed(b_input));
        end
		else if (funct == 'b10110)
        begin
            // bleq rd, rs, rt
            z = $signed(a_input) <= $signed(b_input) ? 1 : 0;
			res = 0;
			$display("%d = %d <= %d", z, $signed(a_input), $signed(b_input));
        end
	end
endmodule