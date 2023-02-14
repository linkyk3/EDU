library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXBranch is
    Port ( 
        clk_i:              IN std_logic;
        PC_i :              IN std_logic_vector(31 downto 0);
        ADDResult_i:        IN std_logic_vector(31 downto 0);
        PCSrc_i:            IN std_logic;
        muxBranchOutput_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
    );
end MUXBranch;

architecture Behavioral of MUXBranch is

begin
    muxBranchOutput_o <= PC_i when PCSrc_i = '0' else ADDResult_i;
end Behavioral;