library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ORBranch_tb is
end ORBranch_tb;

architecture Behavioral of ORBranch_tb is

component ORBranch is
    Port( 
        clk_i:           IN std_logic;
        Branch_i:        IN std_logic;
        Zero_i:          IN std_logic;
        PCSrc_o:         OUT std_logic := '0'
    );
    end component ;

 signal clk_i:           std_logic :='0';
 signal Branch_i:        std_logic :='0';
 signal Zero_i:          std_logic :='0';
 signal PCSrc_o:         std_logic := '0';
 constant clkPeriod_s :   time := 10 ns;
 

begin
    UUT: ORBranch
    port map ( 
        clk_i       => clk_i,
        Branch_i    => Branch_i,
        Zero_i      => Zero_i,
        PCSrc_o     => PCSrc_o
    );
    clk_process:process
    begin
        clk_i <= '0';
        wait for clkPeriod_s/2;
        clk_i <= '1';
        wait for clkPeriod_s/2;
   end process;
    
    stim_proc:process
    begin
        wait for 5ns;
        Branch_i    <= '0';
        Zero_i      <= '0';
        wait for 10ns;
        Branch_i    <= '0';
        Zero_i      <= '1';
        wait for 10ns;
        Branch_i    <= '1';
        Zero_i      <= '0';
        wait for 10ns;
        Branch_i    <= '1';
        Zero_i      <= '1';
        wait;
    end process;


end Behavioral;
