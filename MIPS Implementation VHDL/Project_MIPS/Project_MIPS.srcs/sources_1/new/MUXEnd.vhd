library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXEnd is
  Port ( 
    clk_i:              IN std_logic;
    targetAddress_i:    IN std_logic_vector(31 downto 0);
    jumpAddress_i:      IN std_logic_vector(31 downto 0);
    Jump_i:             IN std_logic;
    endAddress_o:       OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end MUXEnd;

architecture Behavioral of MUXEnd is

begin
    endAddress_o <= targetAddress_i when Jump_i = '0' else jumpAddress_i;
end Behavioral;
