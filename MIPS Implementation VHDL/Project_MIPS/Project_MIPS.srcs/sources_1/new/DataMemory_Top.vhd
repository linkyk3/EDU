library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory_Top is
  Port ( 
    -- Input
    clk_i:              IN std_logic;
    address_DM_i:       IN std_logic_vector(31 downto 0);
    writeData_DM_i:     IN std_logic_vector(31 downto 0);
    PC_DM_i:            IN std_logic_vector(31 downto 0);
    -- Control
    MemtoReg_i:         IN std_logic_vector(1 downto 0);
    MemWrite_i:         IN std_logic;
    MemRead_i:          IN std_logic;
    Byte_i:             IN std_logic;
    HalfWord_i:         IN std_logic;
    -- Output
    readWriteData_DM_o: OUT std_logic_vector(31 downto 0)
  );
end DataMemory_Top;

architecture Behavioral of DataMemory_Top is
    -- Components
    component DataMemory is
        Port (
            clk_i:          IN std_logic;
            address_i:      IN std_logic_vector(31 downto 0);
            writeData_i:    IN std_logic_vector(31 downto 0);
            MemWrite_i:     IN std_logic;
            MemRead_i:      IN std_logic;
            Byte_i:         IN std_logic;
            HalfWord_i:     IN std_logic;
            readData_o:     OUT std_logic_vector(31 downto 0) := (others => '0')  
        );
    end component;
    
    component MUXDataMemory is
        Port (
            clk_i:              IN std_logic;
            readData_i:         IN std_logic_vector(31 downto 0);
            ALUResult_i:        IN std_logic_vector(31 downto 0);
            PC_i:               IN std_logic_vector(31 downto 0);
            MemtoReg_i:         IN std_logic_vector(1 downto 0);
            readWriteData_o:    OUT std_logic_vector(31 downto 0) := (others => '0')
        );
    end component;
    
    signal readData_s:   std_logic_vector(31 downto 0);
    
begin
    DataMem:DataMemory
    port map(
        clk_i       => clk_i,
        address_i   => address_DM_i,
        writeData_i => writeData_DM_i,
        MemWrite_i  => MemWrite_i,
        MemRead_i   => MemRead_i,
        Byte_i      => Byte_i,
        HalfWord_i  => HalfWord_i,
        readData_o  => readData_s
    );
    
    MuxDataMem:MUXDataMemory
    port map(
        clk_i           => clk_i,
        readData_i      => readData_s,
        ALUResult_i     => address_DM_i,
        PC_i            => PC_DM_i,
        MemtoReg_i      => MemtoReg_i,
        readWriteData_o => readWriteData_DM_o
    );
end Behavioral;
