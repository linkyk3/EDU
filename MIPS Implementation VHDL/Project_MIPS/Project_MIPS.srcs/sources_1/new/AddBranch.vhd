library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AddBranch is
  Port (
        clk_i:              IN std_logic;
        PC_i:               IN std_logic_vector(31 downto 0); -- program counter (already incremented with +4)
        offsetSE_i:         IN std_logic_vector(31 downto 0); -- sign extended offset from the instruction input
        addBranchResult_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
   );
end AddBranch;

architecture Behavioral of AddBranch is
begin
    AddBranchProcess:process(clk_i)
    begin
        if(rising_edge (clk_i)) then
            addBranchResult_o <=  std_logic_vector(unsigned(PC_i) + unsigned(offsetSE_i));
        end if;
    end process;
end Behavioral;
