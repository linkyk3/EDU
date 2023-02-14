library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity JumpBlock is
  Port ( 
    clk_i:          IN std_logic;
    instr_i:        IN std_logic_vector(31 downto 0); -- slice to 25-0
    PC_i:           IN std_logic_vector(31 downto 0);
    jumpAddress_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end JumpBlock;

architecture Behavioral of JumpBlock is

begin
    JumpBlockProcess:process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            jumpAddress_o <= (std_logic_vector(PC_i(31 downto 28)) & (instr_i(25 downto 0) & "00"));
        end if;
    end process;
end Behavioral;
