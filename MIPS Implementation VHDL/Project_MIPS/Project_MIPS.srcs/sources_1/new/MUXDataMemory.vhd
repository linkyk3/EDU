library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MUXDataMemory is
  Port ( 
        clk_i:              IN std_logic;
        readData_i:         IN std_logic_vector(31 downto 0);
        ALUResult_i:        IN std_logic_vector(31 downto 0);
        PC_i:               IN std_logic_vector(31 downto 0); -- PC+4 for the jal
        MemtoReg_i:         IN std_logic_vector(1 downto 0);
        readWriteData_o:    OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end MUXDataMemory;

architecture Behavioral of MUXDataMemory is
begin
    MuxProcess:process(MemtoReg_i, readData_i, ALUResult_i, PC_i)
    begin
        if (MemtoReg_i = "00") then
            ReadWriteData_o <= ALUResult_i;
        elsif (MemtoReg_i = "01") then
            ReadWriteData_o <= readData_i;
        elsif (MemtoReg_i = "10") then 
            ReadWriteData_o <= PC_i + x"00000004"; -- actually PC+8
        end if;
    end process;
end Behavioral;
