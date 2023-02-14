library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXShiftLogic is
  Port ( 
    clk_i:                  IN std_logic;
    readData1_i:            IN std_logic_vector(31 downto 0);
    instr_i:                IN std_logic_vector(31 downto 0); -- pass the full instruction -> in ALU: slice the shamt
    ShiftLogic_i:           IN std_logic;
    muxShiftLogicOutput_o:  OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end MUXShiftLogic;

architecture Behavioral of MUXShiftLogic is

begin
    muxShiftLogicOutput_o <= readData1_i when ShiftLogic_i = '0' else instr_i; -- instr_i is sliced to shamt in the ALU -> not necessary to change the port dimensions
end Behavioral;
