library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Adder is
  Port ( 
        clk_i:          IN std_logic ;
        PC_i:           IN std_logic_vector(31 downto 0);
        addCte_i:       IN std_logic_vector(31 downto 0);
        addPCResult_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end Adder;

architecture Behavioral of Adder is

begin
    AdderProcess:process(clk_i)
    begin
        if(rising_edge(clk_i)) then
            addPCResult_o <= PC_i + addCte_i;
        end if; 
    end process;


end Behavioral;
