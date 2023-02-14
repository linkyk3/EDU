library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter_Top_tb is
end ProgramCounter_Top_tb;

architecture Behavioral of ProgramCounter_Top_tb is

component ProgramCounter_Top is
  Port ( 
        clk             :IN std_logic ;
        reset           :IN std_logic;
        PC_in           :IN std_logic_vector (31 downto 0);
        PC_out          :OUT std_logic_vector(31 downto 0);
        instruction     :OUT std_logic_vector(31 downto 0)
  );
end component ;

--Input signals 
signal clk  :std_logic  := '0';
signal reset :std_logic := '0';

--Output signal
signal instruction :std_logic_vector(31 downto 0);

--Fake connections 
signal PC_feedback :std_logic_vector (31 downto 0);

--Clock divider constant
constant clk_period : time := 10 ns;
 
begin
    uut:ProgramCounter_Top 
    port map(
        clk         => clk,
        reset       => reset,
        PC_in       => PC_feedback,
        PC_out      => PC_feedback,
        instruction => instruction
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
        -- Wait for 10 clock periods 
        wait for 10*clk_period;
        reset <= '1';
        wait for 10*clk_period;
        reset <= '0';
        wait for 45ns;
        reset <= '1';
        wait for 10*clk_period;
        reset <= '0';
        wait;
    end process;
end Behavioral;
