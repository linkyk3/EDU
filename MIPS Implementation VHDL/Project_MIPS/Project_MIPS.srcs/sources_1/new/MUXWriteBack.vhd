library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUXWriteBack is
  Port ( 
    clk_i:              IN std_logic;
    readWriteData_i:    IN std_logic_vector(31 downto 0); -- ALU Result/Read data from mem
    UART_readData_i:    IN std_logic_vector(31 downto 0); -- UART read data (8bit)
    ReadEN:             IN std_logic;
    writeData_o:        OUT std_logic_vector(31 downto 0) := (others => '0')
  );
end MUXWriteBack;

architecture Behavioral of MUXWriteBack is

begin
    writeData_o <= readWriteData_i when ReadEN = '0' else UART_readData_i;
end Behavioral;
