library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ShiftLeft2_tb is
end ShiftLeft2_tb;

architecture Behavioral of ShiftLeft2_tb is
    component ShiftLeft2 is
        Port( 
            clk_i:              IN std_logic;
            directInput_i:      IN std_logic_vector(31 downto 0);
            shiftLeft2Output_o: OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    signal clk_s:               std_logic := '0';
    signal directInput_s:       std_logic_vector(31 downto 0);
    signal output_s:            std_logic_vector(31 downto 0) := (others => '0');
    
    constant clkPeriod_s : time := 10 ns;

begin
  UUT: ShiftLeft2
    port map(
        clk_i               => clk_s,
        directInput_i       => directInput_s,
        shiftLeft2Output_o  => output_s   
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
        directInput_s <= "11111111111111111111111111111111";
        wait;
    end process;   

end Behavioral;