library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_tb is
end Control_tb;

architecture Behavioral of Control_tb is
    component Control is 
    Port ( 
        clk_i:          IN std_logic ;
        instr_Ctrl_i:   IN std_logic_vector(31 downto 0);
        RegDst_o:       OUT std_logic := '0';
        Jump_o:         OUT std_logic := '0';
        JumpReg_o:      OUT std_logic := '0';
        Branch_o:       OUT std_logic := '0';
        MemRead_o:      OUT std_logic := '0';
        MemToReg_o:     OUT std_logic := '0';
        ALUOp_o:        OUT std_logic_vector(1 downto 0) := (others => '0');
        MemWrite_o:     OUT std_logic := '0';
        ALUSrc_o:       OUT std_logic := '0';
        RegWrite_o:     OUT std_logic := '0'
     );
    end component;

    -- Input Signals 
    signal clk_S:         std_logic := '0';
    signal instr_s:       std_logic_vector (31 downto 0) := (others => '0');
    -- Output Signals 
    signal RegDst_s:      std_logic := '0';
    signal Jump_s:        std_logic := '0';
    signal JumpReg_s:     std_logic := '0';
    signal Branch_s:      std_logic := '0';
    signal MemRead_s:     std_logic := '0';
    signal MemToReg_s:    std_logic := '0';
    signal ALUOp_s:       std_logic_vector (1 downto 0) := (others => '0');
    signal MemWrite_s:    std_logic := '0';
    signal ALUSrc_s:      std_logic := '0';
    signal RegWrite_s:    std_logic := '0';
    -- Fake Connections
    --Clock divider constant
    constant clkPeriod_s : time := 10 ns;

begin
    UUT:Control 
    port map(
        clk_i         => clk_S,
        instr_Ctrl_i       => instr_s,
        RegDst_o      => RegDst_s,
        Jump_o        => Jump_s,
        JumpReg_o     => JumpReg_s,
        Branch_o      => Branch_s,
        MemRead_o     => MemRead_s,
        MemToReg_o    => MemToReg_s,
        ALUOp_o       => ALUOp_s,
        MemWrite_o    => MemWrite_s,
        ALUSrc_o      => ALUSrc_s,
        RegWrite_o    => RegWrite_s 
    );
    
    clk_process:process
    begin
        clk_S <= '0';
        wait for clkPeriod_s/2;
        clk_S <= '1';
        wait for clkPeriod_s/2;
    end process;
    
    stim_proc:process
    begin
        wait for 5ns;
        -- R-type: add
        instr_s   <= "00000000001000100010000000100000"; -- op(000000)-rs(00001)-rt(00010)-rd(00100)-shamt(00000)-funct(100000)
        wait for 10ns;
        -- R-type: jr
        instr_s   <= "00000000001000000000000000001000"; -- op(000000)-rs(00001)-rt(00000)-rd(00000)-shamt(00000)-funct(001000)
        wait for 10ns;
        -- I-type: lw
        instr_s   <= "10001100001000100000000000000001"; -- op(100011)-rs(00001)-rt(00010)-addr/imm(0000000000000001)
        wait for 10ns;
        -- I-type: sw
        instr_s   <= "10101100001000100000000000000001"; -- op(101011)-rs(00001)-rt(00010)-addr/imm(0000000000000001)
        wait for 10ns;
        -- I-type: beq
        instr_s   <= "00010000001000100000000000000001"; -- op(000100)-rs(00001)-rt(00010)-addr/imm(0000000000000001)
        wait for 10ns;
        -- J-type: Jump_s
        instr_s   <= "00001000000000000000000000000001"; -- op(000010)-addr(00000000000000000000000001)
        wait for 10ns;   
        -- Others
        instr_s   <= "11111100000000000000000000000000"; -- op(111111)
        wait for 10ns;              
        wait;
    end process;
    

end Behavioral;
