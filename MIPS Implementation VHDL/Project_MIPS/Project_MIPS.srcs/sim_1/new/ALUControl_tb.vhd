library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUControl_tb is
end ALUControl_tb;

architecture Behavioral of ALUControl_tb is
    component ALUControl is
        Port (
            clk_ALUC_i:     IN std_logic;
            ALUOp_i:        IN std_logic_vector(1 downto 0);
            instr_ALUC_i:   IN std_logic_vector(5 downto 0); -- funct field
            ALUControl_o:   OUT std_logic_vector(2 downto 0) := (others => '0')
  
        );
    end component;
    
    -- Input Signals
    signal clk_s:         std_logic := '0';
    signal instr_s:       std_logic_vector(5 downto 0) := (others => '0') ;
    -- Control Signals
    signal ALUOp_s:       std_logic_vector(1 downto 0) := (others => '0') ;
    -- Output Signals
    signal ALUControl_s:  std_logic_vector(2 downto 0) := (others => '0') ;
    --Clock divider constant
    constant clkPeriod_s : time := 10 ns;
    
begin
    UUT:ALUControl
    port map(
        clk_ALUC_i      => clk_s,
        ALUOp_i         => ALUOp_s,
        instr_ALUC_i    => instr_s,
        ALUControl_o    => ALUControl_s
    );
    
    clk_process:process
    begin
        clk_s <= '0';
        wait for clkPeriod_s/2;
        clk_s <= '1';
        wait for clkPeriod_s/2;
    end process;
    
    stim_proc:process
    begin
        wait for 5ns;
            ALUOp_s <= "00"; -- LW/SW
            wait for 10ns;
            ALUOp_s <= "01"; -- Branch equal
            wait for 10ns;
            ALUOp_s <= "10"; -- R-type
            instr_s <= "100000";
            wait for 10ns;   
            instr_s <= "100010";
            wait for 10ns; 
            instr_s <= "100100";
            wait for 10ns; 
            instr_s <= "100101";
            wait for 10ns;
            instr_s <= "101010";
            wait for 10ns;  
            ALUOp_s <= "11"; -- error 
        wait;
    end process;
    
end Behavioral;
