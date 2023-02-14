library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXRegisters_tb is
end MUXRegisters_tb;

architecture Behavioral of MUXRegisters_tb is
    component MUXRegisters is
        Port (
            clk_i:    IN std_logic;
            input1_i: IN std_logic_vector(4 downto 0);
            input2_i: IN std_logic_vector(4 downto 0);
            RegDst_i: IN std_logic;
            muxOutput_o: OUT std_logic_vector(4 downto 0) := (others => '0')
        );
    end component;
    
    --Input Signals
    signal clk_s:           std_logic;
    signal input1_s:        std_logic_vector(4 downto 0);
    signal input2_s:        std_logic_vector(4 downto 0);
    signal RegDst_s:        std_logic;
    --Output Signals
    signal muxOutput_s:     std_logic_vector(4 downto 0) := (others => '0');
    --Clock divider constant
    constant clkPeriod_c : time := 10 ns;
begin
    UUT:MUXRegisters
    port map(
        clk_i           => clk_s,
        input1_i        => input1_s,
        input2_i        => input2_s,
        RegDst_i        => RegDst_s,
        muxOutput_o     => muxOutput_s
    );
    
    clk_process:process
    begin
        clk_s <= '0';
        wait for clkPeriod_c/2;
        clk_s <= '1';
        wait for clkPeriod_c/2;
    end process;
    
    stim_proc:process
    begin
        input1_s  <= "10101";
        input2_s  <= "01010";
        wait for 5ns;
        RegDst_s <= '1';
        wait for 10ns;
        RegDst_s <= '0';
        wait for 10ns;
        RegDst_s <= 'U';
        wait;
    end process;
    
end Behavioral;
