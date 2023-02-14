library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXJumpReg is
  Port ( 
    clk_i:              IN std_logic;
    registerAddress_i:  IN std_logic_vector(31 downto 0); -- rs register
    endAddress_i:       IN std_logic_vector(31 downto 0); -- jump/target address
    JumpRegister_i:     IN std_logic;
    PCAddress_o:        OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end MUXJumpReg;

architecture Behavioral of MUXJumpReg is

begin
    PCAddress_o <= endAddress_i when JumpRegister_i = '0' else registerAddress_i;
end Behavioral;
