library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ShiftLeft2 is
Port ( 
    clk_i:              IN std_logic;
    directInput_i:      IN std_logic_vector(31 downto 0);
    shiftLeft2Output_o: OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end ShiftLeft2;

architecture Behavioral of ShiftLeft2 is
begin
    ShiftLeft2Process:process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            shiftLeft2Output_o <= directInput_i(29 downto 0) & "00"; 
        end if;
    end process;
end Behavioral;