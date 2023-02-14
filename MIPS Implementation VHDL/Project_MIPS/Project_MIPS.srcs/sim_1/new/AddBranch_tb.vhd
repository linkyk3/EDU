library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AddBranch_tb is
end AddBranch_tb;

architecture Behavioral of AddBranch_tb is

    component AddBranch is
        Port (
            clk_i:              IN std_logic;
            PC_i:               IN std_logic_vector(31 downto 0); 
            offsetSE_i:         IN std_logic_vector(31 downto 0); 
            addBranchResult_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
   );
    end component;

        signal clk_s:       std_logic;
        signal PC_s:        std_logic_vector(31 downto 0);
        signal offsetSE_s:  std_logic_vector(31 downto 0);
        signal output_s:    std_logic_vector(31 downto 0) := (others => '0');
        
        constant clkPeriod_s : time := 10 ns;
   
begin
   UUT: AddBranch
   port map (
        clk_i               => clk_s, 
        PC_i                => PC_s,
        offsetSE_i          => offsetSE_s,
        addBranchResult_o   => output_s
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
        PC_s        <= "00000010001100100100000000000001";
        offsetSE_s  <= "11111111111111111111111111111100";
        wait;
    end process;
end Behavioral;