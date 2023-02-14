library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity SignExtend_tb is
end SignExtend_tb;

architecture Behavioral of SignExtend_tb is
    component SignExtend is
        Port (
            clk_i:              IN std_logic;
            instr_SE_i:         IN std_logic_vector(15 downto 0);
            output_SE_o:        OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    signal clk_s:     std_logic;
    signal input_s:   std_logic_vector(15 downto 0);
    signal output_s:  std_logic_vector(31 downto 0);
    
    constant clkPeriod_s : time := 10 ns;
    
begin
    UUT:SignExtend
    port map(
        clk_i       => clk_s,
        instr_SE_i  => input_s,
        output_SE_o => output_s
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
        input_s <= "1000000000000000";
        wait for 10ns;
        input_s <= "0111111111111111";
        wait;
    end process;

end Behavioral;
