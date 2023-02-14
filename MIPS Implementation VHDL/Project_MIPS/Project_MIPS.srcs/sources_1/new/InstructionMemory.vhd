library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
  Port ( 
        clk_i:      IN std_logic;
        address_i:  IN std_logic_vector(31 downto 0) := x"00000000";
        instr_o:    OUT std_logic_vector(31 downto 0) := (others => '0') -- NOP instructie, bij opstart uitvoeren tot je instructie krijgt -> zie reference card
  );
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    -- Declaratie geheugen: 32bits memory word
    subtype memword_t is std_logic_vector(31 downto 0); -- 1 instructie
    type mem_t is array(0 to 4096) of memword_t; -- Array van 128 lang van type memword_t dat op zijn eurt telkens 32bits lang is -> eigenlijk 2D array
    
    -- Instructie geheugen (ook nog aanmaken na declaratie)
    signal instr_mem : mem_t := (

	-- Simulating R-type instructions:
	
	-- 0x00000000
	"00000000000000000000000000000000", -- NOP
	
	-- 0x00000004
	-- R: add: opcode:000000, rs:00010(02), rt:00011(03), rd: 01000(08), shamt:00000, funct:100000(add) -> 3 + 5 = 8
	"00000000010000110100000000100000",
	
	-- 0x00000008 
	-- R: sub: opcode:000000, rs:01000(08), rt:00010(02), rd: 01001(09), shamt:00000, funct:100010(sub) -> 8 - 3 = 5
	"00000001000000100100100000100010",
	
	-- 0x0000000C
	-- R: slt: opcode:000000, rs:01001(09), rt:01000(08), rd: 01010(10), shamt:00000, funct:101010(sub) -> 5 < 8?
	"00000001001010000101000000101010",
	
	-- 0x00000010
	-- R: and: opcode:000000, rs:00010(02), rt:00011(03), rd: 01011(11), shamt:00000, funct:100100(and) -> 0011 & 0101 = 0001
	"00000000010000110101100000100100",
	
	-- 0x00000014
	-- R: nor: opcode:000000, rs:00010(02), rt:00011(03), rd: 01100(12), shamt:00000, funct:100111(nor) -> 0011 nor 0101 = 1000
	"00000000010000110110000000100111",
	
	-- 0x00000018       
	-- R: or: opcode:000000, rs:00010(02), rt:00011(03), rd: 01101(13), shamt:00000, funct:100101(or) -> 0011 or 0101 = 0111
	"00000000010000110110100000100101",
	
	-- 0x0000001C
	-- R: sll: opcode:000000, (rs:00000(00)), rt:01101(13), rd: 01110(14), shamt:00101(5), funct:000000(sll) -> rd = rt << shamt(5)
	"00000000000011010111000101000000",
	
	-- 0x00000020
	-- R: srl: opcode:000000, (rs:00000(00)), rt:01110(14), rd: 01111(15), shamt:00101(5), funct:000010(srl) -> rd = rt >> shamt(5)
	"00000000000011100111100101000010",
	
	-- 0x00000024
	-- R: jr: opcode:000000, rs:00101(05), rt:00000(00), rd: 00000(00), shamt:00000(0), funct:001000(jr) -> PC = rs(=10) -> jumps to starting I instructions (0x00000028=rs)
	"00000000101000000000000000001000",
	
	-- Simulating I-type instructions:
	
	-- 0x00000028
	-- I: addi: opcode:001000, rs:00010(02), rt:10000(16), immediate:0000000000000101(05) -> 3(rs) + 5(imm) = 8(16)
	"00100000010100000000000000000101",
	
	-- 0x0000002C
	-- I: andi: opcode:101100, rs:00010(02), rt:10001(17), immediate:0000000000000101(05) -> 0011 & 0101 = 0001(17)
	"10110000010100010000000000000101",
	
	-- 0x00000030
	-- I: lbu: opcode:100100, rs:00001(01), rt:10010(18), immediate:0000000000000011(03) -> M[1(rs)+3(SignExtImm)] = M[4](7:0) => rt(18)
	"10010000001100100000000000000011",
	
	-- 0x00000034
	-- I: lhu:  opcode:100101, rs:00001(01), rt:10011(19), immediate:0000000000000011(03) -> M[1(rs)+3(SignExtImm)] = M[4](15:0) => rt(19)
	"10010100001100110000000000000011",
	
	-- 0x00000038
	-- I: lui: opcode:001111, (rs:00000(00)), rt:10100(20), immediate:1111111111111111 -> rt = 11111111111111110000000000000000
	"00111100000101001111111111111111",
	
	-- 0x0000003C
	-- I: lw: opcode:100011, rs:00001(01), rt:10101(21), immediate:0000000000000010(02) -> M[1(rs)+2(imm)] = M[3] = 5 => rt(21) 
	"10001100001101010000000000000010",
	
	-- 0x00000040
	-- I: ori: opcode:001101, rs:00010(02), rt:10110(22), immediate:0000000000000101(05) -> 0011 or 0101 = 0111 
	"00110100010101100000000000000101",
	
	-- 0x00000044
	-- I: slti: opcode:001010, rs:01001(09), rt:10111(23), immediate:0000000000001000(08) -> 5 < 8? 
	"00101001001101110000000000001000",
	
	-- 0x00000048
	-- I: sb: opcode:101000, rs:00001(01), rt:00100(4), immediate:0000000000000100(04) -> M[1(rs)+ 4(SignExtImm)] = M[5](7:0) => rt(4)
	"10100000001001000000000000000100",

    -- 0x0000004C
	-- I: sh: opcode:101001, rs:00001(01), rt:00100(4), immediate:0000000000000110(06) -> M[1(rs)+ 6(SignExtImm)] = M[7](15:0) => rt(4)
	"10100100001001000000000000000110",
	
	-- 0x00000050
	-- I: sw: opcode:101011, rs:00001(01), rt:00100(4), immediate:0000000000000111(07) ->  M[1(rs) + 7(SignExtImm)] = M[8] => rt(16)
	"10101100001001000000000000000111",
	
	-- 0x00000054
	-- I: beq: opcode:000100, rs:00001(1), rt:00010(2), immediate:0000000000000001(1) -> if(rs=rt) -> PC = PC+4+imm, => if = false, skip
	"00010000001000100000000000000001",
	
	-- 0x00000058
	-- I: beq: opcode:000100, rs:00001(1), rt:00110(6), immediate:0000000000000000(1) -> if(rs=rt) -> PC = PC+4+imm, => if = true, jump to instr 0x00000060 (offset of 1 to current(=> imm = 0) -> no offset given because PC is already incremented)
	"00010000001001100000000000000000",
	
	-- 0x0000005C
	-- I: bne: opcode:000101, rs:00001(1), rt:00110(6), immediate:0000000000000001(1) -> if(rs!=rt) -> PC = PC+4+imm, => if = true, skip
	"00010100001001100000000000000001",
	
	-- 0x00000060
	-- I: bne: opcode:000101, rs:00001(1), rt:00010(1), immediate:0000000000000001(1) -> if(rs!=rt) -> PC = PC+4+imm, => if = false, jump to instr 0x00000074
	"00010100001000100000000000000000",
	
	
	-- 0x00000064
	-- R: mul: opcode:000000, rs:00100(4), rt:00010(2), (rd: 00000(0)), shamt:00000, funct:011000(mul) -> 0xFFFF FFFF * 0x0000 0003 = 0x0000 0002 FFFF FFFD
	"00000000100000100000000000011000",
	
	-- 0x00000068
	-- R: mfhi: opcode:000000, (rs:00000(0)), (rt:00000(0)), rd: 11000(24), shamt:00000, funct:010000(mfhi) -> 0x2 FFFF FFFD -> hi = 0x0000 0002
	"00000000000000001100000000010000", 
	
	-- 0x0000006C 
	-- R: mflo: opcode:000000, (rs:00000(0)), (rt:00000(0)), rd: 11001(25), shamt:00000, funct:010010(mflo) -> 0x2 FFFF FFFD -> lo = 0xFFFF FFFD
	"00000000000000001100100000010010",
	
	-- 0x00000070
	-- R: div: opcode:000000, rs:00011(3), rt:00010(2), (rd: 00000(0)), shamt:00000, funct:011010(div) -> hi = 5/3 = 1, lo = 5 mod 3 = 2
	"00000000011000100000000000011010", 
	
	-- 0x00000074
	-- R: mfhi: opcode:000000, (rs:00000(0)), (rt:00000(0)), rd: 11010(26), shamt:00000, funct:010000(mfhi) -> hi = 1
	"00000000000000001101000000010000",  
	
	-- 0x00000078
	-- R: mflo: opcode:000000, (rs:00000(0)), (rt:00000(0)), rd: 11011(27), shamt:00000, funct:010010(mflo) -> lo = 2
	"00000000000000001101100000010010",
	
	-- 0x0000007C
	-- J: j: opcode:000010, address:00000000000000000000100000-> jump to UART instructions(0x0000 0080)
	"00001000000000000000000000100000",
	
	-- UART Instructions: -> see UART file
	
	-- 0x00000080
    -- UART Write: UART Address = 0x00004000 (0100000000000000)
	-- I: sb: opcode:101000, rs:11101(29), rt:10011(19), immediate:0100000000000000 -> UART(M[rs+imm] = 0x00004000) = rt(7:0)
	--"10100011101100110100000000000000",
	
	-- 0x00000084
	-- UART Read: UART Address = 0x00004000 (0100000000000000)
	-- I: lbu: opcode:100100, rs:11101(29), rt:11110(30), immediate:0100000000000000 -> rt(7:0) = UART(M[rs+imm] = 0x00004000
	--"10010011101111100100000000000000",
	--"00000000000000000000000000000000", -- NOP 
	
	-- JAL also supported -> see ProcedureCall file
    -- J: jal: opcode:000011, address:00000000000000000000000110 -> jal label
    --"00001100000000000000000000000110",    
        others => (others => '0')
    );
begin
    instr_o <= x"00000000" when address_i = x"00000000" else
                instr_mem(to_integer(unsigned(address_i)) / 4);
end Behavioral;

