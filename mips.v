//=======================================================
//  Top Level Module
//=======================================================

module mips(CK, RESET, DONE, OUTADDR, OUTDATA, OUTVALID);

//Required For Testing	
	
	input CK;
	input RESET;
	output DONE;
	output [4:0] OUTADDR;
	output [31:0] OUTDATA;
	output OUTVALID;

	reg [31:0] OUTDATA;
	reg DONE;
	reg [4:0] OUTADDR;
	reg OUTVALID;
	
//Required For Operation

	reg [31:0] ROM [31:0];
	reg [31:0] regarray [31:0];
	reg [31:0] dmem [31:0];
	reg [31:0] pc, pctemp, instruction, pcinc, j_address, simm32, simm32sl2, b_result, readdata1, readdata2, aluout, b_address, nextpc, tempaddress, dataout, writedata;
	reg [27:0] j_shift;
	reg [25:0] j_tempaddress;
	reg [15:0] simm16;
	reg [5:0] opcode, funct;
	reg [4:0] pcread, rd, rt, rs, address, writereg;
	reg [1:0] aluop, alucontrol;
	reg outvalidtemp, regdst, jump, branch, memread, memtoreg, memwrite, alusrc, regwrite, aluzero;

//Initial Statement	
	
	initial
	begin
		ROM[0]<=32'b00100100000010110000000000000100;
		ROM[1]<=32'b00100100000010010000000000000001;
		ROM[2]<=32'b00100100000010000000000000000000;
		ROM[3]<=32'b00100100000010100000000000000000;
		ROM[4]<=32'b00100100000011000010000000000000;
		ROM[5]<=32'b10101101100010100000000000000000;
		ROM[6]<=32'b00000001010010010101000000100001;
		ROM[7]<=32'b00100101100011000000000000000100;
		ROM[8]<=32'b00101101010000010000000000010000;
		ROM[9]<=32'b00010100001000001111111111111011;
		ROM[10]<=32'b00100101100011000000000000001000;
		ROM[11]<=32'b00000001010010010101000000100011;
		ROM[12]<=32'b10101101100010101111111111111000;
		ROM[13]<=32'b00000001100010110110000000100001;
		ROM[14]<=32'b00010001010000000000000000000001;
		ROM[15]<=32'b00001000000000000000000000001011;
		ROM[16]<=32'b00100100000011000001111111111000;
		ROM[17]<=32'b00100100000010110000000000100000;
		ROM[18]<=32'b10001101100011010000000000001000;
		ROM[19]<=32'b00100101101011011000000000000000;
		ROM[20]<=32'b10101101100011010000000000001000;
		ROM[21]<=32'b00000001010010010101000000100001;
		ROM[22]<=32'b00100101100011000000000000000100;
		ROM[23]<=32'b00000001010010110000100000101011;
		ROM[24]<=32'b00010100001000001111111111111001;
		ROM[25]<=32'b00100100010000100000000000001010;
		ROM[26]<=32'b00000000000000000000000000001100;
	end

//Always Statement	
	
	always @ (posedge CK)
	begin
		if (RESET == 1'b1)
		begin
			pc <= 32'd0;
		end
		else
		begin
		
			//Reading PC
			pctemp = pc >> 2;
			pcread = pctemp[4:0];
			instruction = ROM[pcread];	
				
			//Acquiring Incremented PC Address
			pcinc = pc + 32'h4;

			//Parsing Instructions
			opcode = instruction[31:26];
			funct = instruction[5:0];
			rd = instruction[15:11];
			rt = instruction[20:16];
			rs = instruction[25:21];
			j_tempaddress = instruction[25:0];
			j_shift = {j_tempaddress,2'b00};
			j_address = {pcinc[31:28],j_shift};
			simm16 = instruction[15:0];
			simm32 = {{16{simm16[15]}},simm16};
			simm32sl2 = simm32 << 2;
			b_result = pcinc + simm32sl2;
				
			//Control Unit
			outvalidtemp = 1'b0;
			case(opcode)
			6'h0: //R-Type
			begin
				case(funct)
				6'h21: //addu
				begin
					regdst = 1'b1;
					jump = 1'b0;
					branch = 1'b0;
					memread = 1'b0;
					memtoreg = 1'b0;
					aluop = 2'b10;
					memwrite = 1'b0;
					alusrc = 1'b0;
					regwrite = 1'b1;
				end
				6'h2b: //sltu
				begin
					regdst = 1'b1;
					jump = 1'b0;
					branch = 1'b0;
					memread = 1'b0;
					memtoreg = 1'b0;
					aluop = 2'b10;
					memwrite = 1'b0;
					alusrc = 1'b0;
					regwrite = 1'b1;
				end
				6'h23: //subu
				begin
					regdst = 1'b1;
					jump = 1'b0;
					branch = 1'b0;
					memread = 1'b0;
					memtoreg = 1'b0;
					aluop = 2'b10;
					memwrite = 1'b0;
					alusrc = 1'b0;
					regwrite = 1'b1;
				end
				6'hc: //syscall
				begin
					regdst = 1'b1;
					jump = 1'b0;
					branch = 1'b0;
					memread = 1'b0;
					memtoreg = 1'b0;
					aluop = 2'b10;
					memwrite = 1'b0;
					alusrc = 1'b0;
					regwrite = 1'b0;
				end
				endcase
			end
			6'h9: //addiu
			begin
				regdst = 1'b0;
				jump = 1'b0;
				branch = 1'b0;
				memread = 1'b0;
				memtoreg = 1'b0;
				aluop = 2'b00;					
				memwrite = 1'b0;					
				alusrc = 1'b1;					
				regwrite = 1'b1;					
			end
			6'h4: //beq
			begin
				regdst = 1'b0;
				jump = 1'b0;
				branch = 1'b1;
				memread = 1'b0;
				memtoreg = 1'b0;
				aluop = 2'b01;
				memwrite = 1'b0;
				alusrc = 1'b0; //Even though I-type, comparison is between registers and not between reg and simm.
				regwrite = 1'b0;
			end
			6'h5: //bne
			begin
				regdst = 1'b0;
				jump = 1'b0;
				branch = 1'b1;
				memread = 1'b0;
				memtoreg = 1'b0;
				aluop = 2'b01;
				memwrite = 1'b0;
				alusrc = 1'b0; //Even though I-type, comparison is between registers and not between reg and simm.
				regwrite = 1'b0;
			end
			6'h23: //lw
			begin
				regdst = 1'b0;
				jump = 1'b0;
				branch = 1'b0;
				memread = 1'b1;
				memtoreg = 1'b1;
				aluop = 2'b00;
				memwrite = 1'b0;
				alusrc = 1'b1;
				regwrite = 1'b1;
			end
			6'hb: //sltiu
			begin
				regdst = 1'b0;
				jump = 1'b0;
				branch = 1'b0;
				memread = 1'b0;
				memtoreg = 1'b0;
				aluop = 2'b11;
				memwrite = 1'b0;
				alusrc = 1'b1;
				regwrite = 1'b1;
			end
			6'h2b: //sw
			begin
				regdst = 1'b0;
				jump = 1'b0;
				branch = 1'b0;
				memread = 1'b0;
				memtoreg = 1'b0;
				aluop = 2'b00;
				memwrite = 1'b1;
				alusrc = 1'b1;
				regwrite = 1'b0;
				outvalidtemp = 1'b1;
			end
			6'h2: //j
			begin
				regdst = 1'b0;
				jump = 1'b1;
				branch = 1'b0;
				memread = 1'b0;
				memtoreg = 1'b0;
				aluop = 2'b00;
				memwrite = 1'b0;
				alusrc = 1'b0;
				regwrite = 1'b0;
			end
			endcase
			OUTVALID <= outvalidtemp;
			
			//Register File - Reading
			regarray[0] = 32'h0;
			readdata1 = regarray[rs];
			readdata2 = regarray[rt];
			
			//ALU Control
			case(aluop)
			2'b00: //addiu,lw,sw,j
			begin
				alucontrol = 2'b00;
			end
			2'b01: //beq,bne
			begin
				alucontrol = 2'b01;
			end
			2'b10: //R-type
			begin
				case(funct)
				6'h21: //addu
				begin
					alucontrol = 2'b00;
				end
				6'h2b: //sltu
				begin
					alucontrol = 2'b10;
				end
				6'h23: //subu
				begin
					alucontrol = 2'b01;
				end
				6'hc: //syscall
				begin
					alucontrol = 2'b00;
				end
				endcase
			end
			2'b11: //sltiu
			begin
				alucontrol = 2'b10;
			end
			endcase
			
			//ALU
			case(alucontrol)
			2'b00: //addition
			begin
				if (alusrc == 1'b0)
				begin
					aluout = readdata1 + readdata2;
				end
				else
				begin
					aluout = readdata1 + simm32;
				end
			end
			2'b01: //subtraction
			begin
				if (alusrc == 1'b0)
				begin
					aluout = readdata1 - readdata2;
				end
				else
				begin
					aluout = readdata1 - simm32;
				end
			end
			2'b10: //borrow
			begin
				if (alusrc == 1'b0)
				begin
				aluout = (readdata1 < readdata2) ? 1 : 0;	
				end
				if (alusrc == 1'b1)
				begin
				aluout = (readdata1 < simm32) ? 1 : 0;
				end
			end
			endcase
			if (aluout == 32'd0)
			begin
				aluzero = 1'b1;
			end
			else
			begin
				aluzero = 1'b0;
			end
			
			//Branching
			if (opcode == 6'h4) //beq
			begin
				b_address = (branch == 1'b1 && aluzero == 1'b1) ? b_result : pcinc;
			end
			if (opcode == 6'h5) //bne
			begin
				b_address = (branch == 1'b1 && aluzero == 1'b0) ? b_result : pcinc;
			end
			
			//Selecting 'nextpc'
			if (opcode == 6'h0 && funct == 6'hc) //syscall
			begin
				nextpc = pc;
				DONE <= 1'b1;
			end
			else if (branch == 1'b1) //branch
			begin
				nextpc = b_address;
			end
			else if (jump == 1'b1) //jump
			begin
				nextpc = j_address;
			end
			else //inc
			begin
				nextpc = pcinc;
			end
			pc <= nextpc;
			
			//Data Memory
			tempaddress = (aluout >> 2);
			address = tempaddress[4:0];
			if (memwrite == 1'b1)
			begin
				dmem[address] <= readdata2;
				OUTDATA <= readdata2;
				OUTADDR <= address;
			end
			if (memread == 1'b1)
			begin
				dataout = dmem[address];
			end
			
			//Register File - Writing
			writereg = (regdst) ? rd : rt;
			writedata = (memtoreg) ? dataout : aluout;
			if (regwrite == 1'b1)
			begin
				regarray[writereg] <= writedata;
			end
			
		end
	end
endmodule