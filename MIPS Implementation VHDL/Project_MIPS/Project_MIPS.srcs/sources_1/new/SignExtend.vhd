library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SignExtend is
  Port ( 
        clk_i:          IN std_logic;
        instr_SE_i:     IN std_logic_vector(15 downto 0);
        immediate_SE_o: OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end SignExtend;

architecture Behavioral of SignExtend is

begin
    SignExtendProcess:process(clk_i)
    begin
        if(rising_edge(clk_i)) then
            if (instr_SE_i(15) = '1') then
                immediate_SE_o <= "1111111111111111"&instr_SE_i;
            elsif (instr_SE_i(15) = '0') then
                immediate_SE_o <= "0000000000000000"&instr_SE_i;
            end if;
        end if;
    end process;
end Behavioral;
