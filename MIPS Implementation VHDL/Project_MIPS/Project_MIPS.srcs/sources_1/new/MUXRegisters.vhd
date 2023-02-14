library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MUXRegisters is
  Port ( 
        clk_i:          IN std_logic;
        input1_i:       IN std_logic_vector(4 downto 0);
        input2_i:       IN std_logic_vector(4 downto 0);
        RegDst_i:       IN std_logic_vector(1 downto 0);
        muxOutput_o:    OUT std_logic_vector(4 downto 0) := (others => '0')
  );
end MUXRegisters;

architecture Behavioral of MUXRegisters is
begin
    MuxProcess:process(RegDst_i, input1_i, input2_i, RegDst_i)
    begin
        if (RegDst_i = "00") then
            muxOutput_o <= input1_i;
        elsif (RegDst_i = "01") then
            muxOutput_o <= input2_i;
        elsif (RegDst_i = "10") then
            muxOutput_o <= "11111"; -- jal: R[31]
        end if;
    end process;
end Behavioral;
