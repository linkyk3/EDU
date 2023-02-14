library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Main_Top_tb is
end Main_Top_tb;

architecture Behavioral of Main_Top_tb is
    
    component Main_Top is
        Port (
            -- Input
            clk_i:              IN std_logic;
            instr_Main_i:       IN std_logic_vector(31 downto 0);
            -- Output
            JumpReg_o:          OUT std_logic := '0';
            Jump_o:             OUT std_logic := '0';
            Branch_o:           OUT std_logic := '0';
            Zero_o:             OUT std_logic := '0';
            readData1_Main_o:   OUT std_logic_vector(31 downto 0) := (others => '0');
            instr_SE_Main_o:    OUT std_logic_vector(31 downto 0) := (others => '0')    
        );
    end component;
    
    -- Input Signals
    signal clk_s:               std_logic := '0';
    signal instr_s:             std_logic_vector(31 downto 0) := (others => '0');
    -- Output Signals
    signal JumpReg_s:           std_logic := '0';
    signal Jump_s:              std_logic := '0';
    signal Branch_s:            std_logic := '0';
    signal Zero_s:              std_logic := '0';
    signal readData1_s:         std_logic_vector(31 downto 0) := (others => '0');
    signal instr_SE_s:          std_logic_vector(31 downto 0) := (others => '0');
    
    -- Clock divider constant
    constant clkPeriod_s : time := 10 ns;

begin
    UUT:Main_Top
    port map(
        clk_i               => clk_s,
        instr_Main_i        => instr_s,
        JumpReg_o           => JumpReg_s,
        Jump_o              => Jump_s,
        Branch_o            => Branch_s,
        Zero_o              => Zero_s,
        readData1_Main_o    => readData1_s,
        instr_SE_Main_o     => instr_SE_s
    );
    
    clk_s_process:process
    begin
        clk_s <= '0';
        wait for clkPeriod_s/2;
        clk_s <= '1';
        wait for clkPeriod_s/2;
    end process;
    
    stim_proc:process
    begin
        wait for 5ns;
        -- Simulating R-type instructions:
        
        -- R: add: opcode:000000, rs:00010(02), rt:00011(03), rd: 01000(08), shamt:00000, funct:100000(add) -> 3 + 5 = 8
        -- Reg[2] = 1 and Reg[3] = 2 -> hard coded
        instr_s     <= "00000000010000110100000000100000";
        wait for 50ns; -- 5 clock cycles
        -- R: sub: opcode:000000, rs:01000(08), rt:00010(02), rd: 01001(09), shamt:00000, funct:100010(sub) -> 8 - 3 = 5
        instr_s     <= "00000001000000100100100000100010";
        wait for 50ns;        
        -- R: slt: opcode:000000, rs:01001(09), rt:01000(08), rd: 01010(10), shamt:00000, funct:101010(sub) -> 5 < 8?
        instr_s     <= "00000001001010000101000000101010";
        wait for 50ns; 
        -- R: and: opcode:000000, rs:00010(02), rt:00011(03), rd: 01011(11), shamt:00000, funct:100100(and) -> 0011 & 0101 = 0001
        instr_s     <= "00000000010000110101100000100100";
        wait for 50ns;        
        -- R: nor: opcode:000000, rs:00010(02), rt:00011(03), rd: 01100(12), shamt:00000, funct:100111(nor) -> 0011 nor 0101 = 1000
        instr_s     <= "00000000010000110110000000100111";       
        wait for 50ns;        
        -- R: or: opcode:000000, rs:00010(02), rt:00011(03), rd: 01101(13), shamt:00000, funct:100101(or) -> 0011 or 0101 = 0111
        instr_s     <= "00000000010000110110100000100101";
        wait for 50ns;
        -- R: sll: opcode:000000, (rs:00000(00)), rt:01101(13), rd: 01110(14), shamt:00101(5), funct:000000(sll) -> rd = rt << shamt(5)
        instr_s     <= "00000000000011010111000101000000";
        wait for 50ns;
        -- R: srl: opcode:000000, (rs:00000(00)), rt:01110(14), rd: 01111(15), shamt:00101(5), funct:000010(srl) -> rd = rt >> shamt(5)
        instr_s     <= "00000000000011100111100101000010";
        wait for 50ns;
        
        -- Simulating I-type instructions:
        
        -- I: addi: opcode:001000, rs:00010(02), rt:10000(16), immediate:0000000000000101(05) -> 3(rs) + 5(imm) = 8(16)
        instr_s     <= "00100000010100000000000000000101";
        wait for 50ns;
        -- I: addiu
        -- I: andi: opcode:101100, rs:00010(02), rt:10001(17), immediate:0000000000000101(05) -> 0011 & 0101 = 0001(17)
        instr_s     <= "10110000010100010000000000000101";
        wait for 50ns;
        -- I: lbu: opcode:100100, rs:00001(01), rt:10010(18), immediate:0000000000000011(02) -> M[1(rs)+3(SignExtImm] = M[4](7:0) => rt(18)
        instr_s     <= "10010000001100100000000000000011";
        wait for 50ns;
        -- I: lhu:  opcode:100101, rs:00001(01), rt:10011(19), immediate:0000000000000011(02) -> M[1(rs)+3(SignExtImm)] = M[4](15:0) => rt(19)
        instr_s     <= "10010100001100110000000000000011";
        wait for 50ns;
        -- I: lui: opcode:001111, rs:00001(01), rt:10100(20), immediate:0000000000000011(02) -> M[1(rs)+3(SignExtImm)] = M[4](15:0) => rt(19)
        --instr_s     <= "00111100001100110000000000000011";
        --wait for 50ns;
        -- I: lw: opcode:100011, rs:00001(01), rt:10101(21), immediate:0000000000000010(02) -> M[1(rs)+2(imm)] = M[3] = 5 => rt(21) 
        instr_s     <= "10001100001101010000000000000010";
        wait for 50ns;
        -- I: ori: opcode:001101, rs:00010(02), rt:10110(22), immediate:0000000000000101(05) -> 0011 or 0101 = 0111 
        instr_s     <= "00110100010101100000000000000101";
        wait for 50ns;
        -- I: slti: opcode:001010, rs:01001(09), rt:10111(23), immediate:0000000000001000(08) -> 5 < 8? 
        instr_s     <= "00101001001101110000000000001000";
        wait for 50ns;
        -- I: sltiu
        -- I: sb: opcode:101000, rs:00001(01), rt:00100(4), immediate:0000000000000100(04) -> M[1(rs)+ 4(SignExtImm)] = M[5](7:0) <= rt(4)
        instr_s     <= "10100000001001000000000000000100";
        wait for 50ns;
        -- I: sc:
        -- I: sh: opcode:101001, rs:00001(01), rt:00100(4), immediate:0000000000000110(06) -> M[1(rs)+ 6(SignExtImm)] = M[7](15:0) <= rt(4)
        instr_s     <= "10100100001001000000000000000110";
        wait for 50ns;
        -- I: sw: opcode:101011, rs:00001(01), rt:00100(4), immediate:0000000000000111(07) ->  M[1(rs) + 7(SignExtImm)] = M[8] <= rt(16)
        instr_s     <= "10101100001001000000000000000111";
        wait for 50ns;
        wait;
    end process;

end Behavioral;
