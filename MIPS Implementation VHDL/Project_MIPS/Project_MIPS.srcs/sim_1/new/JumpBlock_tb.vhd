library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity JumpBlock_tb is
end JumpBlock_tb;

architecture Behavioral of JumpBlock_tb is
    
    component JumpBlock is
      Port ( 
        clk:            IN std_logic;
        instr:          IN std_logic_vector(31 downto 0);
        PC:             IN std_logic_vector(31 downto 0);
        jump_address:   OUT std_logic_vector(31 downto 0)
    );    
    end component;
    
    -- Input Signals
    signal clk:         std_logic := '0';
    signal instr:       std_logic_vector(31 downto 0) := (others => '0');
    signal PC:          std_logic_vector(31 downto 0) := (others => '0');
    -- Output Signals
    signal jump_address: std_logic_vector(31 downto 0) := (others => '0');
    --Clock divider constant
    constant clk_period : time := 10 ns;
    
begin
    UUT:JumpBlock
    port map(
        clk         => clk,
        instr       => instr,
        PC          => PC,
        jump_address => jump_address
    );
    
    clk_process:process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc:process
    begin
        wait for 5ns;
        instr   <= "00001010110001010001010001100010"; -- opcode = 000010 (0x02)
        PC      <= "01010110011101100111001010010100"; -- current PC    
        wait;
    end process;

end Behavioral;
