library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers_Top is
  Port ( 
        -- Input 
        clk_i:                  IN std_logic;
        instr_RegT_i:           IN std_logic_vector(31 downto 0);
        writeData_RegT_i:       IN std_logic_vector(31 downto 0);
        -- Control 
        RegDst_i:               IN std_logic_vector(1 downto 0);
        RegWrite_i:             IN std_logic;
        -- Output
        readData1_RegT_o:       OUT std_logic_vector(31 downto 0) := (others => '0');
        readData2_RegT_o:       OUT std_logic_vector(31 downto 0) := (others => '0');
        UART_writeData_RegT_o:  OUT std_logic_vector(31 downto 0) := (others => '0') -- copy of readData2 for UART write
  );
end Registers_Top;

architecture Behavioral of Registers_Top is 
    -- Components
    component Registers is
        Port (
            clk_i:              IN std_logic;
            readReg1_i:         IN std_logic_vector(4 downto 0); -- R, I: rs
            readReg2_i:         IN std_logic_vector(4 downto 0); -- R, I: rt
            writeReg_i:         IN std_logic_vector(4 downto 0); -- R: rd 
            writeData_i:        IN std_logic_vector(31 downto 0);
            RegWrite_i:         IN std_logic;
            readData1_o:        OUT std_logic_vector(31 downto 0) := (others => '0');
            readData2_o:        OUT std_logic_vector(31 downto 0) := (others => '0');
            UART_writeData_o:   OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;

    component MUXRegisters is
        Port (
            clk_i:              IN std_logic;
            input1_i:           IN std_logic_vector(4 downto 0);
            input2_i:           IN std_logic_vector(4 downto 0);
            RegDst_i:           IN std_logic_vector(1 downto 0);
            muxOutput_o:        OUT std_logic_vector(4 downto 0) := (others => '0')
        );
    end component;
    
    -- Internal Signals
    signal muxOutput_s:  std_logic_vector(4 downto 0);
    
begin
    MUX:MUXRegisters
    port map(
        clk_i               => clk_i,
        input1_i            => instr_RegT_i(20 downto 16),
        input2_i            => instr_RegT_i(15 downto 11),
        RegDst_i            => RegDst_i,
        muxOutput_o         => muxOutput_s
    );
    
    Regs:Registers
    port map(
        clk_i               => clk_i,
        readReg1_i          => instr_RegT_i(25 downto 21),
        readReg2_i          => instr_RegT_i(20 downto 16),
        writeReg_i          => muxOutput_s,
        writeData_i         => writeData_RegT_i,
        RegWrite_i          => RegWrite_i,
        readData1_o         => readData1_RegT_o,
        readData2_o         => readData2_RegT_o,
        UART_writeData_o    => UART_writeData_RegT_o
    );

end Behavioral;
