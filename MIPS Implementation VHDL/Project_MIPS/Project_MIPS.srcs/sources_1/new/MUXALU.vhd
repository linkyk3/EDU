library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXALU is
  Port ( 
    clk_i:           IN std_logic;
    registerInput_i: IN std_logic_vector(31 downto 0);
    directInput_i:   IN std_logic_vector(31 downto 0);
    ALUSrc_i:        IN std_logic;
    muxALUOutput_o:     OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end MUXALU;

architecture Behavioral of MUXALU is
begin
    muxALUOutput_o <= registerInput_i when ALUSrc_i = '0' else directInput_i;
end Behavioral;

