library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXEnd_tb is
end MUXEnd_tb;

architecture Behavioral of MUXEnd_tb is
    
    component MUXEnd is
        Port( 
            clk:            IN std_logic;
            ALU_result:     IN std_logic_vector(31 downto 0);
            jump_address:   IN std_logic_vector(31 downto 0);
            Jump:           IN std_logic;
            output:         OUT std_logic_vector(31 downto 0) := (others => '0')
        );        
    end component;
    
    -- Input Signals
    signal clk:         std_logic := '0';
    signal ALU_result:  std_logic_vector(31 downto 0) := (others => '0');
    signal jump_address: std_logic_vector(31 downto 0) := (others => '0');
    -- Control Signals
    signal Jump:        std_logic := '0';
    -- Output Signals
    signal output:      std_logic_vector(31 downto 0) := (others => '0');
    --Clock divider constant
    constant clk_period : time := 10 ns;

begin
    UUT: MuxEnd
    port map(
        clk             => clk,
        ALU_result      => ALU_result,
        jump_address    => jump_address,
        Jump            => Jump,
        output          => output
    );
    
    clk_prcoess:process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stim_proc:process
    begin
        wait for 5ns;
            Jump            <= '0';
            ALU_result      <= "00000000000000001111111111111111"; 
            jump_address    <= "11111111111111110000000000000000";
            wait for 10ns;
            Jump            <= '1';
        wait;
    end process;    


end Behavioral;
