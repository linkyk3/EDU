library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LogicBranch is
    Port ( 
        clk_i:      IN std_logic;
        BEQ_i:      IN std_logic;
        BNE_i:      IN std_logic;  
        Zero_i:     IN std_logic;
        PCSrc_o:    OUT std_logic := '0'
    );
end LogicBranch;

architecture Behavioral of LogicBranch is
begin
    PCSrc_o <= (BEQ_i AND Zero_i) OR (BNE_i AND (NOT Zero_i));
end Behavioral;